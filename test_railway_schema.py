#!/usr/bin/env python3
"""
Test actual Railway database connection and schema
"""

import os
import sys
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

load_dotenv()

def test_railway_schema():
    """Test Railway database and check users table schema"""
    print("=== Testing Railway Database Schema ===\n")
    
    # Get Railway database URL
    railway_url = os.getenv('DATABASE_URL')
    if not railway_url:
        print("❌ DATABASE_URL not found")
        return False
    
    # Set Railway environment
    os.environ['RAILWAY_ENVIRONMENT'] = 'production'
    
    # If URL contains localhost, try to get the public URL
    if 'localhost' in railway_url:
        print("⚠️  DATABASE_URL contains localhost, trying DATABASE_PUBLIC_URL...")
        public_url = os.getenv('DATABASE_PUBLIC_URL')
        if public_url:
            railway_url = public_url
            print(f"✅ Using DATABASE_PUBLIC_URL instead")
        else:
            print("❌ No DATABASE_PUBLIC_URL found")
    
    # Handle Railway's postgres:// URLs
    if railway_url.startswith('postgres://'):
        railway_url = railway_url.replace('postgres://', 'postgresql://', 1)
    
    print(f"🔗 Database URL: {railway_url[:50]}...")
    
    try:
        # Connect with Railway SSL requirements
        conn = psycopg2.connect(railway_url, sslmode='require', connect_timeout=60)
        print(f"✅ Connected to Railway database successfully!")
        
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        # Check users table schema
        print(f"\n📋 Users table schema:")
        cursor.execute("""
            SELECT 
                column_name,
                data_type,
                is_nullable,
                column_default
            FROM information_schema.columns 
            WHERE table_name = 'users' AND table_schema = 'public'
            ORDER BY ordinal_position;
        """)
        
        columns = cursor.fetchall()
        for col in columns:
            nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
            print(f"  - {col['column_name']}: {col['data_type']} {nullable}")
        
        # Specifically check for password columns
        print(f"\n🔐 Password-related columns:")
        password_cols = [col for col in columns if 'password' in col['column_name'].lower()]
        
        if password_cols:
            for col in password_cols:
                nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
                print(f"  ✅ {col['column_name']}: {col['data_type']} {nullable}")
        else:
            print(f"  ❌ No password columns found!")
        
        # Test a simple insert (dry run)
        print(f"\n🧪 Testing INSERT statement structure...")
        try:
            cursor.execute("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = 'users' 
                AND column_name IN ('password', 'password_hash')
                AND table_schema = 'public'
            """)
            available_password_cols = [row['column_name'] for row in cursor.fetchall()]
            print(f"  Available password columns: {available_password_cols}")
            
            if 'password_hash' in available_password_cols and 'password' not in available_password_cols:
                print(f"  ✅ Only password_hash exists - registration should work")
            elif 'password' in available_password_cols and 'password_hash' in available_password_cols:
                print(f"  ⚠️  Both password and password_hash exist - need both in INSERT")
            elif 'password' in available_password_cols:
                print(f"  ⚠️  Only password exists - need to update registration code")
            else:
                print(f"  ❌ No password columns found!")
                
        except Exception as e:
            print(f"  ❌ Error checking columns: {str(e)}")
        
        cursor.close()
        conn.close()
        
        return True
        
    except Exception as e:
        print(f"❌ Railway connection failed: {str(e)}")
        return False

if __name__ == "__main__":
    success = test_railway_schema()
    if success:
        print(f"\n🎉 Railway schema test completed!")
    else:
        print(f"\n❌ Railway schema test failed!")
        sys.exit(1) 
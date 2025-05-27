#!/usr/bin/env python3
"""
Test Railway database connection with the correct public proxy URL.
"""

import os
import sys
import psycopg2
from urllib.parse import urlparse

def test_railway_connection():
    """Test Railway database connection with public proxy URL"""
    print("=== Testing Railway Database Connection ===\n")
    
    # Use the CURRENT Railway URL with correct password
    railway_url = "postgresql://postgres:NOpgaTHGiZhHsBCyRirumdUPlbbGnLyG@yamanote.proxy.rlwy.net:53645/railway"
    
    print(f"Testing Railway URL: {railway_url}")
    
    # Parse the public URL
    parsed = urlparse(railway_url)
    
    db_params = {
        'dbname': parsed.path[1:],
        'user': parsed.username,
        'password': parsed.password,
        'host': parsed.hostname,
        'port': parsed.port,
        'sslmode': 'require',
        'connect_timeout': 60,
        'application_name': 'rally_tennis_railway_test'
    }
    
    print(f"\nConnection parameters:")
    print(f"  Host: {db_params['host']}")
    print(f"  Port: {db_params['port']}")
    print(f"  Database: {db_params['dbname']}")
    print(f"  User: {db_params['user']}")
    print(f"  SSL Mode: {db_params['sslmode']}")
    print(f"  Timeout: {db_params['connect_timeout']}s")
    
    # Test connection
    max_retries = 3
    for attempt in range(max_retries):
        print(f"\n--- Attempt {attempt + 1}/{max_retries} ---")
        
        try:
            print("Connecting to Railway database...")
            conn = psycopg2.connect(**db_params)
            print("✅ Railway connection successful!")
            
            # Test query
            cursor = conn.cursor()
            cursor.execute("SELECT 1 as test, current_database(), version()")
            result = cursor.fetchone()
            print(f"✅ Query successful: test={result[0]}")
            print(f"Database: {result[1]}")
            print(f"PostgreSQL: {result[2][:50]}...")
            
            # Check tables
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """)
            tables = cursor.fetchall()
            print(f"\nTables in Railway database: {len(tables)}")
            for table in tables:
                print(f"  - {table[0]}")
            
            cursor.close()
            conn.close()
            print("\n🎉 Railway database test PASSED!")
            
            print(f"\n📋 NEXT STEPS:")
            print(f"✅ DATABASE_URL is correctly configured in Railway")
            print(f"✅ Connection to Railway database is working")
            print(f"🚀 Ready to deploy! Run: railway up")
            
            return True
            
        except Exception as e:
            print(f"❌ Connection failed: {e}")
            
            if 'timeout' in str(e).lower():
                print("\n🔍 Timeout troubleshooting:")
                print("  1. Verify Railway database service is running")
                print("  2. Check Railway service status in dashboard")
                print("  3. Ensure your Railway plan supports external connections")
                print("  4. Try connecting from Railway's web terminal")
            
            if attempt < max_retries - 1:
                import time
                wait_time = 2 ** attempt
                print(f"⏳ Waiting {wait_time}s before retry...")
                time.sleep(wait_time)
    
    print(f"\n💥 All connection attempts failed!")
    print(f"\n🔧 TROUBLESHOOTING:")
    print(f"1. Check Railway dashboard for database service status")
    print(f"2. Verify the proxy URL and port are correct")
    print(f"3. Check if the database password has changed")
    print(f"4. Try connecting from Railway's web terminal first")
    
    return False

if __name__ == "__main__":
    success = test_railway_connection()
    sys.exit(0 if success else 1) 
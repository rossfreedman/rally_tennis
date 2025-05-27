#!/usr/bin/env python3
"""
Standalone database connection test for Railway deployment.
This script tests the database connection independently of the main application.
"""

import os
import sys
import traceback
from dotenv import load_dotenv
import psycopg2
from urllib.parse import urlparse
from psycopg2.extras import RealDictCursor

# Load environment variables
load_dotenv()

def test_database_connection():
    """Test database connection with detailed logging"""
    print("=== Railway Database Connection Test ===\n")
    
    # Get DATABASE_URL
    database_url = os.getenv('DATABASE_URL')
    if not database_url:
        print("ERROR: DATABASE_URL environment variable not found!")
        print("Please ensure DATABASE_URL is set in your Railway environment variables.")
        return False
    
    print(f"DATABASE_URL found: {database_url[:50]}...")
    
    # Handle Railway's postgres:// URLs
    if database_url.startswith('postgres://'):
        database_url = database_url.replace('postgres://', 'postgresql://', 1)
        print("Converted postgres:// to postgresql://")
    
    # Railway internal URLs should work directly - no conversion needed
    
    # Parse URL
    try:
        parsed = urlparse(database_url)
        print(f"\nParsed connection details:")
        print(f"  Host: {parsed.hostname}")
        print(f"  Port: {parsed.port}")
        print(f"  Database: {parsed.path[1:]}")
        print(f"  Username: {parsed.username}")
        print(f"  Password: {'*' * len(parsed.password) if parsed.password else 'None'}")
    except Exception as e:
        print(f"ERROR parsing DATABASE_URL: {e}")
        return False
    
    # Prepare connection parameters
    hostname = parsed.hostname or ''
    sslmode = 'require' if ('railway.app' in hostname or 'rlwy.net' in hostname) else 'prefer'
    connect_timeout = int(os.getenv('PGCONNECT_TIMEOUT', '60'))
    
    db_params = {
        'dbname': parsed.path[1:],
        'user': parsed.username,
        'password': parsed.password,
        'host': parsed.hostname,
        'port': parsed.port or 5432,
        'sslmode': sslmode,
        'connect_timeout': connect_timeout,
        'application_name': 'rally_tennis_connection_test'
    }
    
    print(f"\nConnection parameters:")
    print(f"  SSL Mode: {sslmode}")
    print(f"  Connect Timeout: {connect_timeout}s")
    
    # Test connection with retries
    max_retries = 3
    for attempt in range(max_retries):
        print(f"\n--- Connection Attempt {attempt + 1}/{max_retries} ---")
        
        try:
            print("Attempting to connect...")
            conn = psycopg2.connect(**db_params)
            print("✅ Connection successful!")
            
            # Test a simple query
            print("Testing simple query...")
            cursor = conn.cursor()
            cursor.execute("SELECT 1 as test, version() as pg_version")
            result = cursor.fetchone()
            print(f"✅ Query successful: test={result[0]}")
            print(f"PostgreSQL version: {result[1]}")
            
            # Test table existence
            print("Checking for application tables...")
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """)
            tables = cursor.fetchall()
            if tables:
                print(f"✅ Found {len(tables)} tables:")
                for table in tables:
                    print(f"  - {table[0]}")
            else:
                print("⚠️  No tables found (database may need initialization)")
            
            cursor.close()
            conn.close()
            print("\n🎉 Database connection test PASSED!")
            return True
            
        except psycopg2.OperationalError as e:
            error_msg = str(e)
            print(f"❌ Connection failed: {error_msg}")
            
            if 'timeout expired' in error_msg:
                print("\n🔍 Timeout troubleshooting:")
                print("  1. Check if Railway database service is running")
                print("  2. Verify the proxy URL and port are correct")
                print("  3. Check Railway service logs for database issues")
                print("  4. Ensure your Railway plan supports external connections")
            
            if 'postgres.railway.internal' in error_msg:
                print("\n🔍 Internal hostname detected:")
                print("  The DATABASE_URL is using Railway's internal hostname")
                print("  This should be automatically converted to the public proxy URL")
            
            if attempt < max_retries - 1:
                import time
                wait_time = 2 ** attempt  # Exponential backoff
                print(f"⏳ Waiting {wait_time}s before retry...")
                time.sleep(wait_time)
            
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
            print(f"Error type: {type(e).__name__}")
            traceback.print_exc()
            break
    
    print(f"\n💥 All {max_retries} connection attempts failed!")
    return False

def test_railway_connection():
    """Test direct connection to Railway database"""
    
    # Use the Railway DATABASE_URL environment variable directly
    database_url = os.getenv('DATABASE_URL')
    if not database_url:
        print("❌ DATABASE_URL environment variable not found!")
        return False
    
    # Handle Railway's postgres:// URLs
    if database_url.startswith('postgres://'):
        database_url = database_url.replace('postgres://', 'postgresql://', 1)
    
    print(f"Testing Railway connection...")
    print(f"Database: railway")
    
    try:
        conn = psycopg2.connect(database_url, sslmode='require', connect_timeout=30)
        print("✅ Connected to Railway database successfully!")
        
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            # Test the exact query from settings
            cursor.execute('''
                SELECT u.first_name, u.last_name, u.email, u.club_automation_password,
                       c.name as club, s.name as series
                FROM users u
                LEFT JOIN clubs c ON u.club_id = c.id
                LEFT JOIN series s ON u.series_id = s.id
                WHERE u.email = %s
            ''', ('rossfreedman@gmail.com',))
            
            user_data = cursor.fetchone()
            
            # Test a simple query
            cursor.execute("SELECT 1 as test, version() as pg_version")
            result = cursor.fetchone()
            print(f"✅ Query successful: test={result[0]}")
            print(f"PostgreSQL version: {result[1]}")
            
            # Test table existence
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """)
            tables = cursor.fetchall()
            if tables:
                print(f"✅ Found {len(tables)} tables:")
                for table in tables:
                    print(f"  - {table[0]}")
            else:
                print("⚠️  No tables found (database may need initialization)")
            
            cursor.close()
            conn.close()
            print("\n🎉 Database connection test PASSED!")
            return True
            
    except psycopg2.OperationalError as e:
        error_msg = str(e)
        print(f"❌ Connection failed: {error_msg}")
        
        if 'timeout expired' in error_msg:
            print("\n🔍 Timeout troubleshooting:")
            print("  1. Check if Railway database service is running")
            print("  2. Verify the proxy URL and port are correct")
            print("  3. Check Railway service logs for database issues")
            print("  4. Ensure your Railway plan supports external connections")
        
        if 'postgres.railway.internal' in error_msg:
            print("\n🔍 Internal hostname detected:")
            print("  The DATABASE_URL is using Railway's internal hostname")
            print("  This should be automatically converted to the public proxy URL")
        
        return False
    
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        print(f"Error type: {type(e).__name__}")
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_database_connection()
    sys.exit(0 if success else 1) 
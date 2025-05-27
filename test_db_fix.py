#!/usr/bin/env python3
"""
Test script to verify database connection fixes
"""

import os
import sys
from database_config import test_db_connection, get_db_url, get_db

def main():
    print("=== Testing Database Connection Fixes ===")
    print()
    
    # Test 1: Check database URL
    print("1. Testing database URL configuration...")
    db_url = get_db_url()
    print(f"   Database URL: {db_url.split('@')[0]}@[REDACTED]")
    
    if 'yamanote.proxy.rlwy.net' in db_url:
        print("   ✅ Railway proxy URL detected")
    elif 'localhost' in db_url:
        print("   ℹ️  Local database URL detected")
    else:
        print("   ⚠️  Unknown database URL format")
    print()
    
    # Test 2: Test connection function
    print("2. Testing database connection...")
    try:
        success, error = test_db_connection()
        if success:
            print("   ✅ Database connection successful!")
        else:
            print(f"   ❌ Database connection failed: {error}")
    except Exception as e:
        print(f"   ❌ Database connection error: {str(e)}")
    print()
    
    # Test 3: Test context manager
    print("3. Testing database context manager...")
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                cursor.execute('SELECT version()')
                version = cursor.fetchone()[0]
                print(f"   ✅ PostgreSQL version: {version}")
    except Exception as e:
        print(f"   ❌ Context manager failed: {str(e)}")
    print()
    
    print("=== Test Complete ===")

if __name__ == "__main__":
    main() 
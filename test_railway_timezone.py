#!/usr/bin/env python3
"""
Test script to verify timezone functionality on Railway
Run this after deploying and running the migration
"""

import os
import sys
import requests
from datetime import datetime

# Add current directory to path for imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_railway_app_health():
    """Test that the Railway app is responding"""
    print("🔍 Testing Railway app health...")
    
    # Get Railway app URL from environment or prompt user
    app_url = os.getenv('RAILWAY_APP_URL', 'https://rally-tennis-production.up.railway.app')
    
    try:
        # Test health endpoint
        response = requests.get(f"{app_url}/health", timeout=30)
        if response.status_code == 200:
            print(f"✅ App is healthy: {response.status_code}")
            return True
        else:
            print(f"⚠️  App responded but not healthy: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ App health check failed: {str(e)}")
        return False

def test_local_database_connection():
    """Test local database connection (if running locally)"""
    print("🔍 Testing database connection...")
    
    try:
        from database_utils import execute_query_one
        
        # Test basic connection
        result = execute_query_one("SELECT NOW() as current_time")
        if result:
            print(f"✅ Database connected: {result['current_time']}")
            return True
        else:
            print("❌ Database connection failed")
            return False
    except Exception as e:
        print(f"❌ Database connection error: {str(e)}")
        return False

def test_migration_status():
    """Test migration status"""
    print("🔍 Checking migration status...")
    
    try:
        from database_utils import execute_query_one
        
        # Check Alembic version
        result = execute_query_one("SELECT version_num FROM alembic_version")
        if result:
            version = result['version_num']
            print(f"📋 Current migration: {version}")
            
            if version == '1c2bac3892b6':
                print("✅ Timezone migration is applied")
                return True
            else:
                print(f"⚠️  Migration not applied: {version}")
                return False
        else:
            print("❌ Could not check migration status")
            return False
    except Exception as e:
        print(f"❌ Migration status check failed: {str(e)}")
        return False

def test_schema_changes():
    """Test that schema changes are correct"""
    print("🔍 Verifying schema changes...")
    
    try:
        from database_utils import execute_query_one
        
        # Check column type
        result = execute_query_one("""
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_name = 'player_availability'
            AND column_name = 'match_date'
        """)
        
        if result:
            data_type = result['data_type']
            print(f"📊 match_date column type: {data_type}")
            
            if 'timestamp' in data_type.lower():
                print("✅ Column is TIMESTAMPTZ")
            else:
                print(f"❌ Column is still: {data_type}")
                return False
        
        # Check constraint
        constraint_result = execute_query_one("""
            SELECT conname 
            FROM pg_constraint 
            WHERE conrelid = 'player_availability'::regclass
            AND conname = 'match_date_must_be_midnight_utc'
        """)
        
        if constraint_result:
            print("✅ Midnight UTC constraint exists")
        else:
            print("❌ Midnight UTC constraint missing")
            return False
            
        return True
        
    except Exception as e:
        print(f"❌ Schema verification failed: {str(e)}")
        return False

def test_date_operations():
    """Test that date operations work correctly"""
    print("🔍 Testing date operations...")
    
    try:
        from routes.act.availability import update_player_availability, get_player_availability
        from utils.date_utils import date_to_db_timestamp
        
        # Test date conversion
        test_date = "2025-06-15"
        utc_timestamp = date_to_db_timestamp(test_date)
        print(f"📅 Date conversion: {test_date} -> {utc_timestamp}")
        
        if utc_timestamp.tzinfo is not None and str(utc_timestamp).endswith('+00:00'):
            print("✅ Date converts to UTC correctly")
        else:
            print(f"❌ Date conversion issue: {utc_timestamp}")
            return False
        
        # Test application functions
        test_player = "Test Railway User"
        test_series = "Series 2B"
        test_status = 1
        
        print(f"🧪 Testing availability functions...")
        
        # Update availability
        success = update_player_availability(test_player, test_date, test_status, test_series)
        if success:
            print("✅ Availability update successful")
        else:
            print("❌ Availability update failed")
            return False
        
        # Get availability
        status = get_player_availability(test_player, test_date, test_series)
        if status == test_status:
            print(f"✅ Availability retrieval successful: {status}")
        else:
            print(f"❌ Availability retrieval failed: got {status}, expected {test_status}")
            return False
        
        # Cleanup
        from database_utils import execute_query_one
        execute_query_one(
            "DELETE FROM player_availability WHERE player_name = %(name)s",
            {'name': test_player}
        )
        print("✅ Test cleanup completed")
        
        return True
        
    except Exception as e:
        print(f"❌ Date operations test failed: {str(e)}")
        return False

def test_timezone_consistency():
    """Test timezone consistency"""
    print("🔍 Testing timezone consistency...")
    
    try:
        from database_utils import execute_query_one
        
        # Check a few sample records
        result = execute_query_one("""
            SELECT match_date, 
                   date_part('hour', match_date AT TIME ZONE 'UTC') as hour_utc,
                   date_part('minute', match_date AT TIME ZONE 'UTC') as minute_utc
            FROM player_availability 
            LIMIT 3
        """)
        
        if result:
            print(f"📊 Sample record: {result['match_date']}")
            print(f"🕐 UTC hour: {result['hour_utc']}, minute: {result['minute_utc']}")
            
            if result['hour_utc'] == 0 and result['minute_utc'] == 0:
                print("✅ Data is stored as midnight UTC")
                return True
            else:
                print("⚠️  Data may not be midnight UTC")
                return False
        else:
            print("ℹ️  No data to test")
            return True
            
    except Exception as e:
        print(f"❌ Timezone consistency test failed: {str(e)}")
        return False

def main():
    """Main test function"""
    print("🧪 Railway Timezone Test Script")
    print("=" * 40)
    
    tests = [
        ("Database Connection", test_local_database_connection),
        ("Migration Status", test_migration_status),
        ("Schema Changes", test_schema_changes),
        ("Date Operations", test_date_operations),
        ("Timezone Consistency", test_timezone_consistency),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n🧪 Running: {test_name}")
        try:
            if test_func():
                print(f"✅ {test_name}: PASSED")
                passed += 1
            else:
                print(f"❌ {test_name}: FAILED")
        except Exception as e:
            print(f"❌ {test_name}: ERROR - {str(e)}")
    
    print(f"\n📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Timezone migration is working correctly.")
        return True
    else:
        print("⚠️  Some tests failed. Check the issues above.")
        return False

if __name__ == "__main__":
    success = main()
    if success:
        print("\n✅ Railway timezone functionality verified!")
        sys.exit(0)
    else:
        print("\n❌ Some issues found. Please investigate.")
        sys.exit(1) 
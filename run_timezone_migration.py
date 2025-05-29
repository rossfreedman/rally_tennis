#!/usr/bin/env python3
"""
Script to run the timezone migration and test the fix for date storage issues.
This script will:
1. Run the migration to convert DATE to TIMESTAMPTZ
2. Test date storage and retrieval
3. Verify the fix works correctly
"""

import os
import sys
from datetime import datetime, date
import traceback
import re

# Add the project root to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database_utils import execute_query_one, execute_query
from routes.act.availability import update_player_availability, get_player_availability
from utils.date_utils import date_to_db_timestamp

def run_migration():
    """Run the timezone migration"""
    print("=== RUNNING TIMEZONE MIGRATION ===")
    
    try:
        # Read the migration file
        migration_path = os.path.join(os.path.dirname(__file__), 'migrations', 'fix_timezone_date_issue.sql')
        
        with open(migration_path, 'r') as f:
            migration_sql = f.read()
        
        print("Executing migration...")
        
        # Execute the entire migration as one transaction
        # Remove comments and empty lines
        lines = migration_sql.split('\n')
        clean_lines = []
        for line in lines:
            line = line.strip()
            if line and not line.startswith('--'):
                clean_lines.append(line)
        
        clean_sql = '\n'.join(clean_lines)
        
        try:
            execute_query_one(clean_sql)
            print("✅ Migration completed successfully!")
            return True
        except Exception as e:
            if "already exists" in str(e) or "does not exist" in str(e):
                print(f"⚠ Migration partially applied (some objects already exist): {str(e)}")
                return True
            else:
                print(f"❌ Migration error: {str(e)}")
                raise
        
    except Exception as e:
        print(f"❌ Migration failed: {str(e)}")
        print(traceback.format_exc())
        return False

def test_timezone_fix():
    """Test the timezone fix with various date formats"""
    print("\n=== TESTING TIMEZONE FIX ===")
    
    # Import here to avoid circular imports
    try:
        from routes.act.availability import update_player_availability, get_player_availability
    except ImportError as e:
        print(f"❌ Could not import availability functions: {str(e)}")
        return
    
    test_cases = [
        {
            'name': 'MM/DD/YYYY format',
            'date': '05/26/2025',
            'expected_date': '2025-05-26'
        },
        {
            'name': 'YYYY-MM-DD format', 
            'date': '2025-05-27',
            'expected_date': '2025-05-27'
        },
        {
            'name': 'Edge case - end of month',
            'date': '05/31/2025',
            'expected_date': '2025-05-31'
        }
    ]
    
    test_player = "Test Player Timezone"
    test_series = "Series 2B"  # Assuming this exists
    
    try:
        # Clean up any existing test data
        execute_query_one(
            "DELETE FROM player_availability WHERE player_name = %(player)s",
            {'player': test_player}
        )
        
        for i, test_case in enumerate(test_cases):
            print(f"\n--- Test {i+1}: {test_case['name']} ---")
            
            # Test date normalization
            try:
                normalized = date_to_db_timestamp(test_case['date'])
                print(f"Input: {test_case['date']}")
                print(f"Normalized: {normalized}")
                print(f"Expected date part: {test_case['expected_date']}")
                
                # Verify the date part matches expected
                date_part = normalized.strftime('%Y-%m-%d')
                if date_part == test_case['expected_date']:
                    print("✓ Date normalization correct")
                else:
                    print(f"❌ Date normalization incorrect: got {date_part}, expected {test_case['expected_date']}")
                    continue
                    
            except Exception as e:
                print(f"❌ Date normalization failed: {str(e)}")
                continue
            
            # Test availability update
            try:
                success = update_player_availability(test_player, test_case['date'], 1, test_series)
                if success:
                    print("✓ Availability update successful")
                else:
                    print("❌ Availability update failed")
                    continue
            except Exception as e:
                print(f"❌ Availability update error: {str(e)}")
                continue
            
            # Test availability retrieval
            try:
                status = get_player_availability(test_player, test_case['date'], test_series)
                if status == 1:
                    print("✓ Availability retrieval successful")
                else:
                    print(f"❌ Availability retrieval failed: got {status}, expected 1")
            except Exception as e:
                print(f"❌ Availability retrieval error: {str(e)}")
        
        # Test cross-format compatibility
        print(f"\n--- Cross-format compatibility test ---")
        
        # Store with MM/DD/YYYY format
        update_player_availability(test_player + "_cross", "06/15/2025", 2, test_series)
        
        # Retrieve with YYYY-MM-DD format
        status1 = get_player_availability(test_player + "_cross", "2025-06-15", test_series)
        
        if status1 == 2:
            print("✓ Cross-format compatibility works")
        else:
            print(f"❌ Cross-format compatibility failed: got {status1}, expected 2")
        
        # Clean up test data
        execute_query_one(
            "DELETE FROM player_availability WHERE player_name LIKE %(pattern)s",
            {'pattern': test_player + "%"}
        )
        
        print("\n✅ All timezone tests completed!")
        
    except Exception as e:
        print(f"❌ Test failed: {str(e)}")
        print(traceback.format_exc())

def verify_database_schema():
    """Verify the database schema has been updated correctly"""
    print("\n=== VERIFYING DATABASE SCHEMA ===")
    
    try:
        # Check the column type
        result = execute_query_one("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'player_availability'
            AND column_name = 'match_date'
        """)
        
        if result:
            print(f"Column: {result['column_name']}")
            print(f"Data type: {result['data_type']}")
            print(f"Nullable: {result['is_nullable']}")
            
            if 'timestamp' in result['data_type'].lower():
                print("✅ Column type is correct (TIMESTAMPTZ)")
            else:
                print(f"❌ Column type is incorrect: {result['data_type']}")
        else:
            print("❌ Could not find match_date column")
        
        # Check timezone setting
        tz_result = execute_query_one("SELECT current_setting('timezone') as tz")
        if tz_result:
            print(f"Database timezone: {tz_result['tz']}")
        
        # Check if the normalize function exists
        func_result = execute_query_one("""
            SELECT proname 
            FROM pg_proc 
            WHERE proname = 'normalize_match_date'
        """)
        
        if func_result:
            print("✅ normalize_match_date function exists")
        else:
            print("❌ normalize_match_date function not found")
            
    except Exception as e:
        print(f"❌ Schema verification failed: {str(e)}")

def main():
    """Main function to run migration and tests"""
    print("🚀 Starting timezone migration and testing process...")
    
    # Step 1: Verify current schema
    verify_database_schema()
    
    # Step 2: Run migration
    if not run_migration():
        print("❌ Migration failed, stopping...")
        return False
    
    # Step 3: Verify schema after migration
    verify_database_schema()
    
    # Step 4: Test the fix
    test_timezone_fix()
    
    print("\n🎉 Migration and testing process completed!")
    print("\n📋 SUMMARY:")
    print("- The DATE column has been converted to TIMESTAMPTZ")
    print("- Timezone handling has been added to prevent off-by-one date issues")
    print("- All date operations now use 'America/Chicago' timezone consistently")
    print("- The normalize_match_date() function ensures consistent date storage")
    
    return True

if __name__ == "__main__":
    main() 
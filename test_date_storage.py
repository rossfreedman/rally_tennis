#!/usr/bin/env python3

import os
import sys
from datetime import datetime

# Add the project root to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database_utils import execute_query_one

def test_date_storage():
    """Test how dates are stored in the database"""
    
    print("=== Testing Date Storage ===")
    
    # Test date that should be stored
    test_date = "2025-05-26"
    test_player = "Test Player"
    test_series_id = 184  # Series 2B
    test_status = 1
    
    print(f"Input date: {test_date}")
    
    # Test 1: Direct string insertion
    print("\n--- Test 1: Direct string insertion ---")
    try:
        result1 = execute_query_one(
            """
            INSERT INTO player_availability 
                (player_name, match_date, availability_status, series_id, updated_at)
            VALUES 
                (%(player_name)s, %(match_date)s, %(status)s, %(series_id)s, CURRENT_TIMESTAMP)
            ON CONFLICT (player_name, match_date, series_id) 
            DO UPDATE SET 
                availability_status = %(status)s,
                updated_at = CURRENT_TIMESTAMP
            RETURNING id, match_date, updated_at
            """,
            {
                'player_name': test_player + "_test1",
                'match_date': test_date,
                'status': test_status,
                'series_id': test_series_id
            }
        )
        print(f"Result 1: {result1}")
    except Exception as e:
        print(f"Error 1: {e}")
    
    # Test 2: Using DATE() function
    print("\n--- Test 2: Using DATE() function ---")
    try:
        result2 = execute_query_one(
            """
            INSERT INTO player_availability 
                (player_name, match_date, availability_status, series_id, updated_at)
            VALUES 
                (%(player_name)s, DATE(%(match_date)s), %(status)s, %(series_id)s, CURRENT_TIMESTAMP)
            ON CONFLICT (player_name, match_date, series_id) 
            DO UPDATE SET 
                availability_status = %(status)s,
                updated_at = CURRENT_TIMESTAMP
            RETURNING id, match_date, updated_at
            """,
            {
                'player_name': test_player + "_test2",
                'match_date': test_date,
                'status': test_status,
                'series_id': test_series_id
            }
        )
        print(f"Result 2: {result2}")
    except Exception as e:
        print(f"Error 2: {e}")
    
    # Test 3: Check timezone
    print("\n--- Test 3: Check database timezone ---")
    try:
        timezone_result = execute_query_one("SELECT current_setting('timezone') as timezone")
        print(f"Database timezone: {timezone_result}")
        
        now_result = execute_query_one("SELECT NOW() as now, CURRENT_DATE as current_date")
        print(f"Database NOW(): {now_result}")
    except Exception as e:
        print(f"Error 3: {e}")
    
    # Clean up test records
    print("\n--- Cleanup ---")
    try:
        execute_query_one(
            "DELETE FROM player_availability WHERE player_name LIKE %(pattern)s",
            {'pattern': test_player + "%"}
        )
        print("Test records cleaned up")
    except Exception as e:
        print(f"Cleanup error: {e}")

if __name__ == "__main__":
    test_date_storage() 
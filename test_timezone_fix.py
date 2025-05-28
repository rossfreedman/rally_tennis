#!/usr/bin/env python3
"""
Test script to verify if timezone environment variables fixed the date issue
"""

import os
import sys
from datetime import datetime, date
import pytz

def test_timezone_settings():
    """Test current timezone settings"""
    print("=== Timezone Environment Test ===")
    
    # Check environment variables
    tz_env = os.getenv('TZ')
    pgtz_env = os.getenv('PGTZ')
    
    print(f"TZ environment variable: {tz_env}")
    print(f"PGTZ environment variable: {pgtz_env}")
    
    # Check system timezone
    try:
        import time
        print(f"System timezone: {time.tzname}")
    except:
        print("Could not determine system timezone")
    
    # Test datetime behavior
    now = datetime.now()
    print(f"Current datetime (naive): {now}")
    
    # Test with Chicago timezone
    chicago_tz = pytz.timezone('America/Chicago')
    chicago_now = datetime.now(chicago_tz)
    print(f"Chicago datetime: {chicago_now}")
    
    # Test date creation
    test_date = date(2025, 5, 26)
    print(f"Test date object: {test_date}")
    
    return tz_env == 'America/Chicago'

def test_date_storage_simulation():
    """Simulate how dates would be stored now"""
    print("\n=== Date Storage Simulation ===")
    
    # Simulate user input: "Monday 5/26/25"
    user_input_date = "2025-05-26"
    
    # Convert to date object
    date_obj = datetime.strptime(user_input_date, '%Y-%m-%d').date()
    print(f"User wants: Monday 5/26/25")
    print(f"Parsed as: {date_obj}")
    print(f"Day of week: {date_obj.strftime('%A')}")
    
    # Check if this matches what user expects
    expected_dow = "Monday"
    actual_dow = date_obj.strftime('%A')
    
    if actual_dow == expected_dow:
        print("✅ Date parsing matches user expectation!")
        return True
    else:
        print(f"❌ Date mismatch: expected {expected_dow}, got {actual_dow}")
        return False

if __name__ == "__main__":
    print("Testing Railway Timezone Fix")
    print("=" * 40)
    
    tz_correct = test_timezone_settings()
    date_correct = test_date_storage_simulation()
    
    print("\n" + "=" * 40)
    if tz_correct and date_correct:
        print("✅ Timezone fix appears to be working!")
        print("Try setting availability to confirm database storage is correct.")
    else:
        print("⚠️ Timezone settings may need adjustment.")
        print("Check that TZ=America/Chicago is set in Railway environment variables.") 
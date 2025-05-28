#!/usr/bin/env python3
"""
Test script to verify timezone environment variable detection
"""

import os
import sys
from datetime import date, timedelta

# Add the project root to Python path
sys.path.insert(0, '/Users/rossfreedman/dev/rally_tennis')

from utils.date_verification import check_railway_date_correction

def test_timezone_detection():
    """Test that our timezone detection works correctly"""
    
    print("=== TESTING TIMEZONE ENVIRONMENT VARIABLE DETECTION ===\n")
    
    # Test date
    test_date = date(2025, 5, 25)
    print(f"Test date: {test_date}")
    
    # Check current environment variables
    tz_env = os.getenv('TZ')
    pgtz_env = os.getenv('PGTZ')
    railway_env = os.getenv('RAILWAY_ENVIRONMENT')
    database_url = os.getenv('DATABASE_URL', '')
    
    print(f"\nCurrent Environment Variables:")
    print(f"  TZ: {tz_env}")
    print(f"  PGTZ: {pgtz_env}")
    print(f"  RAILWAY_ENVIRONMENT: {railway_env}")
    print(f"  DATABASE_URL contains 'railway': {'railway' in database_url}")
    
    # Test the correction function
    print(f"\n=== TESTING check_railway_date_correction ===")
    corrected_date = check_railway_date_correction(test_date)
    
    print(f"Original date: {test_date}")
    print(f"Corrected date: {corrected_date}")
    print(f"Correction applied: {corrected_date != test_date}")
    
    if corrected_date == test_date:
        print("✅ SUCCESS: No correction applied (timezone env vars detected)")
    else:
        print(f"❌ WARNING: Correction applied - {test_date} -> {corrected_date}")
        print("This suggests timezone environment variables are not being detected properly")
    
    return corrected_date == test_date

if __name__ == "__main__":
    success = test_timezone_detection()
    sys.exit(0 if success else 1) 
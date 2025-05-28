#!/usr/bin/env python3
"""
Test script for the date verification system
This tests the conservative approach to fixing date handling issues
"""

import os
import sys
from datetime import datetime, date, timedelta

# Add the project root to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Import our verification utilities
from utils.date_verification import (
    verify_and_fix_date_for_storage,
    verify_date_from_database,
    check_railway_date_correction,
    normalize_date_string,
    format_date_for_display,
    log_date_operation
)

def test_date_normalization():
    """Test date string normalization"""
    print("\n=== Testing Date Normalization ===")
    
    test_cases = [
        "2025-05-26",
        "05/26/2025", 
        "5/26/25",
        "2025/05/26"
    ]
    
    for test_date in test_cases:
        try:
            normalized = normalize_date_string(test_date)
            print(f"✓ {test_date} -> {normalized}")
        except Exception as e:
            print(f"❌ {test_date} -> ERROR: {e}")

def test_storage_verification():
    """Test date verification for storage"""
    print("\n=== Testing Storage Verification ===")
    
    test_date = "2025-05-26"
    intended_display = "Monday 5/26/25"
    
    corrected_date, verification_info = verify_and_fix_date_for_storage(
        input_date=test_date,
        intended_display_date=intended_display
    )
    
    print(f"Input date: {test_date}")
    print(f"Intended display: {intended_display}")
    print(f"Corrected date: {corrected_date}")
    print(f"Verification info: {verification_info}")

def test_retrieval_verification():
    """Test date verification for retrieval"""
    print("\n=== Testing Retrieval Verification ===")
    
    # Simulate Railway storing date one day behind
    stored_date = date(2025, 5, 25)  # One day behind the intended 5/26
    
    display_date, verification_info = verify_date_from_database(
        stored_date=stored_date,
        expected_display_format="Monday 5/26/25"
    )
    
    print(f"Stored date: {stored_date}")
    print(f"Display date: {display_date}")
    print(f"Verification info: {verification_info}")

def test_railway_correction():
    """Test Railway date correction logic"""
    print("\n=== Testing Railway Correction ===")
    
    # Test with Railway environment simulation
    os.environ['DATABASE_URL'] = 'postgresql://user:pass@host.railway.app:5432/db'
    
    test_date = date(2025, 5, 25)
    corrected = check_railway_date_correction(test_date)
    
    print(f"Original date: {test_date}")
    print(f"Corrected date: {corrected}")
    print(f"Correction applied: {corrected != test_date}")
    
    # Clean up
    del os.environ['DATABASE_URL']

def test_display_formatting():
    """Test display formatting"""
    print("\n=== Testing Display Formatting ===")
    
    test_dates = [
        date(2025, 5, 26),
        "2025-05-26",
        datetime(2025, 5, 26, 12, 0, 0)
    ]
    
    for test_date in test_dates:
        formatted = format_date_for_display(test_date)
        print(f"✓ {test_date} -> {formatted}")

def test_real_world_scenario():
    """Test a real-world scenario"""
    print("\n=== Testing Real-World Scenario ===")
    
    print("Scenario: User clicks 'Available' for Monday 5/26/25")
    print("Frontend sends: '2025-05-26'")
    print("Railway stores it as: '2025-05-25' (one day behind)")
    print("We need to detect and correct this...")
    
    # Step 1: User input processing
    frontend_date = "2025-05-26"
    user_sees = "Monday 5/26/25"
    
    corrected_for_storage, storage_info = verify_and_fix_date_for_storage(
        input_date=frontend_date,
        intended_display_date=user_sees
    )
    
    print(f"\n1. Storage Verification:")
    print(f"   Frontend sent: {frontend_date}")
    print(f"   User sees: {user_sees}")
    print(f"   Corrected for storage: {corrected_for_storage}")
    print(f"   Correction applied: {storage_info.get('correction_applied')}")
    
    # Step 2: Simulate Railway storing it wrong (for testing)
    # In reality, this would be handled by the database layer
    simulated_stored_date = date(2025, 5, 25)  # Railway bug: one day behind
    
    print(f"\n2. Simulated Railway Storage:")
    print(f"   What we tried to store: {corrected_for_storage}")
    print(f"   What Railway actually stored: {simulated_stored_date}")
    
    # Step 3: Retrieval and display correction
    display_date, retrieval_info = verify_date_from_database(
        stored_date=simulated_stored_date
    )
    
    print(f"\n3. Retrieval Verification:")
    print(f"   Retrieved from DB: {simulated_stored_date}")
    print(f"   Corrected for display: {display_date}")
    print(f"   Correction applied: {retrieval_info.get('correction_applied')}")
    
    # Step 4: Final verification
    print(f"\n4. Final Result:")
    print(f"   User originally saw: {user_sees}")
    print(f"   User now sees: {display_date}")
    print(f"   Consistent? {user_sees == display_date}")

if __name__ == "__main__":
    print("Date Verification System Test")
    print("=" * 50)
    
    try:
        test_date_normalization()
        test_storage_verification()
        test_retrieval_verification()
        test_railway_correction()
        test_display_formatting()
        test_real_world_scenario()
        
        print("\n" + "=" * 50)
        print("✅ All tests completed!")
        print("\nTo test this in your app:")
        print("1. Deploy the changes to Railway")
        print("2. Set your availability for a specific date")
        print("3. Check the logs to see the verification process")
        print("4. Verify the date displays correctly on the team schedule page")
        
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        import traceback
        traceback.print_exc() 
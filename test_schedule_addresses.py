#!/usr/bin/env python3
"""
Test script to verify schedule addresses are working correctly
"""

import os
import sys
from routes.act.schedule import get_matches_for_user_club

def test_schedule_addresses():
    """Test that schedule addresses are working correctly"""
    
    print("🧪 Testing schedule addresses...")
    
    # Create a test user (similar to the one having the issue)
    test_user = {
        'club': 'Tennaqua',
        'series': 'Series 2B',
        'email': 'test@example.com'
    }
    
    print(f"Testing with user: {test_user}")
    
    # Get matches for the user
    matches = get_matches_for_user_club(test_user)
    
    print(f"\nFound {len(matches)} matches/events")
    
    # Check each match for address information
    for i, match in enumerate(matches[:5]):  # Check first 5 matches
        print(f"\nMatch {i+1}:")
        print(f"  Date: {match.get('date')}")
        print(f"  Location: {match.get('location')}")
        print(f"  Location Address: {match.get('location_address')}")
        
        if match.get('location_address'):
            print(f"  ✅ Address found: {match['location_address']}")
        else:
            print(f"  ❌ No address found for location: {match.get('location')}")
            
        if match.get('type') == 'match':
            print(f"  Teams: {match.get('home_team')} vs {match.get('away_team')}")
        else:
            print(f"  Type: {match.get('type', 'Unknown')}")
    
    # Check specifically for Ravinia Green matches
    ravinia_matches = [m for m in matches if 'Ravinia' in str(m.get('location', ''))]
    if ravinia_matches:
        print(f"\n🎾 Found {len(ravinia_matches)} Ravinia Green matches:")
        for match in ravinia_matches:
            print(f"  Location: {match.get('location')}")
            print(f"  Address: {match.get('location_address')}")
            if match.get('location_address'):
                print(f"  ✅ Ravinia Green address working!")
            else:
                print(f"  ❌ Ravinia Green address missing!")
    else:
        print("\n⚠️  No Ravinia Green matches found in test data")

if __name__ == "__main__":
    test_schedule_addresses() 
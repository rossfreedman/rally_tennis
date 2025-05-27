#!/usr/bin/env python3

import os
import sys
import json
from database_utils import execute_query

def test_club_addresses():
    """Test script to debug club address lookup"""
    
    print("=== Testing Club Address Lookup ===")
    
    # Get club addresses from database
    try:
        clubs = execute_query("SELECT name, address FROM clubs")
        print(f"\nFound {len(clubs)} clubs in database:")
        for club in clubs:
            print(f"  '{club['name']}' -> '{club['address']}'")
        
        club_addresses = {}
        for club in clubs:
            club_addresses[club['name']] = club['address']
            
    except Exception as e:
        print(f"Error loading club addresses: {e}")
        return
    
    # Load schedule data to see what locations are used
    try:
        schedule_path = os.path.join('data', 'schedules.json')
        with open(schedule_path, 'r') as f:
            all_matches = json.load(f)
        
        print(f"\nFound {len(all_matches)} entries in schedules.json")
        
        # Get unique locations
        locations = set()
        for match in all_matches:
            location = match.get('location', '')
            if location:
                locations.add(location)
        
        print(f"\nUnique locations in schedules.json:")
        for location in sorted(locations):
            print(f"  '{location}'")
        
        # Test address lookup for each location
        print(f"\nTesting address lookup:")
        
        def get_club_address(location):
            """Get the address for a club location"""
            if not location:
                return None
            
            # Try exact match first
            if location in club_addresses:
                return club_addresses[location]
            
            # Try to extract club name from location (remove extra text)
            location_clean = location.strip()
            for club_name in club_addresses:
                if club_name.lower() in location_clean.lower():
                    return club_addresses[club_name]
            
            return None
        
        for location in sorted(locations):
            address = get_club_address(location)
            print(f"  '{location}' -> {address if address else 'NO MATCH'}")
            
    except Exception as e:
        print(f"Error loading schedule data: {e}")

if __name__ == "__main__":
    test_club_addresses() 
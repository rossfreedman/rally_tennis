#!/usr/bin/env python3
"""
Debug club addresses issue
This script checks the current state of club addresses in the database
"""

import os
import sys
from utils.db import execute_query

def debug_club_addresses():
    """Debug the club addresses issue"""
    
    print("🔍 Debugging club addresses issue...")
    
    # Check if address column exists
    print("\n1. Checking if address column exists...")
    try:
        result = execute_query("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'clubs' AND column_name = 'address'
        """)
        
        if result:
            col_info = result[0]
            print(f"   ✅ Address column exists: {col_info['data_type']}, nullable: {col_info['is_nullable']}")
        else:
            print("   ❌ Address column does NOT exist")
            return
            
    except Exception as e:
        print(f"   ❌ Error checking address column: {e}")
        return
    
    # Check all clubs and their addresses
    print("\n2. Checking all clubs and their addresses...")
    try:
        clubs = execute_query("SELECT id, name, address FROM clubs ORDER BY name")
        
        clubs_with_address = 0
        clubs_without_address = 0
        
        print(f"   Found {len(clubs)} clubs total:")
        
        for club in clubs:
            if club['address']:
                clubs_with_address += 1
                print(f"   ✅ {club['name']}: {club['address']}")
            else:
                clubs_without_address += 1
                print(f"   ❌ {club['name']}: NO ADDRESS")
        
        print(f"\n   Summary:")
        print(f"   - Clubs with addresses: {clubs_with_address}")
        print(f"   - Clubs without addresses: {clubs_without_address}")
        
    except Exception as e:
        print(f"   ❌ Error checking clubs: {e}")
        return
    
    # Check specific clubs mentioned in the issue
    print("\n3. Checking specific clubs from the issue...")
    specific_clubs = ['Ravinia Green', 'Tennaqua']
    
    for club_name in specific_clubs:
        try:
            club = execute_query("SELECT id, name, address FROM clubs WHERE name = %s", (club_name,))
            if club:
                club_data = club[0]
                if club_data['address']:
                    print(f"   ✅ {club_name}: {club_data['address']}")
                else:
                    print(f"   ❌ {club_name}: NO ADDRESS (this is the problem!)")
            else:
                print(f"   ⚠️  {club_name}: Club not found in database")
        except Exception as e:
            print(f"   ❌ Error checking {club_name}: {e}")
    
    # Test the address lookup function
    print("\n4. Testing address lookup function...")
    try:
        from routes.act.schedule import get_matches_for_user_club
        
        # Simulate the code that's failing
        club_addresses = {}
        clubs = execute_query("SELECT name, address FROM clubs")
        for club in clubs:
            club_addresses[club['name']] = club['address']
        
        print(f"   Loaded {len(club_addresses)} club addresses into lookup dict")
        
        # Test specific lookups
        test_clubs = ['Ravinia Green', 'Tennaqua']
        for club_name in test_clubs:
            address = club_addresses.get(club_name)
            if address:
                print(f"   ✅ {club_name} lookup: {address}")
            else:
                print(f"   ❌ {club_name} lookup: None (this causes the issue!)")
                
    except Exception as e:
        print(f"   ❌ Error testing lookup function: {e}")

if __name__ == "__main__":
    debug_club_addresses() 
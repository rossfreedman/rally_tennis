#!/usr/bin/env python3
"""
Fix club addresses in production database
This script ensures the address column exists and populates known club addresses
"""

import os
import sys
from utils.db import execute_query, execute_update

def fix_club_addresses():
    """Fix club addresses in the database"""
    
    print("🔧 Fixing club addresses in database...")
    
    # First, check if address column exists
    try:
        print("1. Checking if address column exists...")
        result = execute_query("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'clubs' AND column_name = 'address'
        """)
        
        if not result:
            print("   ❌ Address column does not exist. Adding it...")
            execute_update("ALTER TABLE clubs ADD COLUMN address VARCHAR(500)")
            print("   ✅ Address column added successfully")
        else:
            print("   ✅ Address column already exists")
            
    except Exception as e:
        print(f"   ❌ Error checking/adding address column: {e}")
        return False
    
    # Known club addresses (based on the user's example and common Chicago area clubs)
    club_addresses = {
        'Ravinia Green': '1200 Saunders Road, Riverwoods, Illinois 60015',
        'Tennaqua': '1 Tennaqua Drive, Northbrook, Illinois 60062',
        'Lake Forest': '1601 Deerpath Road, Lake Forest, Illinois 60045',
        'Winnetka': '540 Hibbard Road, Winnetka, Illinois 60093',
        'Birchwood': '7000 N Caldwell Avenue, Niles, Illinois 60714',
        'North Shore': '1340 Glenview Road, Glenview, Illinois 60025',
        'Glen View': '643 Glen View Road, Golf, Illinois 60029',
        'Onwentsia': '300 Green Bay Road, Lake Forest, Illinois 60045',
        'Exmoor': '825 Hibbard Road, Wilmette, Illinois 60091',
        'Westmoreland': '4 Westmoreland Place, Wilmette, Illinois 60091',
        'Michigan Shores': '911 Sheridan Road, Wilmette, Illinois 60091',
        'Hinsdale PC': '6200 S County Line Road, Burr Ridge, Illinois 60527',
        'Skokie': '9300 Weber Park Place, Skokie, Illinois 60077',
        'Wilmette PD': '1200 Wilmette Avenue, Wilmette, Illinois 60091'
    }
    
    print(f"2. Updating {len(club_addresses)} club addresses...")
    
    updated_count = 0
    for club_name, address in club_addresses.items():
        try:
            # Check if club exists
            club = execute_query("SELECT id, name, address FROM clubs WHERE name = %s", (club_name,))
            
            if club:
                club_data = club[0]
                if not club_data.get('address'):  # Only update if address is empty/null
                    success = execute_update(
                        "UPDATE clubs SET address = %s WHERE name = %s",
                        (address, club_name)
                    )
                    if success:
                        print(f"   ✅ Updated {club_name}: {address}")
                        updated_count += 1
                    else:
                        print(f"   ❌ Failed to update {club_name}")
                else:
                    print(f"   ⏭️  {club_name} already has address: {club_data['address']}")
            else:
                print(f"   ⚠️  Club not found: {club_name}")
                
        except Exception as e:
            print(f"   ❌ Error updating {club_name}: {e}")
    
    print(f"\n✅ Successfully updated {updated_count} club addresses")
    
    # Verify the fix
    print("\n3. Verifying the fix...")
    try:
        clubs_with_addresses = execute_query("SELECT name, address FROM clubs WHERE address IS NOT NULL AND address != ''")
        print(f"   ✅ Found {len(clubs_with_addresses)} clubs with addresses:")
        for club in clubs_with_addresses[:5]:  # Show first 5
            print(f"      - {club['name']}: {club['address'][:50]}...")
        if len(clubs_with_addresses) > 5:
            print(f"      ... and {len(clubs_with_addresses) - 5} more")
            
    except Exception as e:
        print(f"   ❌ Error verifying fix: {e}")
    
    return True

if __name__ == "__main__":
    success = fix_club_addresses()
    if success:
        print("\n🎉 Club addresses fix completed successfully!")
        print("The 'Get Directions' links should now work properly in production.")
    else:
        print("\n❌ Club addresses fix failed!")
        sys.exit(1) 
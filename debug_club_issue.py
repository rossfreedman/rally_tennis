#!/usr/bin/env python3

import requests
import json

def debug_club_issue():
    """Debug the club filtering issue"""
    
    base_url = "http://127.0.0.1:8080"
    
    print("=== Debugging Club Filtering Issue ===\n")
    
    # Create a session to maintain cookies
    session = requests.Session()
    
    print("1. Testing lineup page access...")
    try:
        response = session.get(f"{base_url}/mobile/lineup")
        print(f"   Status: {response.status_code}")
        
        if response.status_code == 200:
            print("   ✓ Lineup page accessible")
            
            # Check if we can see any players in the response
            if "Mark Gantner" in response.text or "RICKY BARNETT" in response.text:
                print("   ⚠️  WARNING: Ravinia Green players found in response!")
            else:
                print("   ✓ No Ravinia Green players found in response")
                
        elif response.status_code == 302:
            print("   → Redirected (likely to login)")
            print("   This means authentication is required")
        else:
            print(f"   ✗ Unexpected status: {response.status_code}")
            
    except Exception as e:
        print(f"   ✗ Error: {e}")
    
    print("\n2. Checking what clubs exist in players.json...")
    try:
        with open('data/players.json', 'r') as f:
            players = json.load(f)
        
        clubs = sorted(list(set(player['Club'] for player in players)))
        print(f"   Found {len(clubs)} clubs:")
        for club in clubs:
            print(f"     - {club}")
            
        # Count players per club
        print(f"\n   Players per club:")
        club_counts = {}
        for player in players:
            club = player['Club']
            club_counts[club] = club_counts.get(club, 0) + 1
            
        for club, count in sorted(club_counts.items()):
            print(f"     - {club}: {count} players")
            
    except Exception as e:
        print(f"   ✗ Error reading players.json: {e}")
    
    print("\n=== Summary ===")
    print("The issue is likely one of these:")
    print("1. User's club in session doesn't match any club in players.json")
    print("2. User's club in session is empty/null")
    print("3. There's a bug in the filtering logic")
    print("\nTo fix this, we need to:")
    print("1. Ensure user has a valid club in their session")
    print("2. Make sure that club exists in players.json")
    print("3. Verify the filtering logic works correctly")

if __name__ == "__main__":
    debug_club_issue() 
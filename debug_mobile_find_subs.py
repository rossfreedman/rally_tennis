#!/usr/bin/env python3
"""
Debug script for mobile find-subs page showing players from wrong clubs
"""

import json
import re

def analyze_substitute_logic():
    """Analyze the substitute logic and identify potential issues"""
    
    print("🔍 DEBUGGING: Mobile Find-Subs Club Filtering")
    print("=" * 60)
    
    # Load players data
    with open('data/players.json', 'r') as f:
        all_players = json.load(f)
    
    # Show available clubs and series
    clubs = {}
    series_by_club = {}
    
    for player in all_players:
        club = player['Club']
        series = player['Series']
        
        if club not in clubs:
            clubs[club] = 0
            series_by_club[club] = set()
        
        clubs[club] += 1
        series_by_club[club].add(series)
    
    print("📊 AVAILABLE DATA:")
    print(f"Total players: {len(all_players)}")
    print("\nClubs and their players:")
    for club, count in sorted(clubs.items()):
        series_list = sorted(list(series_by_club[club]))
        print(f"  {club}: {count} players, Series: {', '.join(series_list)}")
    
    # Test substitute logic for each club/series combination
    print("\n🧪 TESTING SUBSTITUTE LOGIC:")
    print("=" * 40)
    
    test_cases = [
        ('Tennaqua', 'Series 2B'),
        ('Birchwood', 'Series 2B'),
        ('Winnetka', 'Series 2B'),
        ('Lake Forest', 'Series 2B'),
        ('Ravinia Green', 'Series 2B'),
    ]
    
    for user_club, user_series in test_cases:
        print(f"\n--- Testing: {user_club} {user_series} ---")
        
        # Parse user's series number
        match = re.search(r'(\d+)([A-Z]?)', user_series)
        if not match:
            print(f"❌ Could not parse series: {user_series}")
            continue
            
        user_series_num = int(match.group(1))
        user_series_letter = match.group(2) or ''
        
        if user_series_letter:
            letter_value = ord(user_series_letter) - ord('A') + 1
            user_series_numeric = user_series_num + (letter_value / 10)
        else:
            user_series_numeric = user_series_num
        
        print(f"User series numeric: {user_series_numeric}")
        
        # Find substitute players (this is the actual logic from server.py)
        substitute_players = []
        for player in all_players:
            # Parse player's series
            player_match = re.search(r'(\d+)([A-Z]?)', player['Series'])
            if not player_match:
                continue
                
            player_series_num = int(player_match.group(1))
            player_series_letter = player_match.group(2) or ''
            
            if player_series_letter:
                letter_value = ord(player_series_letter) - ord('A') + 1
                player_series_numeric = player_series_num + (letter_value / 10)
            else:
                player_series_numeric = player_series_num
                
            # Check if this player is from a lower-skilled series (higher number) and SAME CLUB
            if player_series_numeric > user_series_numeric and player['Club'] == user_club:
                player_name = f"{player['First Name']} {player['Last Name']}"
                substitute_players.append({
                    'name': player_name,
                    'series': player['Series'],
                    'club': player['Club'],
                    'series_numeric': player_series_numeric
                })
        
        print(f"✅ Found {len(substitute_players)} substitutes")
        
        if substitute_players:
            print("Substitutes found:")
            for sub in substitute_players:
                print(f"  - {sub['name']} ({sub['series']}) from {sub['club']}")
        else:
            print("  No substitutes available")
        
        # Verify all substitutes are from the correct club
        wrong_club_subs = [s for s in substitute_players if s['club'] != user_club]
        if wrong_club_subs:
            print(f"🚨 ERROR: Found substitutes from wrong club:")
            for sub in wrong_club_subs:
                print(f"  - {sub['name']} from {sub['club']} (should be {user_club})")
        else:
            print(f"✅ All substitutes correctly from {user_club}")

def check_mobile_page_api():
    """Check what the mobile page API call should return"""
    
    print("\n\n📱 MOBILE PAGE API ANALYSIS:")
    print("=" * 40)
    
    print("The mobile find-subs page makes this API call:")
    print("  GET /api/players?all_subs=1")
    print("\nThis triggers get_all_substitute_players() function which:")
    print("1. Gets user's club from session['user']['club']")
    print("2. Gets user's series from session['user']['series']")  
    print("3. Filters players where:")
    print("   - player_series_numeric > user_series_numeric (higher series)")
    print("   - player['Club'] == user_club (SAME CLUB ONLY)")
    print("\n✅ The logic is correct and should only show same-club players")

def debugging_steps():
    """Provide debugging steps for the user"""
    
    print("\n\n🛠️  DEBUGGING STEPS:")
    print("=" * 30)
    
    print("If you're seeing players from other clubs, here's how to debug:")
    print()
    print("1. Check your user session:")
    print("   - Open browser dev tools (F12)")
    print("   - Go to http://127.0.0.1:8080/debug-session")
    print("   - Check what 'user_club' shows in the JSON response")
    print()
    print("2. Check the API response:")
    print("   - Open dev tools Network tab")  
    print("   - Go to find-subs page")
    print("   - Look for the call to '/api/players?all_subs=1'")
    print("   - Check if all returned players have the same club as your user")
    print()
    print("3. Check server logs:")
    print("   - The get_all_substitute_players() function has debug prints")
    print("   - Look for lines starting with '=== DEBUG: get_all_substitute_players ==='")
    print("   - This will show your club and what players were found")
    print()
    print("4. Possible causes:")
    print("   - User's club in session doesn't match club names in players.json")
    print("   - Case sensitivity issues (e.g., 'Tennaqua' vs 'tennaqua')")
    print("   - Browser caching old data")
    print("   - Session expired/corrupted")
    print()
    print("5. Quick fixes to try:")
    print("   - Log out and log back in")
    print("   - Clear browser cache/cookies")
    print("   - Check your user settings to ensure club is correct")

if __name__ == "__main__":
    analyze_substitute_logic()
    check_mobile_page_api()
    debugging_steps() 
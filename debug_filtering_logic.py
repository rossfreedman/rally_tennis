#!/usr/bin/env python3

import json
import re
import os
from utils.series_matcher import series_match, normalize_series_for_storage

def debug_filtering_logic():
    """Debug the exact filtering logic used in the /api/players endpoint"""
    
    print("🔍 Debugging Player Filtering Logic")
    print("=" * 60)
    
    # Simulate the user's session data
    user_series = "tennaqua series 2B"
    user_club = "Tennaqua"
    
    print(f"User series: '{user_series}'")
    print(f"User club: '{user_club}'")
    print()
    
    # Load the actual players data
    players_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data', 'players.json')
    with open(players_path, 'r') as f:
        all_players = json.load(f)
    
    # Test the filtering logic on specific problematic players
    problematic_players = [
        "Mark Gantner",
        "RICKY BARNETT", 
        "JAVI CAPELLA",
        "MIKE CARUSO"
    ]
    
    print("Testing problematic players:")
    print("-" * 40)
    
    for target_name in problematic_players:
        # Find this player in the data
        found_player = None
        for player in all_players:
            player_name = f"{player['First Name']} {player['Last Name']}"
            if player_name == target_name:
                found_player = player
                break
        
        if found_player:
            print(f"\n🔍 Testing: {target_name}")
            print(f"   Player series: '{found_player['Series']}'")
            print(f"   Player club: '{found_player['Club']}'")
            
            # Test the exact filtering logic from server.py
            player_series = found_player['Series']
            
            # Test 1: Exact series match
            series_matches_exactly = series_match(player_series, user_series)
            print(f"   Exact series match: {series_matches_exactly}")
            
            # Test 2: Series suffix match (the problematic logic)
            series_suffix_match = False
            if not series_matches_exactly:
                player_series_match = re.search(r'Series\s+(\w+)', player_series)
                user_series_match = re.search(r'(\w+)$', user_series)
                
                if player_series_match and user_series_match:
                    player_series_id = player_series_match.group(1)
                    user_series_id = user_series_match.group(1)
                    series_suffix_match = player_series_id.lower() == user_series_id.lower()
                    
                    print(f"   Player series ID: '{player_series_id}'")
                    print(f"   User series ID: '{user_series_id}'")
                    print(f"   Series suffix match: {series_suffix_match}")
            
            # Test 3: Club match
            club_matches = found_player['Club'] == user_club
            print(f"   Club match: {club_matches}")
            
            # Final result
            would_be_included = (series_matches_exactly or series_suffix_match) and club_matches
            print(f"   ❌ WOULD BE INCLUDED: {would_be_included}")
            
            if would_be_included and found_player['Series'] != 'Series 2B':
                print(f"   🚨 BUG: This player should NOT be included!")
        else:
            print(f"\n❌ Player '{target_name}' not found in data")
    
    print("\n" + "=" * 60)
    print("Testing correct Series 2B Tennaqua players:")
    print("-" * 40)
    
    # Test some Series 2B Tennaqua players to make sure they WOULD be included
    correct_players = []
    for player in all_players:
        if player['Series'] == 'Series 2B' and player['Club'] == 'Tennaqua':
            player_name = f"{player['First Name']} {player['Last Name']}"
            correct_players.append((player_name, player))
            if len(correct_players) >= 3:  # Test first 3
                break
    
    for player_name, player in correct_players:
        print(f"\n✅ Testing: {player_name}")
        print(f"   Player series: '{player['Series']}'")
        print(f"   Player club: '{player['Club']}'")
        
        # Test the filtering logic
        player_series = player['Series']
        series_matches_exactly = series_match(player_series, user_series)
        
        series_suffix_match = False
        if not series_matches_exactly:
            player_series_match = re.search(r'Series\s+(\w+)', player_series)
            user_series_match = re.search(r'(\w+)$', user_series)
            
            if player_series_match and user_series_match:
                player_series_id = player_series_match.group(1)
                user_series_id = user_series_match.group(1)
                series_suffix_match = player_series_id.lower() == user_series_id.lower()
        
        club_matches = player['Club'] == user_club
        would_be_included = (series_matches_exactly or series_suffix_match) and club_matches
        
        print(f"   Exact series match: {series_matches_exactly}")
        print(f"   Series suffix match: {series_suffix_match}")
        print(f"   Club match: {club_matches}")
        print(f"   ✅ WOULD BE INCLUDED: {would_be_included}")
        
        if not would_be_included:
            print(f"   🚨 BUG: This player SHOULD be included!")

if __name__ == "__main__":
    debug_filtering_logic() 
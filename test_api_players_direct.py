#!/usr/bin/env python3

import json
import os
import re
from utils.series_matcher import series_match, normalize_series_for_storage

def test_api_players_logic():
    """Test the exact logic from /api/players endpoint"""
    
    print("🧪 Testing /api/players filtering logic directly")
    print("=" * 60)
    
    # Simulate the parameters that would come from the frontend
    series = "tennaqua series 2B"  # This is what the frontend would send
    user_club = "Tennaqua"  # This is what should be in the session
    
    print(f"Input parameters:")
    print(f"  series: '{series}'")
    print(f"  user_club: '{user_club}'")
    print()
    
    # Load player data (same as server)
    players_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data', 'players.json')
    with open(players_path, 'r') as f:
        all_players = json.load(f)
    
    # Simulate the exact filtering logic from server.py
    players = []
    players_checked = 0
    series_matches = 0
    club_matches = 0
    
    print("Processing players...")
    print("-" * 40)
    
    for player in all_players:
        players_checked += 1
        
        # More flexible series matching - check both exact match and normalized match
        player_series = player['Series']
        series_matches_exactly = series_match(player_series, series)
        
        # Also try matching just the series part (e.g., "Series 2B" matches "tennaqua series 2B")
        series_suffix_match = False
        if not series_matches_exactly:
            # Extract the series identifier (e.g., "2B" from "Series 2B")
            player_series_match = re.search(r'Series\s+(\w+)', player_series)
            user_series_match = re.search(r'(\w+)$', series)  # Get last word
            
            if player_series_match and user_series_match:
                player_series_id = player_series_match.group(1)
                user_series_id = user_series_match.group(1)
                series_suffix_match = player_series_id.lower() == user_series_id.lower()
                
                if series_suffix_match:
                    print(f"SERIES SUFFIX MATCH: '{player_series}' matches '{series}' (player_id='{player_series_id}', user_id='{user_series_id}')")
        
        if series_matches_exactly or series_suffix_match:
            series_matches += 1
            # Create player name in the same format as match data
            player_name = f"{player['First Name']} {player['Last Name']}"
            
            # Only include players from the same club as the user
            player_club = player['Club']
            
            if player['Club'] == user_club:
                club_matches += 1
                print(f"INCLUDED: {player_name} - Series: '{player['Series']}', Club: '{player['Club']}'")
                player_data = {
                    'name': player_name,
                    'series': normalize_series_for_storage(player['Series']),  # Normalize series format
                    'rating': str(player['PTI']),
                    'wins': str(player['Wins']),
                    'losses': str(player['Losses']),
                    'winRate': player['Win %']
                }
                players.append(player_data)
    
    print(f"\nDEBUG SUMMARY: Checked {players_checked} players, {series_matches} matched series, {club_matches} matched club")
    print(f"Found {len(players)} players in {series} and club {user_club}")
    
    print(f"\nFinal player list:")
    print("-" * 40)
    for i, player in enumerate(players, 1):
        print(f"{i:2d}. {player['name']} (Series: {player['series']})")
    
    # Check if any of the problematic players are in the list
    problematic_names = ["Mark Gantner", "RICKY BARNETT", "JAVI CAPELLA", "MIKE CARUSO"]
    found_problematic = [p for p in players if p['name'] in problematic_names]
    
    if found_problematic:
        print(f"\n🚨 PROBLEM: Found {len(found_problematic)} problematic players:")
        for p in found_problematic:
            print(f"   - {p['name']}")
    else:
        print(f"\n✅ Good: No problematic players found in results")
    
    return players

if __name__ == "__main__":
    test_api_players_logic() 
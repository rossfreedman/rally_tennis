#!/usr/bin/env python3

import json
import os
from utils.series_matcher import series_match

def test_actual_api_call():
    """
    Simulate the exact API call that would be made from the lineup page
    """
    print("=== TESTING ACTUAL API CALL SIMULATION ===")
    
    # Simulate the session data from your user record
    session_user = {
        'club': 'Tennaqua',
        'series': 'Series 2B'  # This comes from the database
    }
    
    # Simulate the request parameters
    series = session_user['series']  # "Series 2B"
    user_club = session_user['club']  # "Tennaqua"
    
    print(f"Request series: '{series}'")
    print(f"User club: '{user_club}'")
    
    # Load player data (same as the API endpoint)
    players_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data', 'players.json')
    with open(players_path, 'r') as f:
        all_players = json.load(f)
    
    # Debug: Show available clubs in players.json
    available_clubs = list(set(player['Club'] for player in all_players))
    print(f"Available clubs in players.json: {sorted(available_clubs)}")
    print(f"User's club: '{user_club}' - Is it in available clubs? {user_club in available_clubs}")
    
    # Filter players using the EXACT same logic as the API endpoint
    players = []
    players_checked = 0
    series_matches = 0
    club_matches = 0
    
    print(f"\n=== FILTERING LOGIC ===")
    
    for player in all_players:
        players_checked += 1
        
        # More flexible series matching - check both exact match and normalized match
        player_series = player['Series']
        series_matches_exactly = series_match(player_series, series)
        
        # Also try matching just the series part (e.g., "Series 2B" matches "tennaqua series 2B")
        series_suffix_match = False
        if not series_matches_exactly:
            # Extract the series identifier (e.g., "2B" from "Series 2B")
            import re
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
                players.append(player_name)
            else:
                # Only log first few mismatches to avoid spam
                if club_matches < 5:
                    print(f"EXCLUDED {player_name} - club mismatch: '{player_club}' != '{user_club}'")
    
    print(f"\n=== RESULTS ===")
    print(f"Checked {players_checked} players")
    print(f"{series_matches} matched series")
    print(f"{club_matches} matched club")
    print(f"Final result: {len(players)} players")
    
    if players:
        print(f"\nFirst 10 players that would be returned:")
        for i, player in enumerate(players[:10]):
            print(f"  {i+1}. {player}")
    else:
        print("\nNO PLAYERS RETURNED!")
        
        # Debug: Let's see what Series 2B Tennaqua players exist
        print(f"\nDEBUG: Looking for Series 2B Tennaqua players...")
        for player in all_players:
            if player['Club'] == 'Tennaqua' and player['Series'] == 'Series 2B':
                player_name = f"{player['First Name']} {player['Last Name']}"
                print(f"  Found: {player_name}")

if __name__ == '__main__':
    test_actual_api_call() 
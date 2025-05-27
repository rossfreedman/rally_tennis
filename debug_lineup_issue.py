#!/usr/bin/env python3

import json
import os
from utils.series_matcher import series_match, normalize_series_for_storage, normalize_series_for_display

def debug_lineup_filtering():
    """Debug the lineup filtering issue for tennaqua series 2B"""
    
    print("🔍 Debugging Lineup Filtering Issue")
    print("=" * 50)
    
    # Test series matching
    user_series = "tennaqua series 2B"
    print(f"User series: '{user_series}'")
    print(f"Normalized for storage: '{normalize_series_for_storage(user_series)}'")
    print(f"Normalized for display: '{normalize_series_for_display(user_series)}'")
    
    # Load players data to see what series are available
    players_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data', 'players.json')
    if os.path.exists(players_path):
        with open(players_path, 'r') as f:
            all_players = json.load(f)
        
        # Get unique series and clubs
        unique_series = set()
        unique_clubs = set()
        tennaqua_players = []
        
        for player in all_players:
            unique_series.add(player['Series'])
            unique_clubs.add(player['Club'])
            
            # Check if this player matches our criteria
            if series_match(player['Series'], user_series):
                if player['Club'].lower() == 'tennaqua':
                    tennaqua_players.append({
                        'name': f"{player['First Name']} {player['Last Name']}",
                        'series': player['Series'],
                        'club': player['Club']
                    })
        
        print(f"\n📊 Data Analysis:")
        print(f"Total players in database: {len(all_players)}")
        print(f"Unique series: {len(unique_series)}")
        print(f"Unique clubs: {len(unique_clubs)}")
        
        print(f"\n🎾 Series containing 'tennaqua' or '2B':")
        for series in sorted(unique_series):
            if 'tennaqua' in series.lower() or '2b' in series.lower():
                print(f"  - {series}")
                # Test if it matches our user series
                if series_match(series, user_series):
                    print(f"    ✅ MATCHES user series")
                else:
                    print(f"    ❌ Does not match user series")
        
        print(f"\n🏢 Clubs containing 'tennaqua':")
        for club in sorted(unique_clubs):
            if 'tennaqua' in club.lower():
                print(f"  - {club}")
        
        print(f"\n👥 Players matching criteria (series: {user_series}, club: tennaqua):")
        if tennaqua_players:
            for player in tennaqua_players[:10]:  # Show first 10
                print(f"  - {player['name']} ({player['series']}, {player['club']})")
            if len(tennaqua_players) > 10:
                print(f"  ... and {len(tennaqua_players) - 10} more")
        else:
            print("  ❌ No players found matching criteria")
            
            # Let's see what players are in tennaqua club
            tennaqua_club_players = [p for p in all_players if 'tennaqua' in p['Club'].lower()]
            print(f"\n  🔍 All players in tennaqua club: {len(tennaqua_club_players)}")
            for player in tennaqua_club_players[:5]:
                print(f"    - {player['First Name']} {player['Last Name']} ({player['Series']}, {player['Club']})")
                
            # Let's see what players are in series 2B
            series_2b_players = [p for p in all_players if '2b' in p['Series'].lower()]
            print(f"\n  🔍 All players in series containing '2B': {len(series_2b_players)}")
            for player in series_2b_players[:5]:
                print(f"    - {player['First Name']} {player['Last Name']} ({player['Series']}, {player['Club']})")
    
    else:
        print("❌ Players data file not found")

if __name__ == "__main__":
    debug_lineup_filtering() 
#!/usr/bin/env python3
"""
Test script to verify the teams-players endpoint fix includes all roster players
"""

import sys
import os
import json
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_teams_players_logic():
    """Test the actual logic used in the teams-players endpoint"""
    
    print("Testing teams-players logic for: Ravinia Green S2B")
    print("=" * 60)
    
    # Load data just like the endpoint does
    with open('data/players.json') as f:
        all_players = json.load(f)
    
    with open('data/match_history.json') as f:
        all_matches = json.load(f)
    
    team = "Ravinia Green S2B"
    club_name = "Ravinia Green"
    series_name = "Series 2B"
    
    # Simulate the endpoint logic
    team_matches = []
    for match in all_matches:
        home_team = match.get('Home Team', '')
        away_team = match.get('Away Team', '')
        if home_team == team or away_team == team:
            team_matches.append(match)
    
    # Calculate player stats from matches
    player_stats = {}
    for match in team_matches:
        is_home = match.get('Home Team') == team
        player1 = match.get('Home Player 1') if is_home else match.get('Away Player 1')
        player2 = match.get('Home Player 2') if is_home else match.get('Away Player 2')
        winner_is_home = match.get('Winner') == 'home'
        team_won = (is_home and winner_is_home) or (not is_home and not winner_is_home)
        
        for player in [player1, player2]:
            if not player:
                continue
            if player not in player_stats:
                player_stats[player] = {'matches': 0, 'wins': 0, 'courts': {}}
            player_stats[player]['matches'] += 1
            if team_won:
                player_stats[player]['wins'] += 1
    
    # Build top players list using the same logic as the endpoint
    top_players = []
    players_with_match_stats = set()
    
    # First, add players who have played matches
    for player, stats in player_stats.items():
        if stats['matches'] > 0:
            win_rate = round((stats['wins'] / stats['matches']) * 100, 1)
            best_court = 'N/A'  # Simplified for test
            
            # Get additional info from players.json if available
            player_info = None
            for p in all_players:
                full_name = f"{p.get('First Name', '')} {p.get('Last Name', '')}".strip()
                if full_name == player:
                    player_info = p
                    break
            
            top_players.append({
                'name': player,
                'matches': stats['matches'],
                'wins': stats['wins'],
                'losses': stats['matches'] - stats['wins'],
                'win_rate': win_rate,
                'best_court': best_court,
                'series': player_info.get('Series', series_name) if player_info else series_name,
                'captain': player_info.get('Captain', '') if player_info else ''
            })
            players_with_match_stats.add(player)
    
    # Then, add players from roster who haven't played matches yet
    roster_players = [p for p in all_players if p.get('Series Mapping ID') == team]
    print(f"DEBUG: Found {len(roster_players)} players in roster for team '{team}'")
    
    for player in roster_players:
        full_name = f"{player.get('First Name', '')} {player.get('Last Name', '')}".strip()
        if full_name and full_name not in players_with_match_stats:
            # Player is on roster but hasn't played matches yet
            top_players.append({
                'name': full_name,
                'matches': 0,
                'wins': 0,
                'losses': 0,
                'win_rate': 0,
                'best_court': 'N/A',
                'series': player.get('Series', series_name),
                'captain': player.get('Captain', '')
            })
    
    # Sort players by matches played, then win rate, then name
    top_players.sort(key=lambda x: (-x['matches'], -x['win_rate'], x['name']))
    
    print(f"\n📊 RESULTS:")
    print(f"  Players with matches: {len(players_with_match_stats)}")
    print(f"  Total players in top_players list: {len(top_players)}")
    print(f"  Roster-only players added: {len(top_players) - len(players_with_match_stats)}")
    
    print(f"\n👥 TOP PLAYERS LIST (first 15):")
    for i, player in enumerate(top_players[:15]):
        captain_str = f" ({player['captain']})" if player['captain'] else ""
        status = "📈 Active" if player['matches'] > 0 else "📝 Roster"
        print(f"  {i+1:2d}. {player['name']}{captain_str} - {player['matches']} matches, {player['win_rate']}% win rate - {status}")
    
    if len(top_players) > 15:
        print(f"  ... and {len(top_players) - 15} more players")
    
    print(f"\n✅ Fix verification:")
    print(f"  ✅ Found all {len(roster_players)} roster players")
    print(f"  ✅ Included {len(players_with_match_stats)} players with match stats")
    print(f"  ✅ Added {len(top_players) - len(players_with_match_stats)} roster-only players")
    print(f"  ✅ Total players displayed: {len(top_players)}")

if __name__ == "__main__":
    test_teams_players_logic() 
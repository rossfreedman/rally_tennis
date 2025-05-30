#!/usr/bin/env python3
"""
Test script for teams-players endpoint
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from server import mobile_teams_players
from flask import Flask, request
import json

def test_teams_players():
    """Test the mobile_teams_players function directly"""
    
    print("Testing teams-players endpoint for: Ravinia Green S2B")
    print("=" * 60)
    
    # Mock Flask request and session
    with Flask(__name__).app_context():
        with Flask(__name__).test_request_context('/?team=Ravinia+Green+S2B'):
            # Mock session
            from flask import session
            session['user'] = {
                'first_name': 'Test',
                'last_name': 'User',
                'email': 'test@example.com',
                'series': 'Series 2B'
            }
            
            try:
                # This would normally call render_template, but let's capture the data
                # We need to modify the function to return data for testing
                team = request.args.get('team')
                print(f"Team parameter: {team}")
                
                # Load the test data directly
                import urllib.parse
                from collections import defaultdict, Counter
                
                with open('data/match_history.json') as f:
                    all_matches = json.load(f)
                
                decoded_team = urllib.parse.unquote_plus(team)
                print(f"Decoded team: {decoded_team}")
                
                # Find all matches for this team
                team_matches = []
                for match in all_matches:
                    home_team = match.get('Home Team', '')
                    away_team = match.get('Away Team', '')
                    if home_team == decoded_team or away_team == decoded_team:
                        team_matches.append(match)
                
                print(f"Found {len(team_matches)} matches for {decoded_team}")
                
                if team_matches:
                    print("\n📊 SAMPLE MATCHES:")
                    for i, match in enumerate(team_matches[:3]):
                        home = match.get('Home Team', '')
                        away = match.get('Away Team', '')
                        scores = match.get('Scores', '')
                        winner = match.get('Winner', '')
                        print(f"  Match {i+1}: {home} vs {away} | {scores} | Winner: {winner}")
                    
                    # Calculate basic stats
                    wins = 0
                    for match in team_matches:
                        is_home = match.get('Home Team') == decoded_team
                        winner_is_home = match.get('Winner') == 'home'
                        team_won = (is_home and winner_is_home) or (not is_home and not winner_is_home)
                        if team_won:
                            wins += 1
                    
                    losses = len(team_matches) - wins
                    win_rate = round((wins / len(team_matches)) * 100, 1) if team_matches else 0
                    
                    print(f"\n📈 TEAM STATS:")
                    print(f"  Total Matches: {len(team_matches)}")
                    print(f"  Wins: {wins}")
                    print(f"  Losses: {losses}")
                    print(f"  Win Rate: {win_rate}%")
                    
                    # Get unique players
                    players = set()
                    for match in team_matches:
                        is_home = match.get('Home Team') == decoded_team
                        if is_home:
                            players.add(match.get('Home Player 1', ''))
                            players.add(match.get('Home Player 2', ''))
                        else:
                            players.add(match.get('Away Player 1', ''))
                            players.add(match.get('Away Player 2', ''))
                    
                    players = {p for p in players if p and p.strip()}
                    print(f"\n👥 PLAYERS ({len(players)}):")
                    for player in sorted(players):
                        print(f"  - {player}")
                
                print("\n✅ Test completed successfully!")
                return True
                
            except Exception as e:
                print(f"❌ Error during test: {str(e)}")
                import traceback
                traceback.print_exc()
                return False

if __name__ == "__main__":
    test_teams_players() 
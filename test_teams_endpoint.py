#!/usr/bin/env python3

import json
from server import calculate_team_analysis

def test_ravinia_team():
    """Test the team analysis for Ravinia Green S2B"""
    
    # Load the data files
    with open('data/series_stats.json') as f:
        all_stats = json.load(f)
    with open('data/match_history.json') as f:
        all_matches = json.load(f)
    
    team = "Ravinia Green S2B"
    
    # Get team stats
    team_stats = next((s for s in all_stats if s.get('team') == team), {})
    print(f"Team stats found: {bool(team_stats)}")
    if team_stats:
        print(f"Team points: {team_stats.get('points', 'N/A')}")
    
    # Get team matches
    team_matches = [m for m in all_matches if m.get('Home Team') == team or m.get('Away Team') == team]
    print(f"Number of matches found: {len(team_matches)}")
    
    if team_matches:
        print("Matches:")
        for i, match in enumerate(team_matches):
            print(f"  {i+1}. {match.get('Date')} - {match.get('Home Team')} vs {match.get('Away Team')}")
            print(f"     Players: {match.get('Home Player 1')}, {match.get('Home Player 2')} vs {match.get('Away Player 1')}, {match.get('Away Player 2')}")
    
    # Calculate team analysis
    if team_stats and team_matches:
        team_analysis_data = calculate_team_analysis(team_stats, team_matches, team)
        print(f"\nTop players found: {len(team_analysis_data['top_players'])}")
        
        if team_analysis_data['top_players']:
            print("Players:")
            for player in team_analysis_data['top_players']:
                print(f"  - {player['name']}: {player['matches']} matches, {player['win_rate']}% win rate")
        else:
            print("No players found in top_players list")
            
        return team_analysis_data
    else:
        print("Missing team stats or matches")
        return None

if __name__ == "__main__":
    test_ravinia_team() 
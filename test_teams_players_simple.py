#!/usr/bin/env python3
"""
Simple test script for teams-players data analysis logic
"""

import json
import urllib.parse
from collections import defaultdict, Counter

def test_team_analysis():
    """Test the team analysis logic"""
    
    print("Testing team analysis for: Ravinia Green S2B")
    print("=" * 60)
    
    # Load match data
    with open('data/match_history.json') as f:
        all_matches = json.load(f)
    
    # Load players data
    with open('data/players.json') as f:
        all_players = json.load(f)
    
    team = "Ravinia Green S2B"
    print(f"Analyzing team: {team}")
    
    # Find all matches for this team
    team_matches = []
    for match in all_matches:
        home_team = match.get('Home Team', '')
        away_team = match.get('Away Team', '')
        if home_team == team or away_team == team:
            team_matches.append(match)
    
    print(f"Found {len(team_matches)} matches for {team}")
    
    if not team_matches:
        print("No matches found!")
        return False
    
    # Calculate team overview stats
    total_matches = len(team_matches)
    wins = 0
    losses = 0
    sets_won = 0
    sets_lost = 0
    games_won = 0
    games_lost = 0
    straight_set_wins = 0
    comeback_wins = 0
    three_set_wins = 0
    three_set_losses = 0
    
    print("\n📊 MATCH ANALYSIS:")
    for i, match in enumerate(team_matches):
        is_home = match.get('Home Team') == team
        winner_is_home = match.get('Winner') == 'home'
        team_won = (is_home and winner_is_home) or (not is_home and not winner_is_home)
        
        home = match.get('Home Team', '')
        away = match.get('Away Team', '')
        scores = match.get('Scores', '')
        
        result = "W" if team_won else "L"
        print(f"  Match {i+1}: {home} vs {away} | {scores} | {result}")
        
        if team_won:
            wins += 1
        else:
            losses += 1
        
        # Parse scores
        score_parts = scores.split(', ')
        match_sets_won = 0
        match_sets_lost = 0
        
        for score in score_parts:
            try:
                # Handle tiebreak notation like "7-6 [7-5]" by removing brackets
                clean_score = score.split(' [')[0] if ' [' in score else score
                if '-' in clean_score:
                    parts = clean_score.split('-')
                    if len(parts) == 2:
                        home_score = int(parts[0])
                        away_score = int(parts[1])
                        
                        if is_home:
                            games_won += home_score
                            games_lost += away_score
                            if home_score > away_score:
                                match_sets_won += 1
                            else:
                                match_sets_lost += 1
                        else:
                            games_won += away_score
                            games_lost += home_score
                            if away_score > home_score:
                                match_sets_won += 1
                            else:
                                match_sets_lost += 1
            except (ValueError, IndexError):
                print(f"Warning: Could not parse score '{score}'")
                pass
        
        sets_won += match_sets_won
        sets_lost += match_sets_lost
        
        # Analyze match patterns
        if len(score_parts) == 2 and team_won:
            straight_set_wins += 1
        elif len(score_parts) == 3:
            if team_won:
                three_set_wins += 1
                # Check for comeback
                first_score_clean = score_parts[0].split(' [')[0] if ' [' in score_parts[0] else score_parts[0]
                if '-' in first_score_clean:
                    first_score = first_score_clean.split('-')
                    if len(first_score) == 2:
                        try:
                            home_first = int(first_score[0])
                            away_first = int(first_score[1])
                            if (is_home and home_first < away_first) or (not is_home and away_first < home_first):
                                comeback_wins += 1
                        except ValueError:
                            pass
            else:
                three_set_losses += 1
    
    # Calculate percentages
    match_win_rate = round((wins / total_matches) * 100, 1) if total_matches > 0 else 0
    set_win_rate = round((sets_won / (sets_won + sets_lost)) * 100, 1) if (sets_won + sets_lost) > 0 else 0
    game_win_rate = round((games_won / (games_won + games_lost)) * 100, 1) if (games_won + games_lost) > 0 else 0
    
    print(f"\n📈 TEAM STATS:")
    print(f"  Total Matches: {total_matches}")
    print(f"  Record: {wins}-{losses}")
    print(f"  Match Win Rate: {match_win_rate}%")
    print(f"  Sets Won/Lost: {sets_won}-{sets_lost}")
    print(f"  Set Win Rate: {set_win_rate}%")
    print(f"  Games Won/Lost: {games_won}-{games_lost}")
    print(f"  Game Win Rate: {game_win_rate}%")
    print(f"  Straight Set Wins: {straight_set_wins}")
    print(f"  Three Set Record: {three_set_wins}-{three_set_losses}")
    print(f"  Comeback Wins: {comeback_wins}")
    
    # Court analysis
    court_stats = {f'court{i}': {'matches': 0, 'wins': 0, 'losses': 0, 'players': Counter()} for i in range(1, 5)}
    matches_by_date = defaultdict(list)
    player_stats = {}
    
    # Group by date for court assignment
    for match in team_matches:
        date = match.get('Date', '')
        matches_by_date[date].append(match)
    
    for date, day_matches in matches_by_date.items():
        day_matches_sorted = sorted(day_matches, key=lambda m: (m.get('Home Team', ''), m.get('Away Team', '')))
        for i, match in enumerate(day_matches_sorted):
            court_num = i + 1
            if court_num > 4:
                continue
            court_key = f'court{court_num}'
            
            is_home = match.get('Home Team') == team
            winner_is_home = match.get('Winner') == 'home'
            team_won = (is_home and winner_is_home) or (not is_home and not winner_is_home)
            
            court_stats[court_key]['matches'] += 1
            if team_won:
                court_stats[court_key]['wins'] += 1
            else:
                court_stats[court_key]['losses'] += 1
            
            # Track players
            if is_home:
                players = [match.get('Home Player 1', ''), match.get('Home Player 2', '')]
            else:
                players = [match.get('Away Player 1', ''), match.get('Away Player 2', '')]
            
            for player in players:
                if player and player.strip():
                    court_stats[court_key]['players'][player] += 1
                    
                    if player not in player_stats:
                        player_stats[player] = {'matches': 0, 'wins': 0, 'courts': Counter()}
                    player_stats[player]['matches'] += 1
                    if team_won:
                        player_stats[player]['wins'] += 1
                    player_stats[player]['courts'][court_key] += 1
    
    print(f"\n🏓 COURT ANALYSIS:")
    for court_key, stats in court_stats.items():
        if stats['matches'] > 0:
            court_win_rate = round((stats['wins'] / stats['matches']) * 100, 1)
            print(f"  {court_key}: {stats['wins']}-{stats['losses']} ({court_win_rate}%) - {stats['matches']} matches")
            top_players = stats['players'].most_common(3)
            for player, matches in top_players:
                print(f"    - {player}: {matches} matches")
    
    print(f"\n👥 PLAYER STATS:")
    sorted_players = sorted(player_stats.items(), key=lambda x: (-x[1]['matches'], -x[1]['wins'], x[0]))
    for player, stats in sorted_players[:10]:  # Top 10 players
        win_rate = round((stats['wins'] / stats['matches']) * 100, 1) if stats['matches'] > 0 else 0
        print(f"  {player}: {stats['wins']}-{stats['matches'] - stats['wins']} ({win_rate}%) - {stats['matches']} matches")
    
    # Analyze player performance from matches
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
                player_stats[player] = {'matches': 0, 'wins': 0}
            player_stats[player]['matches'] += 1
            if team_won:
                player_stats[player]['wins'] += 1
    
    print(f"\n👥 PLAYER STATS FROM MATCHES:")
    for player, stats in player_stats.items():
        if stats['matches'] > 0:
            win_rate = round((stats['wins'] / stats['matches']) * 100, 1)
            print(f"  {player}: {stats['wins']}-{stats['matches'] - stats['wins']} ({win_rate}%) - {stats['matches']} matches")
    
    # Check roster players
    roster_players = [p for p in all_players if p.get('Series Mapping ID') == team]
    print(f"\n📋 ROSTER PLAYERS ({len(roster_players)} total):")
    
    players_with_matches = set(player_stats.keys())
    roster_only_players = []
    
    for player in roster_players:
        full_name = f"{player.get('First Name', '')} {player.get('Last Name', '')}".strip()
        captain_status = player.get('Captain', '')
        captain_str = f" ({captain_status})" if captain_status else ""
        
        if full_name in players_with_matches:
            print(f"  ✅ {full_name}{captain_str} - Has played matches")
        else:
            print(f"  📝 {full_name}{captain_str} - Not in matches yet")
            roster_only_players.append(full_name)
    
    print(f"\n📊 SUMMARY:")
    print(f"  Players with matches: {len(players_with_matches)}")
    print(f"  Players from roster only: {len(roster_only_players)}")
    print(f"  Total team members: {len(roster_players)}")

    print("\n✅ Analysis completed successfully!")
    return True

if __name__ == "__main__":
    test_team_analysis() 
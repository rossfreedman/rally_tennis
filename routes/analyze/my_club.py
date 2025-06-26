from flask import jsonify, session, render_template
import pandas as pd
import json
import os
from datetime import datetime
import logging
from ..act.auth import login_required

logger = logging.getLogger(__name__)

def get_all_club_teams_matches(user):
    """
    Get the most recent matches for ALL teams at a user's club.
    
    Args:
        user: User object containing club information
        
    Returns:
        List of match dictionaries from match_history.json filtered for all teams at the user's club,
        only including matches from the most recent date
    """
    try:
        # Use the JSON file approach instead of database
        script_dir = os.path.dirname(os.path.abspath(__file__))
        json_path = os.path.join(script_dir, '../../data/match_history.json')
        
        with open(json_path, 'r') as f:
            all_matches = json.load(f)
            
        if not user or not user.get('club'):
            return []
            
        user_club = user['club']
        # Filter matches where ANY team from user's club is either home or away team
        # This includes checking if the club name appears at the start of team names
        club_matches = []
        for match in all_matches:
            home_team = match.get('Home Team', '')
            away_team = match.get('Away Team', '')
            
            # Check if either team starts with the user's club name
            # This catches all series/teams at the club (e.g., "Tennaqua S2A", "Tennaqua S3B", etc.)
            is_club_match = (home_team.startswith(user_club + ' ') or 
                            away_team.startswith(user_club + ' ') or
                            home_team == user_club or 
                            away_team == user_club)
            
            if is_club_match:
                # Normalize keys to snake_case
                normalized_match = {
                    'date': match.get('Date', ''),
                    'time': match.get('Time', ''),
                    'location': match.get('Location', ''),
                    'home_team': home_team,
                    'away_team': away_team,
                    'winner': match.get('Winner', ''),
                    'scores': match.get('Scores', ''),
                    'home_player_1': match.get('Home Player 1', ''),
                    'home_player_2': match.get('Home Player 2', ''),
                    'away_player_1': match.get('Away Player 1', ''),
                    'away_player_2': match.get('Away Player 2', ''),
                    'court': match.get('Court', '')
                }
                club_matches.append(normalized_match)
        
        # Sort matches by date to find the most recent
        sorted_matches = sorted(club_matches, key=lambda x: datetime.strptime(x['date'], '%d-%b-%y'), reverse=True)
        
        if not sorted_matches:
            return []
            
        # Get only matches from the most recent date
        most_recent_date = sorted_matches[0]['date']
        recent_matches = [m for m in sorted_matches if m['date'] == most_recent_date]
        
        # Sort by court number if available
        def court_sort_key(match):
            court = match.get('court', '')
            if not court or not str(court).strip():
                return float('inf')
            try:
                return int(court)
            except (ValueError, TypeError):
                return float('inf')
        
        recent_matches.sort(key=court_sort_key)
        return recent_matches
        
    except Exception as e:
        logger.error(f"Error getting all club teams matches: {str(e)}")
        return []

def calculate_player_streaks(matches, club_name):
    """Calculate winning and losing streaks for players"""
    try:
        player_matches = {}
        
        for _, match in matches.iterrows():
            players = [match['player1'], match['player2'], match['player3'], match['player4']]
            
            for player in players:
                if player not in player_matches:
                    player_matches[player] = []
                    
                is_team1 = player in [match['player1'], match['player2']]
                won = (is_team1 and match['team1_won']) or (not is_team1 and match['team2_won'])
                
                player_matches[player].append({
                    'date': match['date'],
                    'won': won
                })
                
        streaks = []
        for player, matches in player_matches.items():
            if len(matches) < 3:  # Require at least 3 matches for a streak
                continue
                
            current_streak = 1
            max_win_streak = 1
            max_loss_streak = 1
            
            for i in range(1, len(matches)):
                if matches[i]['won'] == matches[i-1]['won']:
                    current_streak += 1
                    if matches[i]['won']:
                        max_win_streak = max(max_win_streak, current_streak)
                    else:
                        max_loss_streak = max(max_loss_streak, current_streak)
                else:
                    current_streak = 1
                    
            streaks.append({
                'player': player,
                'max_win_streak': max_win_streak,
                'max_loss_streak': max_loss_streak,
                'current_streak': current_streak,
                'current_streak_type': 'win' if matches[-1]['won'] else 'loss'
            })
            
        return sorted(streaks, key=lambda x: (x['max_win_streak'], -x['max_loss_streak']), reverse=True)
        
    except Exception as e:
        logger.error(f"Error calculating player streaks: {str(e)}")
        return []

def get_club_analysis(user):
    """Get comprehensive club analysis"""
    try:
        with get_db() as conn:
            # Get all matches for the club
            matches_df = pd.read_sql_query('''
                SELECT * FROM matches 
                WHERE club = %s
                ORDER BY date DESC
            ''', conn, params=[user['club']])
            
            # Get all teams in the club
            teams_df = pd.read_sql_query('''
                SELECT * FROM teams 
                WHERE club = %s
            ''', conn, params=[user['club']])

        if matches_df.empty:
            return {
                'error': 'No match data found',
                'matches_played': 0,
                'teams': 0
            }

        # Basic stats
        total_matches = len(matches_df)
        total_teams = len(teams_df)
        
        # Court usage
        court_stats = matches_df['court'].value_counts().to_dict()
        
        # Time of day stats
        matches_df['hour'] = pd.to_datetime(matches_df['time']).dt.hour
        time_stats = {
            'morning': len(matches_df[matches_df['hour'] < 12]),
            'afternoon': len(matches_df[(matches_df['hour'] >= 12) & (matches_df['hour'] < 17)]),
            'evening': len(matches_df[matches_df['hour'] >= 17])
        }
        
        # Player streaks
        streaks = calculate_player_streaks(matches_df, user['club'])
        
        # Recent matches
        recent_matches = get_recent_matches_for_user_club(user)

        return {
            'club_name': user['club'],
            'total_matches': total_matches,
            'total_teams': total_teams,
            'court_stats': court_stats,
            'time_stats': time_stats,
            'player_streaks': streaks[:10],  # Top 10 streaks
            'recent_matches': recent_matches[:5]  # Last 5 matches
        }
    except Exception as e:
        logger.error(f"Error in club analysis: {str(e)}")
        return {'error': 'Failed to analyze club data'}

def init_routes(app):
    @app.route('/mobile/my-club')
    @login_required
    def my_club():
        try:
            if 'user' not in session:
                return jsonify({'error': 'Not authenticated'}), 401

            user = session['user']
            club = user.get('club')
            
            print(f"\n=== ANALYZE ROUTES MY CLUB ENDPOINT ===")
            print(f"User club: {club}")
            print(f"Using get_all_club_teams_matches function from routes/analyze/my_club.py")
            
            # Use the new function that gets ALL club teams
            matches_data = get_all_club_teams_matches(user)
            print(f"Found {len(matches_data)} matches for all teams at {club}")
            
            # Debug: Show which teams were found
            teams_found = set()
            for match in matches_data:
                home_team = match['home_team']
                away_team = match['away_team']
                if home_team.startswith(club + ' ') or home_team == club:
                    teams_found.add(home_team)
                if away_team.startswith(club + ' ') or away_team == club:
                    teams_found.add(away_team)
            print(f"Teams found for {club}: {list(teams_found)}")
            print("=" * 50)
            
            if not matches_data:
                return render_template(
                    'mobile/my_club.html',
                    team_name=club,
                    this_week_results=[],
                    tennaqua_standings=[],
                    head_to_head=[],
                    player_streaks=[]
                )
            
            # Process data similar to main server.py logic
            # Group matches by team
            team_matches = {}
            for match in matches_data:
                home_team = match['home_team']
                away_team = match['away_team']
                
                # Check if home team belongs to user's club
                if home_team.startswith(club + ' ') or home_team == club:
                    team = home_team
                    opponent = away_team.split(' - ')[0] if ' - ' in away_team else away_team.split(' ')[0]
                    is_home = True
                # Check if away team belongs to user's club
                elif away_team.startswith(club + ' ') or away_team == club:
                    team = away_team
                    opponent = home_team.split(' - ')[0] if ' - ' in home_team else home_team.split(' ')[0]
                    is_home = False
                else:
                    continue
                    
                if team not in team_matches:
                    team_matches[team] = {
                        'opponent': opponent,
                        'matches': [],
                        'team_points': 0,
                        'opponent_points': 0,
                        'series': team.split(' - ')[1] if ' - ' in team else team.split(' ')[-1] if ' ' in team else team
                    }
                
                # Calculate points for this match
                scores = match['scores'].split(', ')
                match_team_points = 0
                match_opponent_points = 0
                
                # Points for each set
                for set_score in scores:
                    try:
                        # Handle tiebreak notation like "7-6 [7-5]" by removing brackets
                        clean_score = set_score.split(' [')[0] if ' [' in set_score else set_score
                        if '-' in clean_score:
                            our_score, their_score = map(int, clean_score.split('-'))
                            if not is_home:
                                our_score, their_score = their_score, our_score
                                
                            if our_score > their_score:
                                match_team_points += 1
                            else:
                                match_opponent_points += 1
                    except (ValueError, IndexError) as e:
                        logger.error(f"Warning: Could not parse score '{set_score}': {e}")
                        continue
                        
                # Bonus point for match win
                if (is_home and match['winner'] == 'home') or (not is_home and match['winner'] == 'away'):
                    match_team_points += 1
                else:
                    match_opponent_points += 1
                    
                # Update total points
                team_matches[team]['team_points'] += match_team_points
                team_matches[team]['opponent_points'] += match_opponent_points
                
                # Add match details
                court = match.get('court', '')
                try:
                    court_num = int(court) if court and court.strip() else len(team_matches[team]['matches']) + 1
                except (ValueError, TypeError):
                    court_num = len(team_matches[team]['matches']) + 1
                    
                team_matches[team]['matches'].append({
                    'court': court_num,
                    'home_players': f"{match['home_player_1']}/{match['home_player_2']}" if is_home else f"{match['away_player_1']}/{match['away_player_2']}",
                    'away_players': f"{match['away_player_1']}/{match['away_player_2']}" if is_home else f"{match['home_player_1']}/{match['home_player_2']}",
                    'scores': match['scores'],
                    'won': (is_home and match['winner'] == 'home') or (not is_home and match['winner'] == 'away')
                })
            
            # Convert to list format for template
            this_week_results = []
            for team_data in team_matches.values():
                this_week_results.append({
                    'series': f"Series {team_data['series']}" if team_data['series'].isdigit() else team_data['series'],
                    'opponent': team_data['opponent'],
                    'score': f"{team_data['team_points']}-{team_data['opponent_points']}",
                    'won': team_data['team_points'] > team_data['opponent_points'],
                    'match_details': sorted(team_data['matches'], key=lambda x: x['court']),
                    'date': matches_data[0]['date']  # All matches are from the same date
                })
                
            # Sort results by opponent name
            this_week_results.sort(key=lambda x: x['opponent'])
            
            # Calculate Club standings (simplified for now)
            # Load series stats
            script_dir = os.path.dirname(os.path.abspath(__file__))
            stats_path = os.path.join(script_dir, '../../data/series_stats.json')
            try:
                with open(stats_path, 'r') as f:
                    stats_data = json.load(f)
            except:
                stats_data = []
            
            tennaqua_standings = []
            for team_stats in stats_data:
                team_name = team_stats.get('team', '')
                if not (team_name.startswith(club + ' ') or team_name == club):
                    continue
                    
                series = team_stats.get('series')
                if not series:
                    continue
                    
                # Get all teams in this series
                series_teams = [team for team in stats_data if team.get('series') == series]
                
                # Calculate average points
                for team in series_teams:
                    total_matches = sum(team.get('matches', {}).get(k, 0) for k in ['won', 'lost', 'tied'])
                    total_points = float(team.get('points', 0))
                    team['avg_points'] = round(total_points / total_matches, 1) if total_matches > 0 else 0
                
                # Sort by average points
                series_teams.sort(key=lambda x: x.get('avg_points', 0), reverse=True)
                
                # Find club's position
                for i, team in enumerate(series_teams, 1):
                    team_name = team.get('team', '')
                    if team_name.startswith(club + ' ') or team_name == club:
                        tennaqua_standings.append({
                            'series': series,
                            'place': i,
                            'total_points': team.get('points', 0),
                            'avg_points': team.get('avg_points', 0),
                            'playoff_contention': i <= 8,
                            'team_name': team_name
                        })
                        break
                        
            # Sort standings by place (ascending)
            tennaqua_standings.sort(key=lambda x: x['place'])
            
            # Calculate head-to-head records
            head_to_head = {}
            for match in matches_data:
                home_team = match.get('home_team', '')
                away_team = match.get('away_team', '')
                winner = match.get('winner', '')
                
                if not all([home_team, away_team, winner]):
                    continue
                    
                # Check if home team belongs to user's club
                if home_team.startswith(club + ' ') or home_team == club:
                    opponent = away_team.split(' - ')[0] if ' - ' in away_team else away_team.split(' ')[0]
                    won = winner == 'home'
                # Check if away team belongs to user's club
                elif away_team.startswith(club + ' ') or away_team == club:
                    opponent = home_team.split(' - ')[0] if ' - ' in home_team else home_team.split(' ')[0]
                    won = winner == 'away'
                else:
                    continue
                    
                if opponent not in head_to_head:
                    head_to_head[opponent] = {'wins': 0, 'losses': 0, 'total': 0}
                    
                head_to_head[opponent]['total'] += 1
                if won:
                    head_to_head[opponent]['wins'] += 1
                else:
                    head_to_head[opponent]['losses'] += 1
                    
            # Convert head-to-head to list
            head_to_head = [
                {
                    'opponent': opponent,
                    'wins': stats['wins'],
                    'losses': stats['losses'],
                    'total': stats['total']
                }
                for opponent, stats in head_to_head.items()
            ]
            
            # Sort by total matches
            head_to_head.sort(key=lambda x: x['total'], reverse=True)
            
            # Simple player streaks (simplified for now)
            player_streaks = []
            
            return render_template(
                'mobile/my_club.html',
                team_name=club,
                this_week_results=this_week_results,
                tennaqua_standings=tennaqua_standings,
                head_to_head=head_to_head,
                player_streaks=player_streaks
            )
            
        except Exception as e:
            logger.error(f"Error serving club analysis: {str(e)}")
            import traceback
            print(traceback.format_exc())
            return jsonify({'error': 'Failed to serve club analysis'}), 500

    @app.route('/api/win-streaks')
    @login_required
    def get_win_streaks():
        try:
            if 'user' not in session:
                return jsonify({'error': 'Not authenticated'}), 401

            user = session['user']
            
            # Get matches for the club
            with get_db() as conn:
                matches_df = pd.read_sql_query('''
                    SELECT * FROM matches 
                    WHERE club = %s
                    ORDER BY date DESC
                ''', conn, params=[user['club']])
            
            if matches_df.empty:
                return jsonify({'streaks': []})
                
            streaks = calculate_player_streaks(matches_df, user['club'])
            return jsonify({'streaks': streaks})
            
        except Exception as e:
            logger.error(f"Error getting win streaks: {str(e)}")
            return jsonify({'error': 'Failed to get win streaks'}), 500

    return app 
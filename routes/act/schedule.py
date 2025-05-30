from flask import jsonify, request, session
from datetime import datetime
import os
import json
from utils.logging import log_user_activity
from utils.auth import login_required

def get_matches_for_user_club(user):
    """Get upcoming matches for a user's club from schedules.json"""
    try:
        # Use schedules.json for upcoming matches (availability system)
        file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../data', 'schedules.json')
        print(f"Looking for schedule file at: {file_path}")
        
        with open(file_path, 'r') as f:
            all_matches = json.load(f)
            
        # Get user's club and series
        user_club = user.get('club')
        user_series = user.get('series')
        if not user_club or not user_series:
            print("Missing club or series in user data")
            return []
            
        print(f"Looking for matches for club: {user_club}, series: {user_series}")
        
        # Get club addresses from database
        from utils.db import execute_query
        club_addresses = {}
        try:
            clubs = execute_query("SELECT name, address FROM clubs")
            print(f"Raw clubs query result: {clubs[:3] if clubs else 'No clubs found'}")  # Debug: show first 3 clubs
            
            for club in clubs:
                club_addresses[club['name']] = club['address']
                
            print(f"Loaded {len(club_addresses)} club addresses")
            
            # Debug: Show which clubs have addresses
            clubs_with_addresses = {name: addr for name, addr in club_addresses.items() if addr}
            clubs_without_addresses = {name: addr for name, addr in club_addresses.items() if not addr}
            
            print(f"Clubs with addresses: {len(clubs_with_addresses)}")
            print(f"Clubs without addresses: {len(clubs_without_addresses)}")
            
            if clubs_without_addresses:
                print(f"Clubs missing addresses: {list(clubs_without_addresses.keys())}")
                
        except Exception as e:
            print(f"Warning: Could not load club addresses: {e}")
            import traceback
            print(f"Full traceback: {traceback.format_exc()}")
        
        # Helper function to extract club name from location
        def get_club_address(location):
            """Get the address for a club location"""
            if not location:
                print(f"get_club_address: No location provided")
                return None
            
            print(f"get_club_address: Looking up address for location '{location}'")
            
            # Try exact match first
            if location in club_addresses:
                address = club_addresses[location]
                print(f"get_club_address: Exact match found for '{location}': {address}")
                return address
            
            # Try to extract club name from location (remove extra text)
            location_clean = location.strip()
            for club_name in club_addresses:
                if club_name.lower() in location_clean.lower():
                    address = club_addresses[club_name]
                    print(f"get_club_address: Partial match found '{club_name}' in '{location}': {address}")
                    return address
            
            print(f"get_club_address: No address found for location '{location}'")
            print(f"get_club_address: Available clubs: {list(club_addresses.keys())}")
            return None
        
        filtered_matches = []
        for match in all_matches:
            try:
                match_series = match.get('series', '')
                home_team = match.get('home_team', '')
                away_team = match.get('away_team', '')
                match_type = match.get('type', '')
                
                # Include practices for the user's series OR "All" series
                is_practice_for_user = (
                    (match_series == "All" and match_type == "Practice") or  # Existing logic for "All" practices
                    (match_series == user_series and match_type == "Practice")  # New logic for series-specific practices
                )
                
                if is_practice_for_user:
                    print(f"Found practice session for {match_series}: {match.get('description', 'Team Practice')}")
                    practice_location = match.get('location', user_club)
                    practice_address = get_club_address(practice_location)
                    
                    normalized_match = {
                        'date': match.get('date', ''),
                        'time': match.get('time', ''),
                        'location': practice_location,
                        'location_address': practice_address,
                        'home_team': user_club,  # Set user's club as home team for practices
                        'away_team': '',
                        'type': 'practice',
                        'description': match.get('description', 'Team Practice')
                    }
                    filtered_matches.append(normalized_match)
                    continue
                
                # For actual matches, only include matches where the user's club is actually playing
                # Use the same robust logic as server.py for consistency
                
                # The team name in schedules.json could be in multiple formats:
                # 1. "Club SXX" (e.g. "Tennaqua S2B") - current format
                # 2. "Club - Series - Series" (e.g. "Tennaqua - 22 - 22") - legacy format
                # 3. "Club - Chicago - Series - Series" (e.g. "Midtown - Chicago - 6 - 6") - legacy format
                
                # Extract series abbreviation (e.g. "Series 2B" -> "S2B")
                if user_series.startswith("Series "):
                    series_abbrev = "S" + user_series.replace("Series ", "")
                else:
                    series_abbrev = user_series.split()[-1]  # Get the last part for legacy format
                
                possible_team_formats = [
                    f"{user_club} {series_abbrev}",  # Current format: "Tennaqua S2B"
                    f"{user_club} - {series_abbrev} - {series_abbrev}",  # Legacy format 1
                    f"{user_club} - Chicago - {series_abbrev} - {series_abbrev}",  # Legacy format 2
                    f"{user_club} - {series_abbrev}"  # Legacy format 3
                ]
                
                # Check if either home or away team exactly matches any of our possible formats
                is_user_team = any(fmt == home_team or fmt == away_team for fmt in possible_team_formats)
                
                if is_user_team:
                    print(f"Found match: {home_team} vs {away_team} (series: {match_series})")
                    match_location = match.get('location', '')
                    match_address = get_club_address(match_location)
                    
                    normalized_match = {
                        'date': match.get('date', ''),
                        'time': match.get('time', ''),
                        'location': match_location,
                        'location_address': match_address,
                        'home_team': home_team,
                        'away_team': away_team,
                        'type': 'match'
                    }
                    filtered_matches.append(normalized_match)
                    
            except Exception as e:
                print(f"Warning: Skipping invalid match record: {e}")
                continue
                
        print(f"Found {len(filtered_matches)} total events (matches + practices) for user")
        
        # Sort matches by date chronologically
        try:
            # First try MM/DD/YYYY format (from schedules.json)
            filtered_matches = sorted(filtered_matches, key=lambda x: datetime.strptime(x['date'], '%m/%d/%Y'))
            print("Sorted matches using MM/DD/YYYY format")
        except Exception as e:
            print(f"Error sorting matches with MM/DD/YYYY format: {e}")
            try:
                # Try DD-Mon-YY format
                filtered_matches = sorted(filtered_matches, key=lambda x: datetime.strptime(x['date'], '%d-%b-%y'))
                print("Sorted matches using DD-Mon-YY format")
            except Exception as e2:
                print(f"Error sorting matches with DD-Mon-YY format: {e2}")
                try:
                    # Try YYYY-MM-DD format
                    filtered_matches = sorted(filtered_matches, key=lambda x: datetime.strptime(x['date'], '%Y-%m-%d'))
                    print("Sorted matches using YYYY-MM-DD format")
                except Exception as e3:
                    print(f"Error sorting matches with any format, using string sort: {e3}")
                    filtered_matches = sorted(filtered_matches, key=lambda x: x['date'])
        
        return filtered_matches
    except Exception as e:
        print(f"Error getting matches for user club: {str(e)}")
        return []

def init_schedule_routes(app):
    @app.route('/api/schedule')
    @login_required
    def serve_schedule():
        """Serve the schedule data"""
        try:
            file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../data', 'match_history.json')
            with open(file_path, 'r') as f:
                data = json.load(f)
            return jsonify(data)
        except Exception as e:
            print(f"Error loading schedule: {str(e)}")
            return jsonify({'error': str(e)}), 500

    @app.route('/api/team-matches')
    @login_required
    def get_team_matches():
        """Get matches for a team"""
        try:
            file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../data', 'match_history.json')
            with open(file_path, 'r') as f:
                matches = json.load(f)
            return jsonify(matches)
        except Exception as e:
            print(f"Error getting team matches: {str(e)}")
            return jsonify({'error': str(e)}), 500 
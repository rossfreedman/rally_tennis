import os
import json
import traceback
from datetime import datetime
from database_utils import execute_query


def get_matches_for_user_club(user):
    """
    Get all matches for a user's club and series.
    
    Args:
        user: User object containing club and series information
        
    Returns:
        List of match dictionaries from schedules.json filtered for the user's club and series
    """
    try:
        schedule_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'data', 'schedules.json')
        print(f"\n=== Getting matches for user club ===")
        print(f"Looking for schedule file at: {schedule_path}")
        
        with open(schedule_path, 'r') as f:
            all_matches = json.load(f)
            
        if not user or not user.get('club') or not user.get('series'):
            print("❌ Missing user data:", user)
            return []
            
        user_club = user['club']
        user_series = user['series']
        print(f"Looking for matches for club: {user_club}, series: {user_series}")
        
        # Get club addresses from database
        club_addresses = {}
        try:
            clubs = execute_query("SELECT name, address FROM clubs")
            for club in clubs:
                club_addresses[club['name']] = club['address']
            print(f"Loaded {len(club_addresses)} club addresses")
            print(f"Sample club addresses: {dict(list(club_addresses.items())[:3])}")
        except Exception as e:
            print(f"Warning: Could not load club addresses: {e}")
            import traceback
            print(f"Full traceback: {traceback.format_exc()}")
        
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
        
        # Filter matches where user's team is either home or away team
        club_matches = []
        for match in all_matches:
            try:
                # Check if it's a practice record
                if match.get('type') == 'Practice' or 'Practice' in match:
                    # For practices, add if it's for all clubs or at the user's specific club
                    practice_location = match.get('location', '')
                    practice_series = match.get('series', '')
                    if (practice_location == user_club or 
                        practice_location == 'All Clubs' or 
                        practice_series == 'All' or
                        practice_series == user_series):  # Add support for series-specific practices
                        # For "All Clubs" practices, show the user's club as the location
                        display_location = user_club if practice_location == 'All Clubs' else practice_location
                        
                        # Get address for the practice location
                        practice_address = get_club_address(display_location)
                        print(f"Practice location '{display_location}' -> address: {practice_address}")
                        
                        normalized_match = {
                            'id': f"practice-{match.get('date', '')}-{user_club}",  # Add unique ID
                            'date': match.get('date', ''),
                            'time': match.get('time', ''),
                            'location': display_location,
                            'location_address': practice_address,
                            'Practice': True,
                            'type': 'Practice',
                            'description': match.get('description', 'Team Practice')
                        }
                        club_matches.append(normalized_match)
                        continue
                
                home_team = match.get('home_team', '')
                away_team = match.get('away_team', '')
                
                # Check if either home or away team exactly matches any of our possible formats
                is_user_team = any(fmt == home_team or fmt == away_team for fmt in possible_team_formats)
                
                if is_user_team:
                    # Create a unique ID for the match
                    match_id = f"{match.get('date', '')}-{home_team}-{away_team}"
                    
                    # Get address for the match location
                    match_location = match.get('location', '')
                    match_address = get_club_address(match_location)
                    print(f"Match location '{match_location}' -> address: {match_address}")
                    
                    # Normalize keys to snake_case and ensure all required fields exist
                    normalized_match = {
                        'id': match_id,  # Add unique ID
                        'date': match.get('date', ''),
                        'time': match.get('time', ''),
                        'location': match_location,
                        'location_address': match_address,
                        'home_team': home_team,
                        'away_team': away_team,
                        'winner': match.get('winner', ''),
                        'scores': match.get('scores', ''),
                        'home_player_1': match.get('home_player_1', ''),
                        'home_player_2': match.get('home_player_2', ''),
                        'away_player_1': match.get('away_player_1', ''),
                        'away_player_2': match.get('away_player_2', ''),
                        'type': 'match'
                    }
                    club_matches.append(normalized_match)
            except KeyError as e:
                print(f"Warning: Skipping invalid match record: {e}")
                continue
        
        print(f"Found {len(club_matches)} matches for club")
        
        # Sort matches by date chronologically
        try:
            # First try MM/DD/YYYY format (from schedules.json)
            club_matches = sorted(club_matches, key=lambda x: datetime.strptime(x['date'], '%m/%d/%Y'))
            print("Sorted matches using MM/DD/YYYY format")
        except Exception as e:
            print(f"Error sorting matches with MM/DD/YYYY format: {e}")
            try:
                # Try DD-Mon-YY format
                club_matches = sorted(club_matches, key=lambda x: datetime.strptime(x['date'], '%d-%b-%y'))
                print("Sorted matches using DD-Mon-YY format")
            except Exception as e2:
                print(f"Error sorting matches with DD-Mon-YY format: {e2}")
                try:
                    # Try YYYY-MM-DD format
                    club_matches = sorted(club_matches, key=lambda x: datetime.strptime(x['date'], '%Y-%m-%d'))
                    print("Sorted matches using YYYY-MM-DD format")
                except Exception as e3:
                    print(f"Error sorting matches with any format, using string sort: {e3}")
                    club_matches = sorted(club_matches, key=lambda x: x['date'])
        
        print("=== End getting matches for user club ===\n")
        return club_matches
    except Exception as e:
        print(f"Error getting matches for user club: {e}")
        print(traceback.format_exc())  # Print full traceback for debugging
        return [] 
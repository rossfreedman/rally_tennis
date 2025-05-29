from flask import jsonify, request, session, render_template
from datetime import datetime, timezone, timedelta
import os
import json
import traceback
from database_utils import execute_query, execute_query_one
from utils.logging import log_user_activity
from routes.act.schedule import get_matches_for_user_club
from utils.auth import login_required
import pytz

# Define the application timezone
APP_TIMEZONE = pytz.timezone('America/Chicago')

# Import our new date verification utilities
from utils.date_verification import (
    verify_and_fix_date_for_storage,
    verify_date_from_database,
    log_date_operation
)

def normalize_date_for_db(date_input, target_timezone='America/Chicago'):
    """
    Normalize date input to a consistent TIMESTAMPTZ format for database storage.
    Always stores dates at noon in the target timezone to avoid edge cases.
    """
    try:
        print(f"Normalizing date: {date_input} (type: {type(date_input)})")
        
        if isinstance(date_input, str):
            # Handle multiple date formats
            if '/' in date_input:
                # Handle MM/DD/YYYY format
                dt = datetime.strptime(date_input, '%m/%d/%Y')
            else:
                # Handle YYYY-MM-DD format
                dt = datetime.strptime(date_input, '%Y-%m-%d')
        elif isinstance(date_input, datetime):
            dt = date_input
        else:
            raise ValueError(f"Unsupported date type: {type(date_input)}")
        
        # Set time to noon to avoid timezone edge cases
        dt = dt.replace(hour=12, minute=0, second=0, microsecond=0)
        
        # Localize to target timezone
        tz = pytz.timezone(target_timezone)
        if dt.tzinfo is None:
            dt = tz.localize(dt)
        else:
            dt = dt.astimezone(tz)
        
        print(f"Normalized to: {dt}")
        return dt
        
    except Exception as e:
        print(f"Error normalizing date {date_input}: {str(e)}")
        raise

def get_player_availability(player_name, match_date, series):
    """Get availability for a player on a specific date with verification"""
    try:
        print(f"\n=== GET PLAYER AVAILABILITY WITH VERIFICATION ===")
        print(f"Player: {player_name}")
        print(f"Original date: {match_date}")
        print(f"Series: {series}")
        
        # First get the series_id
        series_record = execute_query_one(
            "SELECT id FROM series WHERE name = %(series)s",
            {'series': series}
        )
        print(f"Series lookup result: {series_record}")
        
        if not series_record:
            print(f"No series found with name: {series}")
            return None
        
        # Normalize the date for querying
        normalized_date = normalize_date_for_db(match_date)
        
        print(f"Querying availability with parameters:")
        print(f"  player_name: {player_name.strip()}")
        print(f"  match_date: {normalized_date}")
        print(f"  series_id: {series_record['id']}")
        
        # Query the database
        result = execute_query_one(
            """
            SELECT availability_status, match_date
            FROM player_availability 
            WHERE player_name = %(player_name)s 
            AND DATE(match_date AT TIME ZONE 'America/Chicago') = DATE(%(match_date)s AT TIME ZONE 'America/Chicago')
            AND series_id = %(series_id)s
            """,
            {
                'player_name': player_name.strip(),
                'match_date': normalized_date,
                'series_id': series_record['id']
            }
        )
        print(f"Availability lookup result: {result}")
        
        if not result:
            print(f"No availability found for {player_name} on {match_date}")
            return None
        
        # Verify the retrieved date for display
        stored_date = result['match_date']
        display_date, verification_info = verify_date_from_database(
            stored_date=stored_date,
            expected_display_format=None
        )
        
        # Log the retrieval verification
        log_date_operation(
            operation="RETRIEVAL_VERIFICATION",
            input_data=f"stored={stored_date}",
            output_data=f"display={display_date}",
            verification_info=verification_info
        )
        
        if verification_info.get('correction_applied'):
            print(f"⚠️ Display correction applied for retrieval")
        
        print(f"Found availability status: {result['availability_status']}")
        return result['availability_status']
        
    except Exception as e:
        print(f"Error in get_player_availability: {str(e)}")
        print(traceback.format_exc())
        return None

def update_player_availability(player_name, match_date, availability_status, series):
    """
    Update player availability with enhanced date verification and correction
    
    This function now includes a comprehensive post-storage verification system that:
    1. Stores the availability record with the intended date
    2. Verifies that the record was stored with the correct date
    3. If a discrepancy is found (most commonly one day earlier due to timezone issues):
       - Searches for records with the wrong date but correct status and player info
       - Updates the discrepant record to have the correct date
       - Verifies the correction was successful
    4. Logs all verification and correction operations for monitoring
    
    This addresses timezone-related date storage issues that can cause records
    to be stored with dates that are off by one day.
    """
    try:
        print(f"\n=== UPDATE PLAYER AVAILABILITY WITH VERIFICATION ===")
        print(f"Input - Player: {player_name}, Date: {match_date}, Status: {availability_status}, Series: {series}")
        
        # Step 1: Verify and fix the date before storage
        corrected_date, verification_info = verify_and_fix_date_for_storage(
            input_date=match_date,
            intended_display_date=None  # We could pass this from the frontend if needed
        )
        
        # Log the date verification result
        log_date_operation(
            operation="PRE_STORAGE_VERIFICATION",
            input_data=match_date,
            output_data=corrected_date,
            verification_info=verification_info
        )
        
        if verification_info.get('correction_applied'):
            print(f"⚠️ Date correction applied: {match_date} -> {corrected_date}")
        
        # Get series ID
        series_record = execute_query_one(
            "SELECT id FROM series WHERE name = %(series)s",
            {'series': series}
        )
        
        if not series_record:
            print(f"❌ Series not found: {series}")
            return False
        
        series_id = series_record['id']
        
        # Convert corrected date to date object for database
        try:
            if isinstance(corrected_date, str):
                # For Railway PostgreSQL, we need to be more explicit about timezone handling
                # Convert to a timezone-aware datetime at noon in Chicago timezone
                from datetime import datetime
                import pytz
                
                # Parse the date string
                date_obj = datetime.strptime(corrected_date, '%Y-%m-%d').date()
                
                # Create a timezone-aware datetime at noon Chicago time
                chicago_tz = pytz.timezone('America/Chicago')
                intended_datetime = chicago_tz.localize(datetime.combine(date_obj, datetime.min.time().replace(hour=12)))
                
                # For Railway compatibility, store as timezone-aware datetime
                # This ensures the date is stored correctly regardless of Railway's timezone handling
                intended_date_obj = intended_datetime
                
                print(f"Converted date for Railway storage: {date_obj} -> {intended_datetime}")
            else:
                intended_date_obj = corrected_date
        except Exception as e:
            print(f"❌ Error converting corrected date: {e}")
            return False
        
        print(f"Intended date for storage: {intended_date_obj}")
        
        # Check if record exists
        existing_record = execute_query_one(
            """
            SELECT id, availability_status, match_date
            FROM player_availability 
            WHERE player_name = %(player)s 
            AND series_id = %(series_id)s 
            AND DATE(match_date AT TIME ZONE 'America/Chicago') = DATE(%(date)s AT TIME ZONE 'America/Chicago')
            """,
            {
                'player': player_name,
                'series_id': series_id,
                'date': intended_date_obj
            }
        )
        
        if existing_record:
            print(f"Updating existing record (ID: {existing_record['id']})")
            print(f"Old status: {existing_record['availability_status']} -> New status: {availability_status}")
            
            result = execute_query(
                """
                UPDATE player_availability 
                SET availability_status = %(status)s, updated_at = NOW()
                WHERE id = %(id)s
                """,
                {
                    'status': availability_status,
                    'id': existing_record['id']
                }
            )
        else:
            # Before creating a new record, check for discrepant dates (timezone issues)
            print("No record found with intended date. Checking for date discrepancies...")
            
            # Check one day earlier (most likely scenario)
            one_day_earlier = intended_date_obj - timedelta(days=1)
            earlier_record = execute_query_one(
                """
                SELECT id, match_date, availability_status 
                FROM player_availability 
                WHERE player_name = %(player)s 
                AND series_id = %(series_id)s 
                AND DATE(match_date AT TIME ZONE 'America/Chicago') = DATE(%(date)s AT TIME ZONE 'America/Chicago')
                """,
                {
                    'player': player_name,
                    'series_id': series_id,
                    'date': one_day_earlier
                }
            )
            
            # Check one day later (less likely but possible)
            one_day_later = intended_date_obj + timedelta(days=1)
            later_record = execute_query_one(
                """
                SELECT id, match_date, availability_status 
                FROM player_availability 
                WHERE player_name = %(player)s 
                AND series_id = %(series_id)s 
                AND DATE(match_date AT TIME ZONE 'America/Chicago') = DATE(%(date)s AT TIME ZONE 'America/Chicago')
                """,
                {
                    'player': player_name,
                    'series_id': series_id,
                    'date': one_day_later
                }
            )
            
            # If we find a discrepant record, correct it instead of creating a new one
            if earlier_record:
                print(f"🔧 Found record one day earlier: {one_day_earlier} (should be {intended_date_obj})")
                print(f"   Correcting record ID {earlier_record['id']} date and status")
                
                # Update both the date and status of the discrepant record
                result = execute_query(
                    """
                    UPDATE player_availability 
                    SET match_date = %(correct_date)s, availability_status = %(status)s, updated_at = NOW()
                    WHERE id = %(id)s
                    """,
                    {
                        'correct_date': intended_date_obj,
                        'status': availability_status,
                        'id': earlier_record['id']
                    }
                )
                
                # Log the pre-storage correction
                log_date_operation(
                    operation="PRE_STORAGE_CORRECTION",
                    input_data=f"discrepant_date={one_day_earlier}, intended_date={intended_date_obj}",
                    output_data=f"corrected_existing_record_id={earlier_record['id']}",
                    verification_info={
                        'discrepancy_found': True,
                        'discrepancy_type': "one_day_earlier",
                        'correction_type': "update_existing_record"
                    }
                )
                
            elif later_record:
                print(f"🔧 Found record one day later: {one_day_later} (should be {intended_date_obj})")
                print(f"   Correcting record ID {later_record['id']} date and status")
                
                # Update both the date and status of the discrepant record
                result = execute_query(
                    """
                    UPDATE player_availability 
                    SET match_date = %(correct_date)s, availability_status = %(status)s, updated_at = NOW()
                    WHERE id = %(id)s
                    """,
                    {
                        'correct_date': intended_date_obj,
                        'status': availability_status,
                        'id': later_record['id']
                    }
                )
                
                # Log the pre-storage correction
                log_date_operation(
                    operation="PRE_STORAGE_CORRECTION",
                    input_data=f"discrepant_date={one_day_later}, intended_date={intended_date_obj}",
                    output_data=f"corrected_existing_record_id={later_record['id']}",
                    verification_info={
                        'discrepancy_found': True,
                        'discrepancy_type': "one_day_later", 
                        'correction_type': "update_existing_record"
                    }
                )
                
            else:
                # No discrepant records found, create new record
                print("Creating new availability record")
                result = execute_query(
                    """
                    INSERT INTO player_availability (player_name, match_date, availability_status, series_id, updated_at)
                    VALUES (%(player)s, %(date)s, %(status)s, %(series_id)s, NOW())
                    """,
                    {
                        'player': player_name,
                        'date': intended_date_obj,
                        'status': availability_status,
                        'series_id': series_id
                    }
                )
        
        # Enhanced post-storage verification and correction
        print(f"\n=== POST-STORAGE VERIFICATION AND CORRECTION ===")
        
        # First check if the record exists with the intended date
        verification_record = execute_query_one(
            """
            SELECT id, match_date, availability_status 
            FROM player_availability 
            WHERE player_name = %(player)s 
            AND series_id = %(series_id)s 
            AND match_date = %(date)s
            """,
            {
                'player': player_name,
                'series_id': series_id,
                'date': intended_date_obj
            }
        )
        
        if verification_record:
            # Perfect match - no discrepancy
            stored_date = verification_record['match_date']
            stored_status = verification_record['availability_status']
            
            print(f"✅ Perfect match: Stored date={stored_date}, status={stored_status}")
            
            # Log the successful storage
            log_date_operation(
                operation="POST_STORAGE_VERIFICATION",
                input_data=f"intended_date={intended_date_obj}, status={availability_status}",
                output_data=f"stored_date={stored_date}, stored_status={stored_status}",
                verification_info={'storage_successful': True, 'discrepancy_found': False}
            )
            
            return True
        else:
            # Check for common discrepancies (one day earlier or later)
            print(f"⚠️ No exact match found. Checking for date discrepancies...")
            
            # Check one day earlier (most likely scenario)
            one_day_earlier = intended_date_obj - timedelta(days=1)
            earlier_record = execute_query_one(
                """
                SELECT id, match_date, availability_status 
                FROM player_availability 
                WHERE player_name = %(player)s 
                AND series_id = %(series_id)s 
                AND DATE(match_date AT TIME ZONE 'America/Chicago') = DATE(%(date)s AT TIME ZONE 'America/Chicago')
                """,
                {
                    'player': player_name,
                    'series_id': series_id,
                    'date': one_day_earlier
                }
            )
            
            # Check one day later (less likely but possible)
            one_day_later = intended_date_obj + timedelta(days=1)
            later_record = execute_query_one(
                """
                SELECT id, match_date, availability_status 
                FROM player_availability 
                WHERE player_name = %(player)s 
                AND series_id = %(series_id)s 
                AND DATE(match_date AT TIME ZONE 'America/Chicago') = DATE(%(date)s AT TIME ZONE 'America/Chicago')
                """,
                {
                    'player': player_name,
                    'series_id': series_id,
                    'date': one_day_later
                }
            )
            
            discrepant_record = None
            discrepancy_type = None
            
            if earlier_record and earlier_record['availability_status'] == availability_status:
                discrepant_record = earlier_record
                discrepancy_type = "one_day_earlier"
                discrepant_date = one_day_earlier
                print(f"🔧 Found record one day earlier: {one_day_earlier} (should be {intended_date_obj})")
            elif later_record and later_record['availability_status'] == availability_status:
                discrepant_record = later_record
                discrepancy_type = "one_day_later" 
                discrepant_date = one_day_later
                print(f"🔧 Found record one day later: {one_day_later} (should be {intended_date_obj})")
            
            if discrepant_record:
                print(f"🔧 Correcting date discrepancy ({discrepancy_type})")
                print(f"   Updating record ID {discrepant_record['id']} from {discrepant_date} to {intended_date_obj}")
                
                # Update the discrepant record to have the correct date
                correction_result = execute_query(
                    """
                    UPDATE player_availability 
                    SET match_date = %(correct_date)s, updated_at = NOW()
                    WHERE id = %(id)s
                    """,
                    {
                        'correct_date': intended_date_obj,
                        'id': discrepant_record['id']
                    }
                )
                
                # Verify the correction worked
                corrected_verification = execute_query_one(
                    """
                    SELECT match_date, availability_status 
                    FROM player_availability 
                    WHERE id = %(id)s
                    """,
                    {'id': discrepant_record['id']}
                )
                
                if corrected_verification and corrected_verification['match_date'] == intended_date_obj:
                    print(f"✅ Date correction successful: {corrected_verification['match_date']}")
                    
                    # Log the correction
                    log_date_operation(
                        operation="POST_STORAGE_CORRECTION",
                        input_data=f"discrepant_date={discrepant_date}, intended_date={intended_date_obj}",
                        output_data=f"corrected_date={corrected_verification['match_date']}",
                        verification_info={
                            'discrepancy_found': True,
                            'discrepancy_type': discrepancy_type,
                            'correction_successful': True
                        }
                    )
                    
                    return True
                else:
                    print(f"❌ Date correction failed")
                    
                    # Log the failed correction
                    log_date_operation(
                        operation="POST_STORAGE_CORRECTION_FAILED",
                        input_data=f"discrepant_date={discrepant_date}, intended_date={intended_date_obj}",
                        output_data="correction_failed",
                        verification_info={
                            'discrepancy_found': True,
                            'discrepancy_type': discrepancy_type,
                            'correction_successful': False
                        }
                    )
                    
                    return False
            else:
                print("❌ No matching record found (including date discrepancies)")
                
                # Log the verification failure
                log_date_operation(
                    operation="POST_STORAGE_VERIFICATION_FAILED",
                    input_data=f"intended_date={intended_date_obj}, status={availability_status}",
                    output_data="no_record_found",
                    verification_info={
                        'storage_successful': False,
                        'discrepancy_found': False,
                        'checked_dates': [str(intended_date_obj), str(one_day_earlier), str(one_day_later)]
                    }
                )
                
                return False
            
    except Exception as e:
        print(f"❌ Error in update_player_availability: {str(e)}")
        print(traceback.format_exc())
        return False

def get_user_availability(player_name, matches, series):
    """Get availability for a user across multiple matches"""
    availability = []
    
    # Map numeric status to string status for template
    status_map = {
        1: 'available',
        2: 'unavailable', 
        3: 'not_sure',
        None: None  # No selection made
    }
    
    for match in matches:
        match_date = match.get('date', '')
        # Get this player's availability for this specific match
        numeric_status = get_player_availability(player_name, match_date, series)
        
        # Convert numeric status to string status that template expects
        string_status = status_map.get(numeric_status)
        availability.append({'status': string_status})
        
    return availability

def init_availability_routes(app):
    @app.route('/mobile/availability', methods=['GET', 'POST'])
    @login_required
    def mobile_availability():
        """Handle mobile availability page and updates"""
        if request.method == 'POST':
            try:
                data = request.json
                player_name = data.get('player_name')
                match_date = data.get('match_date')
                availability_status = data.get('availability_status')
                series = data.get('series')
                
                # Validate required fields
                required_fields = ['player_name', 'match_date', 'availability_status', 'series']
                if not all(field in data for field in required_fields):
                    missing = [f for f in required_fields if f not in data]
                    print(f"Missing required fields: {missing}")
                    return jsonify({'error': 'Missing required fields'}), 400
                
                # Validate availability_status is in valid range
                if availability_status not in [1, 2, 3]:
                    return jsonify({'error': 'Invalid availability status'}), 400
                
                success = update_player_availability(player_name, match_date, availability_status, series)
                if success:
                    return jsonify({'status': 'success'})
                return jsonify({'error': 'Failed to update availability'}), 500
            except Exception as e:
                return jsonify({'error': str(e)}), 500
        else:
            user = session.get('user')
            player_name = f"{user['first_name']} {user['last_name']}"
            series = user['series']

            # Get matches for the user's club/series
            matches = get_matches_for_user_club(user)
            
            # DEBUG: Log the actual date formats being passed to template
            print(f"\n=== DEBUG: MATCHES PASSED TO TEMPLATE ===")
            for i, match in enumerate(matches):
                print(f"Match {i}: date='{match.get('date')}', type={type(match.get('date'))}")
            print("=== END DEBUG ===\n")
            
            # Get this user's availability for each match
            availability = get_user_availability(player_name, matches, series)

            # Create match-availability pairs
            match_avail_pairs = list(zip(matches, availability))

            session_data = {
                'user': user,
                'authenticated': True,
                'matches': matches,
                'availability': availability,
                'players': [{'name': player_name}]  # Add player name to context
            }
            return render_template('mobile/availability.html', 
                                 session_data=session_data,
                                 match_avail_pairs=match_avail_pairs,
                                 players=[{'name': player_name}]  # Also pass directly to template
                                 )

    @app.route('/api/availability', methods=['GET', 'POST'])
    @login_required
    def handle_availability():
        """Handle availability API requests"""
        if request.method == 'POST':
            try:
                print(f"\n=== AVAILABILITY API POST ===")
                print(f"Request Content-Type: {request.content_type}")
                print(f"Request headers: {dict(request.headers)}")
                
                # Try to get data from various sources
                data = None
                error_details = []
                
                # Try JSON first
                if request.is_json:
                    try:
                        data = request.get_json()
                        print("Got JSON data")
                    except Exception as e:
                        error_msg = f"Error parsing JSON: {str(e)}"
                        print(error_msg)
                        error_details.append(error_msg)
                
                # Try form data if JSON failed
                if not data and request.form:
                    data = request.form.to_dict()
                    print("Got form data")
                
                # Try raw data if both failed
                if not data:
                    try:
                        raw_data = request.get_data(as_text=True)
                        print(f"Raw request data: {raw_data}")
                        data = json.loads(raw_data)
                        print("Parsed raw data as JSON")
                    except Exception as e:
                        error_msg = f"Error parsing raw data: {str(e)}"
                        print(error_msg)
                        error_details.append(error_msg)
                
                if not data:
                    error_msg = "No data received from any source"
                    if error_details:
                        error_msg += f". Errors: {', '.join(error_details)}"
                    print(error_msg)
                    return jsonify({'error': error_msg}), 400
                
                print(f"Final parsed data: {data}")
                print(f"Data type: {type(data)}")
                print(f"Keys in data: {list(data.keys())}")
                
                # DEBUG: Log the exact date being received
                received_date = data.get('match_date')
                print(f"DEBUG BACKEND: Received match_date='{received_date}', type={type(received_date)}")
                
                # Validate required fields
                required_fields = ['player_name', 'match_date', 'availability_status', 'series']
                missing = [f for f in required_fields if f not in data]
                print(f"Required fields: {required_fields}")
                print(f"Missing fields: {missing}")
                
                if missing:
                    error_msg = f"Missing required fields: {missing}"
                    print(error_msg)
                    return jsonify({'error': error_msg}), 400
                
                # Convert availability_status to int if it's a string
                try:
                    status = int(data['availability_status'])
                    data['availability_status'] = status
                except (ValueError, TypeError) as e:
                    error_msg = f"Error converting availability_status to int: {str(e)}"
                    print(error_msg)
                    return jsonify({'error': error_msg}), 400
                
                # Verify the player_name matches the logged-in user
                user = session['user']
                if data['player_name'] != f"{user['first_name']} {user['last_name']}":
                    error_msg = f"Player name mismatch: {data['player_name']} vs {user['first_name']} {user['last_name']}"
                    print(error_msg)
                    return jsonify({'error': error_msg}), 403
                
                # Validate availability_status is in valid range
                if status not in [1, 2, 3]:
                    error_msg = f"Invalid availability status: {status}"
                    print(error_msg)
                    return jsonify({'error': error_msg}), 400
                
                success = update_player_availability(
                    data['player_name'],
                    data['match_date'],
                    status,  # Pass status directly
                    data['series']
                )
                
                if success:
                    return jsonify({'status': 'success'})
                return jsonify({'error': 'Failed to update availability'}), 500
            except Exception as e:
                error_msg = f"Error in availability POST handler: {str(e)}"
                print(error_msg)
                print(f"Full traceback: {traceback.format_exc()}")
                return jsonify({'error': error_msg}), 500
        else:
            try:
                player_name = request.args.get('player_name')
                match_date = request.args.get('match_date')
                series = request.args.get('series')
                
                print(f"\n=== AVAILABILITY API GET ===")
                print(f"Query params: player_name={player_name}, match_date={match_date}, series={series}")
                
                is_available = get_player_availability(player_name, match_date, series)
                return jsonify({'is_available': is_available})
            except Exception as e:
                print(f"Error in availability GET handler: {str(e)}")
                return jsonify({'error': str(e)}), 500 
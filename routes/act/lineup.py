from flask import jsonify, request, session, render_template
from datetime import datetime
import os
import json
import time
from utils.db import execute_query, execute_query_one, execute_update
from utils.logging import log_user_activity
# from utils.ai import get_or_create_assistant, client  # DISABLED FOR RAILWAY DEPLOYMENT
from utils.series_matcher import normalize_series_for_display
from utils.auth import login_required

def get_user_instructions(user_email, team_id=None):
    """Get lineup instructions for a user"""
    try:
        query = """
            SELECT id, instruction 
            FROM user_instructions 
            WHERE user_email = %(user_email)s AND is_active = true
        """
        params = {'user_email': user_email}
        
        if team_id:
            query += ' AND team_id = %(team_id)s'
            params['team_id'] = team_id
            
        instructions = execute_query(query, params)
        return [{'id': instr['id'], 'instruction': instr['instruction']} for instr in instructions]
    except Exception as e:
        print(f"Error getting user instructions: {str(e)}")
        return []

def add_user_instruction(user_email, instruction, team_id=None):
    """Add a new lineup instruction"""
    try:
        success = execute_update(
            """
            INSERT INTO user_instructions (user_email, instruction, team_id, is_active)
            VALUES (%(user_email)s, %(instruction)s, %(team_id)s, true)
            """,
            {
                'user_email': user_email,
                'instruction': instruction,
                'team_id': team_id
            }
        )
        return success
    except Exception as e:
        print(f"Error adding instruction: {str(e)}")
        return False

def delete_user_instruction(user_email, instruction, team_id=None):
    """Delete a lineup instruction"""
    try:
        query = """
            UPDATE user_instructions 
            SET is_active = false 
            WHERE user_email = %(user_email)s AND instruction = %(instruction)s
        """
        params = {
            'user_email': user_email,
            'instruction': instruction
        }
        
        if team_id:
            query += ' AND team_id = %(team_id)s'
            params['team_id'] = team_id
            
        success = execute_update(query, params)
        return success
    except Exception as e:
        print(f"Error deleting instruction: {str(e)}")
        return False

def init_lineup_routes(app):
    @app.route('/mobile/lineup')
    @login_required
    def serve_mobile_lineup():
        """Serve the mobile lineup page"""
        try:
            session_data = {
                'user': session['user'],
                'authenticated': True
            }
            print(f"\n=== DEBUG: Lineup page session data ===")
            print(f"User: {session['user']}")
            print(f"User club: {session['user'].get('club')}")
            print(f"User series: {session['user'].get('series')}")
            print("=== END DEBUG ===\n")
            
            log_user_activity(session['user']['email'], 'page_visit', page='mobile_lineup')
            return render_template('mobile/lineup.html', session_data=session_data)
        except Exception as e:
            print(f"Error serving lineup page: {str(e)}")
            return jsonify({'error': str(e)}), 500

    @app.route('/mobile/lineup-escrow')
    @login_required
    def serve_mobile_lineup_escrow():
        """Serve the mobile Lineup Escrow page"""
        session_data = {
            'user': session['user'],
            'authenticated': True
        }
        log_user_activity(
            session['user']['email'],
            'page_visit',
            page='mobile_lineup_escrow',
            details='Accessed mobile lineup escrow page'
        )
        return render_template('mobile/lineup_escrow.html', session_data=session_data)

    @app.route('/api/lineup-instructions', methods=['GET', 'POST', 'DELETE'])
    @login_required
    def lineup_instructions():
        """Handle lineup instructions"""
        if request.method == 'GET':
            try:
                user_email = session['user']['email']
                team_id = request.args.get('team_id')
                instructions = get_user_instructions(user_email, team_id=team_id)
                return jsonify({'instructions': [i['instruction'] for i in instructions]})
            except Exception as e:
                return jsonify({'error': str(e)}), 500
                
        elif request.method == 'POST':
            try:
                user_email = session['user']['email']
                data = request.json
                instruction = data.get('instruction')
                team_id = data.get('team_id')
                
                if not instruction:
                    return jsonify({'error': 'Instruction is required'}), 400
                    
                success = add_user_instruction(user_email, instruction, team_id=team_id)
                if not success:
                    return jsonify({'error': 'Failed to add instruction'}), 500
                    
                return jsonify({'status': 'success'})
            except Exception as e:
                return jsonify({'error': str(e)}), 500
                
        elif request.method == 'DELETE':
            try:
                user_email = session['user']['email']
                data = request.json
                instruction = data.get('instruction')
                team_id = data.get('team_id')
                
                if not instruction:
                    return jsonify({'error': 'Instruction is required'}), 400
                    
                success = delete_user_instruction(user_email, instruction, team_id=team_id)
                if not success:
                    return jsonify({'error': 'Failed to delete instruction'}), 500
                    
                return jsonify({'status': 'success'})
            except Exception as e:
                return jsonify({'error': str(e)}), 500

    @app.route('/api/generate-lineup', methods=['POST'])
    @login_required
    def generate_lineup():
        """DISABLED: Generate lineup using AI"""
        return jsonify({
            'error': 'AI lineup generation has been disabled for Railway deployment. This feature is temporarily unavailable.',
            'suggestion': 'AI lineup generation is currently disabled. Please create lineups manually.',
            'debug': {
                'status': 'disabled',
                'reason': 'OpenAI functionality disabled for Railway deployment'
            }
        }), 503 

    @app.route('/api/test-lineup-data')
    @login_required
    def test_lineup_data():
        """Test endpoint to debug lineup data"""
        try:
            user = session['user']
            series = user.get('series', '')
            club = user.get('club', '')
            team_id = f"{club} - {series.split(' ').pop()}" if club and series else ''
            
            return jsonify({
                'user': user,
                'series': series,
                'club': club,
                'team_id': team_id,
                'api_url': f"/api/players?series={series}&team_id={team_id}"
            })
        except Exception as e:
            return jsonify({'error': str(e)}), 500
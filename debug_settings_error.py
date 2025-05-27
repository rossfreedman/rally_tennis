#!/usr/bin/env python3

import os
from database_utils import execute_query_one

def test_settings_query():
    """Test the exact query used in get-user-settings"""
    
    # Force Railway environment to test against production database
    os.environ['RAILWAY_ENVIRONMENT'] = 'production'
    # Remove local database URL to force Railway connection
    if 'DATABASE_URL' in os.environ:
        del os.environ['DATABASE_URL']
    
    user_email = 'rossfreedman@gmail.com'
    
    print(f"Testing settings query for user: {user_email}")
    print("Forcing Railway database connection...")
    
    try:
        # This is the exact query from the settings route
        user_data = execute_query_one('''
            SELECT u.first_name, u.last_name, u.email, u.club_automation_password,
                   c.name as club, s.name as series
            FROM users u
            LEFT JOIN clubs c ON u.club_id = c.id
            LEFT JOIN series s ON u.series_id = s.id
            WHERE u.email = %(email)s
        ''', {'email': user_email})
        
        print("✅ Query executed successfully!")
        print(f"Result: {user_data}")
        
        if user_data:
            response_data = {
                'first_name': user_data['first_name'] or '',
                'last_name': user_data['last_name'] or '',
                'email': user_data['email'] or '',
                'club_automation_password': user_data['club_automation_password'] or '',
                'club': user_data['club'] or '',
                'series': user_data['series'] or ''
            }
            print(f"Response data: {response_data}")
        else:
            print("❌ No user data found")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        print(f"Error type: {type(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_settings_query() 
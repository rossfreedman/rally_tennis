#!/usr/bin/env python3

import os
import psycopg2
from psycopg2.extras import RealDictCursor

def test_railway_connection():
    """Test direct connection to Railway database"""
    
    # Use the Railway DATABASE_PUBLIC_URL directly
    database_url = "postgresql://postgres:ihxpdgQMcXGoMCNvYqzWWmidKTnkdsoM@metro.proxy.rlwy.net:19439/railway"
    
    print(f"Testing direct Railway connection...")
    print(f"Database: railway")
    
    try:
        conn = psycopg2.connect(database_url, sslmode='require', connect_timeout=30)
        print("✅ Connected to Railway database successfully!")
        
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            # Test the exact query from settings
            cursor.execute('''
                SELECT u.first_name, u.last_name, u.email, u.club_automation_password,
                       c.name as club, s.name as series
                FROM users u
                LEFT JOIN clubs c ON u.club_id = c.id
                LEFT JOIN series s ON u.series_id = s.id
                WHERE u.email = %s
            ''', ('rossfreedman@gmail.com',))
            
            user_data = cursor.fetchone()
            
            if user_data:
                print("✅ User data found:")
                print(f"  Name: {user_data['first_name']} {user_data['last_name']}")
                print(f"  Email: {user_data['email']}")
                print(f"  Club: {user_data['club']}")
                print(f"  Series: {user_data['series']}")
                
                # Test response data formatting
                response_data = {
                    'first_name': user_data['first_name'] or '',
                    'last_name': user_data['last_name'] or '',
                    'email': user_data['email'] or '',
                    'club_automation_password': user_data['club_automation_password'] or '',
                    'club': user_data['club'] or '',
                    'series': user_data['series'] or ''
                }
                print(f"✅ Response data: {response_data}")
            else:
                print("❌ No user data found")
        
        conn.close()
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_railway_connection() 
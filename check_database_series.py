#!/usr/bin/env python3

from utils.db import execute_query

def check_database_series():
    """Check what series and clubs are in the database"""
    
    print("🔍 Checking Database Series and Clubs")
    print("=" * 50)
    
    try:
        # Get all clubs
        clubs = execute_query("SELECT id, name FROM clubs ORDER BY name")
        print(f"📍 Clubs in database ({len(clubs)}):")
        for club in clubs:
            print(f"  {club['id']}: {club['name']}")
        
        # Get all series
        series = execute_query("SELECT id, name FROM series ORDER BY name")
        print(f"\n🎾 Series in database ({len(series)}):")
        for s in series:
            print(f"  {s['id']}: {s['name']}")
        
        # Get all users with their club and series
        users = execute_query("""
            SELECT u.email, u.first_name, u.last_name, c.name as club, s.name as series
            FROM users u
            JOIN clubs c ON u.club_id = c.id
            JOIN series s ON u.series_id = s.id
            ORDER BY u.email
        """)
        print(f"\n👥 Users in database ({len(users)}):")
        for user in users:
            print(f"  {user['email']}: {user['first_name']} {user['last_name']} - {user['club']} - {user['series']}")
            
    except Exception as e:
        print(f"❌ Error checking database: {str(e)}")

if __name__ == "__main__":
    check_database_series() 
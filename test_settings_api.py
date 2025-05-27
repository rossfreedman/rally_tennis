#!/usr/bin/env python3
"""
Test script to verify the settings API functionality
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database_utils import execute_query_one, execute_query
import requests
import json

def test_user_data():
    """Test if we can retrieve user data from the database"""
    try:
        # Get a sample user
        users = execute_query("SELECT email FROM users LIMIT 5")
        print(f"Found {len(users)} users in database")
        
        if not users:
            print("No users found in database")
            return
        
        # Test with first user
        test_email = users[0]['email']
        print(f"Testing with user: {test_email}")
        
        # Test the same query as the settings API
        user_data = execute_query_one('''
            SELECT u.first_name, u.last_name, u.email, u.club_automation_password,
                   c.name as club, s.name as series
            FROM users u
            LEFT JOIN clubs c ON u.club_id = c.id
            LEFT JOIN series s ON u.series_id = s.id
            WHERE u.email = %(email)s
        ''', {'email': test_email})
        
        if user_data:
            print("✅ User data retrieved successfully:")
            print(f"  Name: {user_data['first_name']} {user_data['last_name']}")
            print(f"  Email: {user_data['email']}")
            print(f"  Club: {user_data['club']}")
            print(f"  Series: {user_data['series']}")
            print(f"  Has club automation password: {'Yes' if user_data['club_automation_password'] else 'No'}")
        else:
            print("❌ No user data found")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def test_clubs_and_series():
    """Test if clubs and series data is available"""
    try:
        clubs = execute_query("SELECT name FROM clubs ORDER BY name LIMIT 5")
        series = execute_query("SELECT name FROM series ORDER BY name LIMIT 5")
        
        print(f"\n✅ Found {len(clubs)} clubs (showing first 5):")
        for club in clubs:
            print(f"  - {club['name']}")
            
        print(f"\n✅ Found {len(series)} series (showing first 5):")
        for s in series:
            print(f"  - {s['name']}")
            
    except Exception as e:
        print(f"❌ Error getting clubs/series: {str(e)}")

def test_settings_apis():
    """Test the settings API endpoints that the mobile page uses"""
    
    base_url = "https://rallytennis.up.railway.app"
    
    # First, let's try to login to get a valid session
    login_data = {
        "email": "rossfreedman@gmail.com",
        "password": "password123"  # Replace with actual password
    }
    
    session = requests.Session()
    
    print("=== Testing Login ===")
    login_response = session.post(f"{base_url}/api/login", json=login_data)
    print(f"Login Status: {login_response.status_code}")
    print(f"Login Response: {login_response.text}")
    
    if login_response.status_code == 200:
        print("\n=== Testing /api/get-user-settings ===")
        settings_response = session.get(f"{base_url}/api/get-user-settings")
        print(f"Settings Status: {settings_response.status_code}")
        print(f"Settings Response: {settings_response.text}")
        
        print("\n=== Testing /api/get-clubs ===")
        clubs_response = session.get(f"{base_url}/api/get-clubs")
        print(f"Clubs Status: {clubs_response.status_code}")
        print(f"Clubs Response: {clubs_response.text}")
        
        print("\n=== Testing /api/get-series ===")
        series_response = session.get(f"{base_url}/api/get-series")
        print(f"Series Status: {series_response.status_code}")
        print(f"Series Response: {series_response.text}")
    else:
        print("Login failed, cannot test authenticated endpoints")

if __name__ == "__main__":
    print("Testing Settings API Database Queries")
    print("=" * 40)
    test_user_data()
    test_clubs_and_series()
    test_settings_apis() 
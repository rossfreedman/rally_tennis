#!/usr/bin/env python3

import requests
import json

def test_lineup_functionality():
    """Test the lineup functionality to ensure it works correctly"""
    
    base_url = "http://127.0.0.1:8080"
    
    print("🧪 Testing Lineup Functionality")
    print("=" * 50)
    
    # Test 1: Check if the test endpoint works
    try:
        response = requests.get(f"{base_url}/api/test-lineup-data")
        print(f"✅ Test endpoint status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   User data: {data}")
        else:
            print(f"   Error: {response.text}")
    except Exception as e:
        print(f"❌ Test endpoint failed: {e}")
    
    # Test 2: Check if players API works with sample data
    try:
        # Test with Birchwood Series 2B (from our sample data)
        params = {
            'series': 'Series 2B',
            'team_id': 'Birchwood - 2B'
        }
        response = requests.get(f"{base_url}/api/players", params=params)
        print(f"\n✅ Players API status: {response.status_code}")
        if response.status_code == 200:
            players = response.json()
            print(f"   Found {len(players)} players")
            if players:
                print(f"   Sample player: {players[0]}")
        else:
            print(f"   Error: {response.text}")
    except Exception as e:
        print(f"❌ Players API failed: {e}")
    
    # Test 3: Check if lineup page loads
    try:
        response = requests.get(f"{base_url}/mobile/lineup")
        print(f"\n✅ Lineup page status: {response.status_code}")
        if response.status_code == 200:
            print("   Lineup page loads successfully")
        else:
            print(f"   Error: {response.text}")
    except Exception as e:
        print(f"❌ Lineup page failed: {e}")

if __name__ == "__main__":
    test_lineup_functionality() 
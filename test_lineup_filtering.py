#!/usr/bin/env python3

import requests
import json

# Test the lineup filtering
base_url = "http://127.0.0.1:8080"

# Create a session
session = requests.Session()

# First, let's check what happens when we try to access the lineup page
print("Testing lineup page access...")

try:
    # Try to access the mobile lineup page
    response = session.get(f"{base_url}/mobile/lineup")
    print(f"Lineup page status: {response.status_code}")
    
    if response.status_code == 200:
        print("✅ Lineup page accessible")
        # Check if it contains the expected content
        if "Create Lineup" in response.text:
            print("✅ Lineup page contains expected content")
        else:
            print("❌ Lineup page missing expected content")
    else:
        print(f"❌ Lineup page not accessible: {response.status_code}")
        print("Response:", response.text[:200])

    # Try to access the players API directly
    print("\nTesting players API...")
    response = session.get(f"{base_url}/api/players?series=tennaqua%20series%202B")
    print(f"Players API status: {response.status_code}")
    
    if response.status_code == 200:
        players = response.json()
        print(f"✅ Players API returned {len(players)} players")
        if players:
            print("Sample player:", players[0])
    else:
        print(f"❌ Players API error: {response.status_code}")
        try:
            error_data = response.json()
            print("Error:", error_data)
        except:
            print("Response:", response.text[:200])

except Exception as e:
    print(f"❌ Error testing: {str(e)}")

print("\nTest completed.") 
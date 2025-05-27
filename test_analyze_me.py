#!/usr/bin/env python3
"""
Test script to verify the analyze-me endpoint functionality
"""

import requests
import json

def test_analyze_me_endpoint():
    """Test the /mobile/analyze-me endpoint"""
    base_url = "http://127.0.0.1:8080"
    
    # Create a session to maintain cookies
    session = requests.Session()
    
    # First, try to login as Ross Freedman
    login_data = {
        "email": "rossfreedman@gmail.com",
        "password": "password123"  # You might need to adjust this
    }
    
    print("Attempting to login...")
    login_response = session.post(f"{base_url}/api/login", json=login_data)
    
    if login_response.status_code == 200:
        print("✅ Login successful")
        print(f"Response: {login_response.json()}")
        
        # Now test the analyze-me endpoint
        print("\nTesting /mobile/analyze-me endpoint...")
        analyze_response = session.get(f"{base_url}/mobile/analyze-me")
        
        if analyze_response.status_code == 200:
            print("✅ Analyze-me endpoint successful")
            print("Response received (HTML content)")
        else:
            print(f"❌ Analyze-me endpoint failed: {analyze_response.status_code}")
            print(f"Response: {analyze_response.text}")
            
    else:
        print(f"❌ Login failed: {login_response.status_code}")
        print(f"Response: {login_response.text}")

if __name__ == "__main__":
    test_analyze_me_endpoint() 
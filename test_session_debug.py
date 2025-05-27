#!/usr/bin/env python3

import requests
import json

def test_session_debug():
    """Test what the actual session data contains"""
    
    base_url = "http://127.0.0.1:8080"
    
    print("🔍 Testing Session Debug")
    print("=" * 50)
    
    try:
        # Try to access the debug session endpoint
        response = requests.get(f"{base_url}/debug-session")
        print(f"Debug session status: {response.status_code}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                print("✅ Session data retrieved:")
                print(json.dumps(data, indent=2))
            except:
                print("Response is not JSON:")
                print(response.text[:500])
        else:
            print(f"❌ Debug session error: {response.status_code}")
            print("Response:", response.text[:200])
            
        # Try the test lineup data endpoint
        print(f"\n🧪 Testing lineup data endpoint...")
        response = requests.get(f"{base_url}/api/test-lineup-data")
        print(f"Test lineup data status: {response.status_code}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                print("✅ Lineup test data:")
                print(json.dumps(data, indent=2))
            except:
                print("Response is not JSON:")
                print(response.text[:500])
        else:
            print(f"❌ Test lineup data error: {response.status_code}")
            print("Response:", response.text[:200])

    except Exception as e:
        print(f"❌ Error testing: {str(e)}")

if __name__ == "__main__":
    test_session_debug() 
#!/usr/bin/env python3
"""
Test script to verify health check endpoint
"""

import requests
import threading
import time
import sys

def test_health_check():
    """Test the health check endpoint"""
    print("=== Testing Health Check Endpoint ===")
    
    # Import the Flask app
    from server import app
    
    # Start the server in a thread
    def start_server():
        app.run(host='127.0.0.1', port=5001, debug=False, use_reloader=False)
    
    print("Starting test server...")
    server_thread = threading.Thread(target=start_server, daemon=True)
    server_thread.start()
    
    # Wait for server to start
    time.sleep(3)
    
    # Test health endpoint
    try:
        print("Testing /health endpoint...")
        response = requests.get('http://127.0.0.1:5001/health', timeout=10)
        print(f'✅ Health check status: {response.status_code}')
        print(f'📋 Health check response: {response.json()}')
        
        if response.status_code == 200:
            print("✅ Health check endpoint is working!")
        else:
            print("❌ Health check endpoint returned non-200 status")
            
    except Exception as e:
        print(f'❌ Health check failed: {e}')
    
    print("=== Test Complete ===")

if __name__ == "__main__":
    test_health_check() 
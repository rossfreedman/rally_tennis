#!/usr/bin/env python3
"""
Test script to verify the get_player_analysis function directly
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Import the function directly
from server import get_player_analysis

def test_get_player_analysis():
    """Test the get_player_analysis function directly"""
    
    # Create a test user object that matches Ross Freedman
    test_user = {
        'first_name': 'Ross',
        'last_name': 'Freedman',
        'email': 'rossfreedman@gmail.com',
        'club': 'Tennaqua',
        'series': 'Series 2B'
    }
    
    print("Testing get_player_analysis function...")
    print(f"Test user: {test_user['first_name']} {test_user['last_name']}")
    
    try:
        result = get_player_analysis(test_user)
        
        print("\n✅ Function executed successfully!")
        print(f"Result keys: {list(result.keys())}")
        
        if result.get('error'):
            print(f"❌ Error in result: {result['error']}")
        else:
            print("✅ No errors in result")
            
            # Check current_season
            if result.get('current_season'):
                cs = result['current_season']
                print(f"Current Season - Matches: {cs.get('matches')}, Wins: {cs.get('wins')}, Win Rate: {cs.get('winRate')}%")
            else:
                print("❌ No current_season data")
                
            # Check career_stats
            if result.get('career_stats'):
                cs = result['career_stats']
                print(f"Career Stats - Matches: {cs.get('matches')}, Wins: {cs.get('wins')}, Win Rate: {cs.get('winRate')}%")
            else:
                print("❌ No career_stats data")
                
            # Check court_analysis
            if result.get('court_analysis'):
                print(f"Court Analysis - Courts: {list(result['court_analysis'].keys())}")
            else:
                print("❌ No court_analysis data")
        
    except Exception as e:
        print(f"❌ Function failed with error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_get_player_analysis() 
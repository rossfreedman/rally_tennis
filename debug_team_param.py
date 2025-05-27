#!/usr/bin/env python3

import json
from urllib.parse import unquote_plus

def test_team_parameter():
    """Test how team parameter is handled"""
    
    # Load the data files
    with open('data/series_stats.json') as f:
        all_stats = json.load(f)
    
    # Get all teams
    all_teams = sorted({s['team'] for s in all_stats if 'BYE' not in s['team'].upper()})
    print("Available teams:")
    for team in all_teams:
        print(f"  - '{team}'")
    
    # Test URL parameter variations
    test_params = [
        "Ravinia+Green+S2B",
        "Ravinia Green S2B",
        "Birchwood S2B"
    ]
    
    print("\nTesting URL parameters:")
    for param in test_params:
        decoded = unquote_plus(param)
        print(f"  '{param}' -> '{decoded}'")
        if decoded in all_teams:
            print(f"    ✓ Found in teams list")
        else:
            print(f"    ✗ NOT found in teams list")

if __name__ == "__main__":
    test_team_parameter() 
#!/usr/bin/env python3
"""
Simple test script to test the analyze-me endpoint with direct function call
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from server import get_player_analysis

def test_analyze_me():
    """Test the get_player_analysis function directly"""
    
    # Test user (Ross Freedman)
    test_user = {
        'first_name': 'Ross',
        'last_name': 'Freedman',
        'email': 'rossfreedman@gmail.com'
    }
    
    print(f"Testing get_player_analysis for: {test_user['first_name']} {test_user['last_name']}")
    print("=" * 60)
    
    try:
        result = get_player_analysis(test_user)
        
        print("✅ Function call successful!")
        print("\n📊 CURRENT SEASON STATS:")
        if result.get('current_season'):
            cs = result['current_season']
            print(f"  Matches: {cs.get('matches', 'N/A')}")
            print(f"  Wins: {cs.get('wins', 'N/A')}")
            print(f"  Losses: {cs.get('losses', 'N/A')}")
            print(f"  Win Rate: {cs.get('winRate', 'N/A')}%")
        else:
            print("  No current season data")
            
        print("\n🏓 COURT ANALYSIS:")
        court_analysis = result.get('court_analysis', {})
        print(f"  Total courts in analysis: {len(court_analysis)}")
        for court, stats in court_analysis.items():
            print(f"  {court}: matches={stats.get('matches', 0)}, record={stats.get('record')}, winRate={stats.get('winRate')}%")
            if stats.get('matches', 0) > 0:
                print(f"    Record: {stats.get('record')} (Win Rate: {stats.get('winRate')}%)")
                if stats.get('topPartners'):
                    print(f"    Top Partners: {[p['name'] for p in stats['topPartners'][:2]]}")
            else:
                print(f"    No matches on this court")
        
        print("\n📈 CAREER STATS:")
        if result.get('career_stats'):
            cs = result['career_stats']
            print(f"  Matches: {cs.get('matches', 'N/A')}")
            print(f"  Win Rate: {cs.get('winRate', 'N/A')}%")
            print(f"  PTI: {cs.get('pti', 'N/A')}")
        else:
            print("  No career stats data")
            
        if result.get('error'):
            print(f"\n❌ Error: {result['error']}")
            
    except Exception as e:
        print(f"❌ Function call failed: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_analyze_me() 
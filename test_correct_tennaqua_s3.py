#!/usr/bin/env python3

import requests
from bs4 import BeautifulSoup
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import re
import json

def create_driver():
    """Create and configure a new Chrome WebDriver instance."""
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1920x1080')
    return webdriver.Chrome(options=options)

def test_correct_tennaqua_s3():
    """Test the correct Tennaqua S3 team ID to verify all 12 players are captured."""
    
    driver = create_driver()
    
    try:
        # Correct team ID for men's Tennaqua S3
        team_id = 'nndz-WkMrNnlibi8%3D'
        url = f'https://nstf.tenniscores.com/?mod=nndz-TjJiOWtORzkwTlJFb0NVU1NzOD0%3D&team={team_id}'
        
        print(f"Testing CORRECT Tennaqua S3 Men's Team")
        print(f"URL: {url}")
        
        # Load the page
        driver.get(url)
        time.sleep(3)  # Wait for page to load
        
        # Get the page source after JavaScript has run
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        # Find all player links - they typically have player.php in the href
        player_links = soup.find_all('a', href=re.compile(r'player\.php'))
        
        print(f"Found {len(player_links)} player links")
        
        # Expected players from the roster
        expected_players = [
            'Michael Razzoog',
            'Jeremy Baker', 
            'Howard Dakoff',
            'Nelson Gomez',
            'Jeffery Kivetz',
            'Jason Kray',
            'Wes Maher',
            'Greg Meagher',
            'David Ransburg',
            'Dave Rogers',
            'Dan Romanoff',
            'Marc Sher'
        ]
        
        # Extract player information
        players_found = []
        for i, link in enumerate(player_links):
            try:
                # Get player name from link text
                player_name = link.text.strip()
                
                if not player_name or len(player_name) < 2:
                    continue
                
                # Look for captain designation in surrounding context
                parent_text = ""
                if link.parent:
                    parent_text = link.parent.get_text()
                
                is_captain = "(C)" in parent_text
                is_co_captain = "(CC)" in parent_text
                
                role = "Captain" if is_captain else "Co-Captain" if is_co_captain else "Player"
                
                players_found.append({
                    'name': player_name,
                    'role': role
                })
                
                print(f"  Player {i+1}: {player_name} | {role}")
                
            except Exception as e:
                print(f"  Error processing player link {i+1}: {str(e)}")
                continue
        
        print(f"\nTotal players found: {len(players_found)}")
        print(f"Expected players: {len(expected_players)}")
        
        # Check if Michael Razzoog is found
        michael_found = any('Michael' in p['name'] and 'Razzoog' in p['name'] for p in players_found)
        print(f"Michael Razzoog found: {michael_found}")
        
        # Check which expected players are missing
        found_names = [p['name'] for p in players_found]
        missing_players = []
        for expected in expected_players:
            if not any(expected.lower() in found.lower() for found in found_names):
                missing_players.append(expected)
        
        if missing_players:
            print(f"Missing players: {missing_players}")
        else:
            print("All expected players found!")
        
        # Save results for verification
        with open('correct_tennaqua_s3_test.json', 'w') as f:
            json.dump(players_found, f, indent=2)
        
        return players_found
        
    except Exception as e:
        print(f"Error testing correct Tennaqua S3 team: {str(e)}")
        return []
    
    finally:
        driver.quit()

if __name__ == "__main__":
    players = test_correct_tennaqua_s3()
    print(f"\nResult: Found {len(players)} Tennaqua S3 players with correct team ID") 
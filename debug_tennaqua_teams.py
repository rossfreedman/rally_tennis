#!/usr/bin/env python3

import requests
from bs4 import BeautifulSoup
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import re

def create_driver():
    """Create and configure a new Chrome WebDriver instance."""
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1920x1080')
    return webdriver.Chrome(options=options)

def test_tennaqua_team(team_id, team_name):
    """Test a specific Tennaqua team ID to see what players are found."""
    
    driver = create_driver()
    
    try:
        # Construct URL for the team
        url = f'https://nstf.tenniscores.com/?mod=nndz-TjJiOWtORzkwTlJFb0NVU1NzOD0%3D&team={team_id}'
        
        print(f"\n=== Testing {team_name} ===")
        print(f"URL: {url}")
        
        # Load the page
        driver.get(url)
        time.sleep(3)  # Wait for page to load
        
        # Get the page source after JavaScript has run
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        # Find all player links - they typically have player.php in the href
        player_links = soup.find_all('a', href=re.compile(r'player\.php'))
        
        print(f"Found {len(player_links)} player links")
        
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
        
        print(f"Total players found: {len(players_found)}")
        
        # Check if Michael Razzoog is in this team
        michael_found = any('Michael' in p['name'] and 'Razzoog' in p['name'] for p in players_found)
        print(f"Michael Razzoog found: {michael_found}")
        
        return players_found
        
    except Exception as e:
        print(f"Error testing team {team_name}: {str(e)}")
        return []
    
    finally:
        driver.quit()

if __name__ == "__main__":
    # Test both potential Tennaqua S3 team IDs
    
    # Current team ID (women's team)
    current_team_id = 'nndz-WkNld3hycnc%3D'
    
    # Alternative team IDs to test
    test_team_ids = [
        ('nndz-WkM2NnliL3c%3D', 'Tennaqua S3 Alternative 1'),
        ('nndz-WkNDNHhyN3c%3D', 'Tennaqua S3 Alternative 2'),  
        ('nndz-WkNDNHhyejU%3D', 'Tennaqua S3 Alternative 3'),
        ('nndz-WkNDNHhyNzg%3D', 'Tennaqua S3 Alternative 4'),
    ]
    
    # Test current team first
    print("Testing current team configuration:")
    test_tennaqua_team(current_team_id, 'Tennaqua S3 Current (Women)')
    
    # Test alternative team IDs
    for team_id, team_name in test_team_ids:
        test_tennaqua_team(team_id, team_name) 
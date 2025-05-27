#!/usr/bin/env python3
"""
Test script to scrape just Tennaqua Series 3 team to verify we can get all 12 players.
"""

import requests
from bs4 import BeautifulSoup
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
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

def test_tennaqua_s3():
    """Test scraping Tennaqua Series 3 team."""
    
    # Tennaqua Series 3 team ID from the web search results
    team_id = 'nndz-WkNld3hycnc%3D'
    
    driver = create_driver()
    
    try:
        # Construct URL for the team
        url = f'https://nstf.tenniscores.com/?mod=nndz-TjJiOWtORzkwTlJFb0NVU1NzOD0%3D&team={team_id}'
        
        print(f"Testing Tennaqua S3 from {url}")
        
        # Load the page
        driver.get(url)
        time.sleep(3)  # Wait for page to load
        
        # Get the page source after JavaScript has run
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        # Print the page title to verify we're on the right page
        title = soup.find('title')
        if title:
            print(f"Page title: {title.text}")
        
        # Find all player links - they typically have player.php in the href
        player_links = soup.find_all('a', href=re.compile(r'player\.php'))
        
        print(f"Found {len(player_links)} player links")
        
        players = []
        
        # Extract player information
        for i, link in enumerate(player_links):
            try:
                # Get player name from link text
                player_name = link.text.strip()
                
                if not player_name or len(player_name) < 2:
                    continue
                
                # Split name into first and last
                name_parts = player_name.split()
                if len(name_parts) >= 2:
                    first_name = name_parts[0]
                    last_name = ' '.join(name_parts[1:])
                else:
                    first_name = player_name
                    last_name = ""
                
                # Look for additional player info in the surrounding context
                # Try to find captain designation
                parent_text = ""
                if link.parent:
                    parent_text = link.parent.get_text()
                
                is_captain = "(C)" in parent_text
                is_co_captain = "(CC)" in parent_text
                
                # Create player info
                player_info = {
                    'Series': 'Series 3',
                    'Division ID': 'NSTF_S3_TENNAQUA',
                    'Club': 'Tennaqua',
                    'Location ID': 'NSTF_TENNAQUA',
                    'First Name': first_name,
                    'Last Name': last_name,
                    'PTI': 'N/A',
                    'Wins': '0',
                    'Losses': '0',
                    'Win %': '0.0%'
                }
                
                # Add captain info if present
                if is_captain or is_co_captain:
                    player_info['Captain'] = 'C' if is_captain else 'CC'
                
                players.append(player_info)
                
                print(f"  Player {i+1}: {first_name} {last_name} | Tennaqua | {'Captain' if is_captain else 'Co-Captain' if is_co_captain else 'Player'}")
                
            except Exception as e:
                print(f"  Error processing player link {i+1}: {str(e)}")
                continue
        
        print(f"\nTotal Tennaqua S3 players found: {len(players)}")
        
        # Save to JSON for inspection
        with open('tennaqua_s3_test.json', 'w', encoding='utf-8') as f:
            json.dump(players, f, indent=2)
        
        print(f"Saved to tennaqua_s3_test.json")
        
        return players
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return []
    
    finally:
        driver.quit()

if __name__ == "__main__":
    players = test_tennaqua_s3()
    print(f"\nResult: Found {len(players)} Tennaqua Series 3 players") 
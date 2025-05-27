#!/usr/bin/env python3
"""
Debug script to examine Tennaqua S3 page structure more carefully.
"""

import time
from selenium import webdriver
from bs4 import BeautifulSoup
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

def debug_tennaqua_s3():
    """Debug Tennaqua Series 3 page structure."""
    
    team_id = 'nndz-WkNld3hycnc%3D'
    driver = create_driver()
    
    try:
        url = f'https://nstf.tenniscores.com/?mod=nndz-TjJiOWtORzkwTlJFb0NVU1NzOD0%3D&team={team_id}'
        print(f"Debugging Tennaqua S3 from {url}")
        
        driver.get(url)
        time.sleep(3)
        
        # Save the full page source for inspection
        with open('tennaqua_s3_page_source.html', 'w', encoding='utf-8') as f:
            f.write(driver.page_source)
        print("Saved full page source to tennaqua_s3_page_source.html")
        
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        # Look for the roster section specifically
        print("\n=== Looking for roster/player sections ===")
        
        # Find all tables that might contain player info
        tables = soup.find_all('table')
        print(f"Found {len(tables)} tables")
        
        for i, table in enumerate(tables):
            table_text = table.get_text().strip()
            if 'Tennaqua 3' in table_text or any(name in table_text for name in ['Erin', 'Reagan', 'Melissa']):
                print(f"\nTable {i+1} contains player info:")
                print(table_text[:500] + "..." if len(table_text) > 500 else table_text)
        
        # Look for all links that might be players
        print("\n=== All links analysis ===")
        all_links = soup.find_all('a')
        player_related_links = []
        
        for link in all_links:
            href = link.get('href', '')
            text = link.text.strip()
            
            # Check for player.php links
            if 'player.php' in href:
                player_related_links.append({
                    'type': 'player.php',
                    'href': href,
                    'text': text,
                    'parent_text': link.parent.get_text() if link.parent else ''
                })
            
            # Check for any links with names that look like players
            elif text and len(text.split()) >= 2 and text[0].isupper():
                # Might be a player name
                if not any(skip in text.lower() for skip in ['home', 'login', 'schedule', 'standings', 'matches']):
                    player_related_links.append({
                        'type': 'potential_player',
                        'href': href,
                        'text': text,
                        'parent_text': link.parent.get_text() if link.parent else ''
                    })
        
        print(f"Found {len(player_related_links)} potential player links:")
        for i, link in enumerate(player_related_links):
            print(f"  {i+1}. {link['type']}: '{link['text']}' -> {link['href']}")
            if '(C)' in link['parent_text'] or '(CC)' in link['parent_text']:
                print(f"      Captain info: {link['parent_text']}")
        
        # Look for specific text patterns that might indicate players
        print("\n=== Text pattern analysis ===")
        page_text = soup.get_text()
        
        # Look for captain/co-captain patterns
        captain_patterns = re.findall(r'([A-Z][a-z]+ [A-Z][a-z]+)\s*\([C]{1,2}\)', page_text)
        print(f"Captain patterns found: {captain_patterns}")
        
        # Look for checkmark patterns (✔) which might indicate active players
        checkmark_patterns = re.findall(r'✔\s*([A-Z][a-z]+ [A-Z][a-z]+)', page_text)
        print(f"Checkmark patterns found: {checkmark_patterns}")
        
        return player_related_links
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return []
    
    finally:
        driver.quit()

if __name__ == "__main__":
    debug_tennaqua_s3() 
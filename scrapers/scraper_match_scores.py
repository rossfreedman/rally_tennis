from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from bs4 import BeautifulSoup
import json
import re
import time
import os
from datetime import datetime

print("Starting tennis match scraper...")

class ChromeManager:
    """Context manager for handling Chrome WebDriver sessions."""
    
    def __init__(self, max_retries=3):
        """Initialize the Chrome WebDriver manager.
        
        Args:
            max_retries (int): Maximum number of retries for creating a new driver
        """
        self.driver = None
        self.max_retries = max_retries
        
    def create_driver(self):
        """Create and configure a new Chrome WebDriver instance."""
        options = webdriver.ChromeOptions()
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--disable-gpu')
        options.add_argument('--window-size=1920x1080')
        options.add_argument('--disable-features=NetworkService')
        options.add_argument('--disable-features=VizDisplayCompositor')
        options.add_argument('--disable-web-security')
        options.add_argument('--disable-features=IsolateOrigins,site-per-process')
        return webdriver.Chrome(options=options)

    def __enter__(self):
        """Create and return a Chrome WebDriver instance with retries."""
        for attempt in range(self.max_retries):
            try:
                if self.driver is not None:
                    try:
                        self.driver.quit()
                    except:
                        pass
                self.driver = self.create_driver()
                return self.driver
            except Exception as e:
                print(f"Error creating Chrome driver (attempt {attempt + 1}/{self.max_retries}): {str(e)}")
                if attempt < self.max_retries - 1:
                    print("Retrying...")
                    time.sleep(5)
                else:
                    raise Exception("Failed to create Chrome driver after maximum retries")

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Clean up the Chrome WebDriver instance."""
        self.quit()

    def quit(self):
        """Safely quit the Chrome WebDriver instance."""
        if self.driver is not None:
            try:
                self.driver.quit()
            except Exception as e:
                print(f"Error closing Chrome driver: {str(e)}")
            finally:
                self.driver = None

def scrape_matches(driver, url, max_retries=3, retry_delay=5):
    """Scrape match data from a single series URL with retries."""
    matches_data = []
    
    for attempt in range(max_retries):
        try:
            print(f"Navigating to URL: {url} (attempt {attempt + 1}/{max_retries})")
            driver.get(url)
            time.sleep(2)  # Wait for page to load
            
            # Look for and click the "Matches" link
            print("Looking for Matches link...")
            try:
                matches_link = WebDriverWait(driver, 10).until(
                    EC.presence_of_element_located((By.LINK_TEXT, "Matches"))
                )
                print("Found Matches link, clicking...")
                matches_link.click()
                time.sleep(2)  # Wait for navigation
            except TimeoutException:
                print("Could not find Matches link")
                if attempt < max_retries - 1:
                    print(f"Retrying in {retry_delay} seconds...")
                    time.sleep(retry_delay)
                    continue
                else:
                    print("Max retries reached, could not find Matches link")
                    return []
            
            print("Waiting for match results to load...")
            try:
                WebDriverWait(driver, 20).until(
                    EC.presence_of_element_located((By.ID, "match_results_container"))
                )
                print("Match results loaded successfully")
            except TimeoutException:
                print(f"Timeout waiting for match results to load (attempt {attempt + 1}/{max_retries})")
                if attempt < max_retries - 1:
                    print(f"Retrying in {retry_delay} seconds...")
                    time.sleep(retry_delay)
                    continue
                else:
                    print("Max retries reached, could not load match results")
                    return []
            
            # Find all match result tables
            match_tables = driver.find_elements(By.CLASS_NAME, "match_results_table")
            if not match_tables:
                print("No match tables found on the page")
                if attempt < max_retries - 1:
                    print(f"Retrying in {retry_delay} seconds...")
                    time.sleep(retry_delay)
                    continue
                else:
                    print("Max retries reached, no match tables found")
                    return []
                    
            print(f"Found {len(match_tables)} match tables to process")
            
            for table_index, table in enumerate(match_tables, 1):
                try:
                    print(f"\nProcessing match table {table_index} of {len(match_tables)}")
                    # Find the match header (contains date and club names)
                    header_row = table.find_element(By.CSS_SELECTOR, "div[style*='background-color: #dcdcdc;']")
                    
                    # Extract date from the header
                    date_element = header_row.find_element(By.CLASS_NAME, "match_rest")
                    date_text = date_element.text
                    match_date = re.search(r'(\w+ \d+, \d{4})', date_text)
                    if match_date:
                        date_str = match_date.group(1)
                        date_obj = datetime.strptime(date_str, '%B %d, %Y')
                        date = date_obj.strftime('%d-%b-%y')
                    else:
                        date = "Unknown"
                    
                    # Extract club names from the header
                    home_club_element = header_row.find_element(By.CLASS_NAME, "team_name")
                    away_club_element = header_row.find_element(By.CLASS_NAME, "team_name2")
                    
                    # Get the full team names including the "- 22" suffix
                    home_club_full = home_club_element.text.strip()
                    away_club_full = away_club_element.text.strip()
                    
                    print(f"Processing matches for {home_club_full} vs {away_club_full} on {date}")
                    
                    # Find all player rows in this table
                    player_divs = table.find_elements(By.XPATH, ".//div[not(contains(@style, 'background-color')) and not(contains(@class, 'clear clearfix'))]")
                    
                    i = 0
                    while i < len(player_divs) - 4:  # Need at least 5 elements for a complete match row
                        try:
                            # Check if this is a player match row
                            if ("points" in player_divs[i].get_attribute("class") and 
                                "team_name" in player_divs[i+1].get_attribute("class") and 
                                "match_rest" in player_divs[i+2].get_attribute("class") and 
                                "team_name2" in player_divs[i+3].get_attribute("class")):
                                
                                # Extract data
                                home_text = player_divs[i+1].text.strip()
                                score = player_divs[i+2].text.strip()
                                away_text = player_divs[i+3].text.strip()
                                
                                # Skip if this is not a match
                                if not score or re.search(r'\d{1,2}:\d{2}', score) or "Date" in score:
                                    i += 5
                                    continue
                                
                                # Determine winner
                                winner_img_home = player_divs[i].find_elements(By.TAG_NAME, "img")
                                winner_img_away = player_divs[i+4].find_elements(By.TAG_NAME, "img") if i+4 < len(player_divs) else []
                                
                                if winner_img_home:
                                    winner = "home"
                                elif winner_img_away:
                                    winner = "away"
                                else:
                                    winner = "unknown"
                                
                                # Split player names
                                home_players = home_text.split("/")
                                away_players = away_text.split("/")
                                
                                home_player1 = home_players[0].strip() if len(home_players) > 0 else ""
                                home_player2 = home_players[1].strip() if len(home_players) > 1 else ""
                                away_player1 = away_players[0].strip() if len(away_players) > 0 else ""
                                away_player2 = away_players[1].strip() if len(away_players) > 1 else ""
                                
                                # Extract player IDs from links or data attributes
                                def extract_player_ids(player_div):
                                    """Extract player IDs from a player div element.
                                    
                                    Note: Player IDs may not be available on the match results page
                                    as they might be stored in a separate player database or loaded
                                    dynamically via JavaScript. This function provides a framework
                                    for when such data becomes available.
                                    """
                                    player_ids = []
                                    try:
                                        # Get the full HTML of the player div to search for any ID patterns
                                        html_content = player_div.get_attribute('outerHTML')
                                        
                                        # Look for links within the player div
                                        player_links = player_div.find_elements(By.TAG_NAME, "a")
                                        
                                        for link in player_links:
                                            href = link.get_attribute("href") or ""
                                            onclick = link.get_attribute("onclick") or ""
                                            
                                            # Search in href for various ID patterns
                                            for pattern in [
                                                r'player_id=([^&\s]+)',                    # ?player_id=NSTF_F234A9FE
                                                r'pid=([^&\s]+)',                          # ?pid=NSTF_F234A9FE  
                                                r'id=([A-Z]+_[A-F0-9]+)',                  # ?id=NSTF_F234A9FE
                                                r'([A-Z]{2,6}_[A-F0-9]{6,12})',            # NSTF_F234A9FE pattern
                                                r'player/([^/\s&]+)',                      # /player/NSTF_F234A9FE
                                            ]:
                                                match = re.search(pattern, href, re.IGNORECASE)
                                                if match:
                                                    player_id = match.group(1).strip()
                                                    if player_id and player_id not in player_ids:
                                                        player_ids.append(player_id)
                                            
                                            # Search in onclick for ID patterns
                                            for pattern in [
                                                r"'([A-Z]+_[A-F0-9]+)'",                   # onclick="showPlayer('NSTF_F234A9FE')"
                                                r'"([A-Z]+_[A-F0-9]+)"',                   # onclick="showPlayer("NSTF_F234A9FE")"
                                                r'([A-Z]{2,6}_[A-F0-9]{6,12})',            # Any NSTF_F234A9FE pattern
                                            ]:
                                                match = re.search(pattern, onclick, re.IGNORECASE)
                                                if match:
                                                    player_id = match.group(1).strip()
                                                    if player_id and player_id not in player_ids:
                                                        player_ids.append(player_id)
                                            
                                            # Check data attributes on the link
                                            for attr in ['data-player-id', 'data-id', 'data-player', 'player-id', 'data-pid']:
                                                attr_value = link.get_attribute(attr)
                                                if attr_value and attr_value not in player_ids:
                                                    player_ids.append(attr_value)
                                        
                                        # If no links found, check data attributes directly on the div
                                        if not player_links:
                                            for attr in ['data-player-id', 'data-id', 'data-player', 'player-id', 'data-pid']:
                                                attr_value = player_div.get_attribute(attr)
                                                if attr_value and attr_value not in player_ids:
                                                    player_ids.append(attr_value)
                                        
                                        # As a last resort, search the entire HTML content for ID patterns
                                        if not player_ids and html_content:
                                            for pattern in [
                                                r'([A-Z]{2,6}_[A-F0-9]{6,12})',            # NSTF_F234A9FE pattern
                                                r'player_id[=:][\s]*["\']?([^"\'&\s]+)',   # player_id="NSTF_F234A9FE"
                                                r'pid[=:][\s]*["\']?([^"\'&\s]+)',         # pid="NSTF_F234A9FE"
                                            ]:
                                                matches = re.findall(pattern, html_content, re.IGNORECASE)
                                                for match in matches:
                                                    if match and match not in player_ids:
                                                        player_ids.append(match)
                                        
                                        # Print debug info only when IDs are found
                                        if player_ids:
                                            print(f"    Found player IDs: {player_ids}")
                                        
                                    except Exception as e:
                                        print(f"    Warning: Error extracting player IDs: {str(e)}")
                                    
                                    return player_ids
                                
                                # Extract player IDs for home and away players
                                home_player_ids = extract_player_ids(player_divs[i+1])
                                away_player_ids = extract_player_ids(player_divs[i+3])
                                
                                # Assign player IDs (pad with empty strings if not enough IDs found)
                                home_player1_id = home_player_ids[0] if len(home_player_ids) > 0 else ""
                                home_player2_id = home_player_ids[1] if len(home_player_ids) > 1 else ""
                                away_player1_id = away_player_ids[0] if len(away_player_ids) > 0 else ""
                                away_player2_id = away_player_ids[1] if len(away_player_ids) > 1 else ""
                                
                                # Store match data in the exact format as match_history.json
                                match_data = {
                                    "Date": date,
                                    "Home Team": home_club_full,
                                    "Away Team": away_club_full,
                                    "Home Player 1": home_player1,
                                    "Home Player 1 ID": home_player1_id,
                                    "Home Player 2": home_player2,
                                    "Home Player 2 ID": home_player2_id,
                                    "Away Player 1": away_player1,
                                    "Away Player 1 ID": away_player1_id,
                                    "Away Player 2": away_player2,
                                    "Away Player 2 ID": away_player2_id,
                                    "Scores": score,
                                    "Winner": winner
                                }
                                matches_data.append(match_data)
                                print(f"  Processed match: {home_player1}/{home_player2} vs {away_player1}/{away_player2} - Score: {score}")
                                print(f"    Player IDs: {home_player1_id}/{home_player2_id} vs {away_player1_id}/{away_player2_id}")
                                
                                i += 5  # Move to the next potential match row
                            else:
                                i += 1  # Move to the next div
                        except Exception as e:
                            print(f"  Error processing match row: {str(e)}")
                            i += 1  # Skip this div if there's an error
                    
                    print(f"Completed table {table_index}")
                
                except Exception as e:
                    print(f"Error processing match table {table_index}: {str(e)}")
            
            # If we successfully processed the page, break the retry loop
            break
            
        except TimeoutException:
            print(f"Timeout waiting for page to load (attempt {attempt + 1}/{max_retries})")
            if attempt < max_retries - 1:
                print(f"Retrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
            else:
                print("Max retries reached, could not load page")
                return []
        except Exception as e:
            print(f"Error loading page (attempt {attempt + 1}/{max_retries}): {str(e)}")
            if attempt < max_retries - 1:
                print(f"Retrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
            else:
                print("Max retries reached, could not process page")
                return []
    
    return matches_data

def load_active_series():
    """Load the list of active series from the configuration file."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    active_series_path = os.path.join(script_dir, 'active_series.txt')
    
    print("\n=== Loading Active Series ===")
    try:
        with open(active_series_path, 'r') as f:
            # Keep the exact format from the file
            series_set = {line.strip() for line in f if line.strip()}
            print(f"Successfully loaded {len(series_set)} active series from {active_series_path}")
            print("Active series:", sorted(list(series_set)))
            return series_set
    except FileNotFoundError:
        print(f"Warning: {active_series_path} not found. Processing all series.")
        return None

def scrape_all_matches(max_retries=3, retry_delay=5):
    """Main function to scrape and save match data from all series."""
    try:
        # Load active series configuration
        active_series = load_active_series()
        
        # Use context manager to ensure Chrome driver is properly closed
        with ChromeManager() as driver:
            base_url = 'https://nstf.tenniscores.com/'
            
            # Create directory structure if it doesn't exist
            script_dir = os.path.dirname(os.path.abspath(__file__))  # Get the directory containing this script
            project_root = os.path.dirname(script_dir)  # Go up one level to project root
            data_dir = os.path.join(project_root, 'data')
            os.makedirs(data_dir, exist_ok=True)
            
            print(f"\n=== Accessing Main Page ===")
            print(f"Navigating to URL: {base_url}")
            driver.get(base_url)
            time.sleep(retry_delay)
            
            # Parse the page with BeautifulSoup
            print("\n=== Parsing Main Page ===")
            soup = BeautifulSoup(driver.page_source, 'html.parser')
            
            # Find all div_list_option elements
            series_elements = soup.find_all('div', class_='div_list_option')
            print(f"Found {len(series_elements)} total series on main page")
            
            # Extract series URLs
            series_urls = []
            print("\n=== Processing Series Links ===")
            for element in series_elements:
                try:
                    series_link = element.find('a')
                    if series_link and series_link.text:
                        series_name = series_link.text.strip()
                        print(f"\nFound series link: '{series_name}'")
                        
                        # Skip if not in active series list
                        if active_series and series_name not in active_series:
                            print(f"Skipping inactive series: {series_name}")
                            continue
                            
                        series_url = series_link.get('href', '')
                        full_url = f"{base_url}{series_url}" if series_url else ''
                        if full_url:
                            series_urls.append((series_name, full_url))
                            print(f"Found active series: {series_name}")
                            print(f"         URL: {full_url}")
                            print("-" * 80)
                except Exception as e:
                    print(f"Error extracting series URL: {str(e)}")
            
            if not series_urls:
                print("\nERROR: No active series found!")
                print("Available series on page:", [link.text.strip() for link in soup.find_all('a') if link.text.strip()])
                return
            
            # Sort series by number and letter
            def sort_key(item):
                series_name = item[0]
                try:
                    # Extract numeric and letter parts (e.g., "Series 2B" -> (2, "B"))
                    parts = series_name.split()
                    if len(parts) >= 2:
                        num_part = ''.join(c for c in parts[1] if c.isdigit())
                        letter_part = ''.join(c for c in parts[1] if c.isalpha())
                        return (float(num_part) if num_part else float('inf'), letter_part)
                except (IndexError, ValueError):
                    return (float('inf'), '')
                return (float('inf'), '')
            
            series_urls.sort(key=sort_key)
            
            # Initialize a flat array for all matches
            all_matches = []
            total_matches = 0
            
            print("\n=== Processing Series Pages ===")
            # Process each series
            for series_name, series_url in series_urls:
                print(f"\nProcessing series: {series_name}")
                matches = scrape_matches(driver, series_url, max_retries=max_retries, retry_delay=retry_delay)
                
                if not matches:
                    print(f"No matches found for series {series_name}, skipping")
                    continue
                
                # Add matches directly to the flat array
                all_matches.extend(matches)
                total_matches += len(matches)
                print(f"Completed series {series_name} - Found {len(matches)} matches")
                time.sleep(retry_delay)  # Add delay between series
            
            print("\n=== Saving Data ===")
            # Save all matches to a single JSON file
            json_filename = "match_history.json"
            json_path = os.path.join(data_dir, json_filename)
            print(f"Saving match data to: {json_path}")
            
            with open(json_path, 'w', encoding='utf-8') as jsonfile:
                json.dump(all_matches, jsonfile, indent=2)
            
            print(f"\n=== Scraping Completed Successfully ===")
            print(f"Total matches processed: {total_matches}")
            print(f"Data has been saved to: {json_path}")
            
            # Check if any player IDs were found
            player_ids_found = sum(1 for match in all_matches 
                                 if any([match.get('Home Player 1 ID'), match.get('Home Player 2 ID'),
                                        match.get('Away Player 1 ID'), match.get('Away Player 2 ID')]))
            
            print(f"\n=== Player ID Extraction Status ===")
            print(f"Matches with player IDs found: {player_ids_found} out of {total_matches}")
            if player_ids_found == 0:
                print("Note: Player IDs may not be available on the match results page.")
                print("They might be:")
                print("  - Stored in a separate player database")
                print("  - Loaded dynamically via JavaScript")  
                print("  - Available only on individual player profile pages")
                print("  - Accessible through a different API endpoint")
                print("\nThe data structure is ready to include player IDs when they become available.")

    except Exception as e:
        print(f"\nERROR: An unexpected error occurred")
        print(f"Error type: {type(e).__name__}")
        print(f"Error details: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    scrape_all_matches()

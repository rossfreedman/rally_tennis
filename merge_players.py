#!/usr/bin/env python3
"""
Script to merge NSTF players data with existing players.json file.
"""

import json
import os
from datetime import datetime

def merge_player_data():
    """
    Merge NSTF players data with existing players.json file.
    """
    
    # File paths
    existing_players_file = 'data/players.json'
    nstf_players_file = 'data/nstf_players.json'
    backup_file = f'data/players_backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
    
    try:
        # Load existing players data
        print(f"Loading existing players from {existing_players_file}...")
        if os.path.exists(existing_players_file):
            with open(existing_players_file, 'r', encoding='utf-8') as f:
                existing_players = json.load(f)
            print(f"Found {len(existing_players)} existing players")
            
            # Create backup of existing file
            with open(backup_file, 'w', encoding='utf-8') as f:
                json.dump(existing_players, f, indent=2)
            print(f"Created backup at {backup_file}")
        else:
            existing_players = []
            print("No existing players file found, starting fresh")
        
        # Load NSTF players data
        print(f"Loading NSTF players from {nstf_players_file}...")
        if os.path.exists(nstf_players_file):
            with open(nstf_players_file, 'r', encoding='utf-8') as f:
                nstf_players = json.load(f)
            print(f"Found {len(nstf_players)} NSTF players")
        else:
            print(f"Error: {nstf_players_file} not found!")
            return False
        
        # Merge the data
        print("Merging player data...")
        
        # Create a set of existing player identifiers to avoid duplicates
        existing_player_ids = set()
        for player in existing_players:
            # Use first name, last name, and club as identifier
            player_id = f"{player['First Name']}_{player['Last Name']}_{player['Club']}"
            existing_player_ids.add(player_id)
        
        # Add NSTF players, avoiding duplicates
        new_players_added = 0
        duplicates_skipped = 0
        
        for nstf_player in nstf_players:
            player_id = f"{nstf_player['First Name']}_{nstf_player['Last Name']}_{nstf_player['Club']}"
            
            if player_id not in existing_player_ids:
                existing_players.append(nstf_player)
                existing_player_ids.add(player_id)
                new_players_added += 1
            else:
                duplicates_skipped += 1
        
        print(f"Added {new_players_added} new players")
        print(f"Skipped {duplicates_skipped} duplicates")
        
        # Sort players by Series, Club, Last Name, First Name for better organization
        print("Sorting players...")
        existing_players.sort(key=lambda x: (
            x.get('Series', ''),
            x.get('Club', ''),
            x.get('Last Name', ''),
            x.get('First Name', '')
        ))
        
        # Save merged data back to players.json
        print(f"Saving merged data to {existing_players_file}...")
        with open(existing_players_file, 'w', encoding='utf-8') as f:
            json.dump(existing_players, f, indent=2)
        
        print(f"\n=== MERGE COMPLETE ===")
        print(f"Total players in merged file: {len(existing_players)}")
        print(f"Original players: {len(existing_players) - new_players_added}")
        print(f"New NSTF players added: {new_players_added}")
        print(f"Backup saved to: {backup_file}")
        
        # Print summary by club
        print(f"\nSummary by club:")
        club_counts = {}
        for player in existing_players:
            club = player.get('Club', 'Unknown')
            club_counts[club] = club_counts.get(club, 0) + 1
        
        for club, count in sorted(club_counts.items()):
            print(f"  {club}: {count} players")
        
        return True
        
    except Exception as e:
        print(f"Error during merge: {str(e)}")
        return False

if __name__ == "__main__":
    success = merge_player_data()
    if success:
        print("\nMerge completed successfully!")
    else:
        print("\nMerge failed!") 
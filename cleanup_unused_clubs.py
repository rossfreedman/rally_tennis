#!/usr/bin/env python3

import json
import os
import psycopg2
from dotenv import load_dotenv

def cleanup_unused_clubs():
    """Remove clubs from database that don't have players in players.json"""
    
    print("=== Cleaning Up Unused Clubs from Database ===\n")
    
    # Load environment variables
    load_dotenv()
    
    # Get database URL
    DATABASE_URL = os.getenv('DATABASE_URL')
    if not DATABASE_URL:
        print("ERROR: DATABASE_URL environment variable not set")
        return False
    
    # Handle Railway's postgres:// URLs
    if DATABASE_URL.startswith('postgres://'):
        DATABASE_URL = DATABASE_URL.replace('postgres://', 'postgresql://', 1)
    
    # Load players.json to get clubs that are actually used
    players_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data', 'players.json')
    
    try:
        with open(players_path, 'r') as f:
            players = json.load(f)
        
        # Extract unique clubs from players.json (clubs that should be kept)
        clubs_in_json = set()
        for player in players:
            club = player.get('Club')
            if club:
                clubs_in_json.add(club)
        
        clubs_in_json = sorted(list(clubs_in_json))
        
        print(f"Clubs that SHOULD be kept (have players in players.json): {len(clubs_in_json)}")
        for i, club in enumerate(clubs_in_json, 1):
            print(f"  {i:2d}. {club}")
        
        print("\n" + "="*60)
        
        # Connect to database
        print("Connecting to database...")
        conn = psycopg2.connect(DATABASE_URL)
        cursor = conn.cursor()
        
        # Get current clubs from database
        cursor.execute("SELECT id, name FROM clubs ORDER BY name")
        current_clubs = cursor.fetchall()
        
        print(f"\nCurrent clubs in database: {len(current_clubs)}")
        
        # Find clubs that should be removed (in database but not in JSON)
        clubs_to_remove = []
        clubs_to_keep = []
        
        for club_id, club_name in current_clubs:
            if club_name in clubs_in_json:
                clubs_to_keep.append((club_id, club_name))
            else:
                clubs_to_remove.append((club_id, club_name))
        
        print(f"\nClubs to KEEP (have players): {len(clubs_to_keep)}")
        for i, (club_id, club_name) in enumerate(clubs_to_keep, 1):
            print(f"  {i:2d}. {club_name} (ID: {club_id})")
        
        print(f"\nClubs to REMOVE (no players): {len(clubs_to_remove)}")
        if clubs_to_remove:
            for i, (club_id, club_name) in enumerate(clubs_to_remove, 1):
                print(f"  {i:2d}. {club_name} (ID: {club_id})")
        else:
            print("  None - database is already clean!")
        
        print("\n" + "="*60)
        
        if not clubs_to_remove:
            print("✅ No cleanup needed - all clubs in database have players!")
            cursor.close()
            conn.close()
            return False
        
        # Check if any users are assigned to clubs that would be removed
        print("\nChecking for users assigned to clubs that would be removed...")
        
        clubs_with_users = []
        for club_id, club_name in clubs_to_remove:
            cursor.execute("SELECT COUNT(*) FROM users WHERE club_id = %s", (club_id,))
            user_count = cursor.fetchone()[0]
            if user_count > 0:
                clubs_with_users.append((club_id, club_name, user_count))
        
        if clubs_with_users:
            print(f"\n⚠️  WARNING: {len(clubs_with_users)} clubs have users assigned:")
            for club_id, club_name, user_count in clubs_with_users:
                print(f"    - {club_name} (ID: {club_id}) has {user_count} user(s)")
            print("\nThese clubs will NOT be removed to preserve user data integrity.")
            
            # Remove clubs with users from the removal list
            clubs_to_remove = [(cid, cname) for cid, cname in clubs_to_remove 
                             if cid not in [c[0] for c in clubs_with_users]]
            
            print(f"\nUpdated removal list: {len(clubs_to_remove)} clubs")
            for i, (club_id, club_name) in enumerate(clubs_to_remove, 1):
                print(f"  {i:2d}. {club_name} (ID: {club_id})")
        
        if not clubs_to_remove:
            print("\n✅ No clubs can be safely removed!")
            cursor.close()
            conn.close()
            return False
        
        # Confirm removal
        print(f"\n🗑️  Ready to remove {len(clubs_to_remove)} unused clubs...")
        print("This action cannot be undone!")
        
        # Remove the clubs
        removed_count = 0
        for club_id, club_name in clubs_to_remove:
            try:
                cursor.execute("DELETE FROM clubs WHERE id = %s", (club_id,))
                print(f"  ✓ Removed: {club_name} (ID: {club_id})")
                removed_count += 1
            except Exception as e:
                print(f"  ✗ Failed to remove {club_name}: {str(e)}")
        
        # Commit the changes
        if removed_count > 0:
            conn.commit()
            print(f"\n✅ Successfully removed {removed_count} unused clubs!")
        else:
            print("\n❌ No clubs were removed due to errors.")
        
        # Verify the cleanup
        print("\n" + "="*60)
        print("\nVerifying database after cleanup...")
        
        cursor.execute("SELECT name FROM clubs ORDER BY name")
        final_clubs = cursor.fetchall()
        final_club_names = [club[0] for club in final_clubs]
        
        print(f"Final database club count: {len(final_club_names)}")
        
        # Check that all clubs from JSON are still present
        missing_clubs = [club for club in clubs_in_json if club not in final_club_names]
        
        if missing_clubs:
            print(f"⚠️  WARNING: {len(missing_clubs)} required clubs are missing:")
            for club in missing_clubs:
                print(f"    - {club}")
        else:
            print("✅ All required clubs (from players.json) are present in database!")
        
        # Show extra clubs (should be only those with users)
        extra_clubs = [club for club in final_club_names if club not in clubs_in_json]
        if extra_clubs:
            print(f"\nRemaining extra clubs (kept due to user assignments): {len(extra_clubs)}")
            for club in extra_clubs:
                print(f"    - {club}")
        
        # Close database connection
        cursor.close()
        conn.close()
        
        return removed_count > 0
        
    except Exception as e:
        print(f"Error cleaning up clubs: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = cleanup_unused_clubs()
    if success:
        print("\n🧹 Database cleanup completed!")
        print("Unused clubs have been removed while preserving user data integrity.")
    else:
        print("\n📋 No cleanup was performed.") 
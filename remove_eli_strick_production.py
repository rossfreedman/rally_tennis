#!/usr/bin/env python3

import os
import psycopg2
from urllib.parse import urlparse

def get_production_db_connection():
    """Connect directly to Railway production database"""
    # Use the production database URL from Railway
    prod_url = "postgresql://postgres:ihxpdgQMcXGoMCNvYqzWWmidKTnkdsoM@metro.proxy.rlwy.net:19439/railway"
    
    parsed = urlparse(prod_url)
    
    # Railway requires SSL
    conn_params = {
        'dbname': parsed.path[1:],
        'user': parsed.username,
        'password': parsed.password,
        'host': parsed.hostname,
        'port': parsed.port or 5432,
        'sslmode': 'require',
        'connect_timeout': 30
    }
    
    print(f"Connecting to PRODUCTION Railway database at {conn_params['host']}:{conn_params['port']}")
    return psycopg2.connect(**conn_params)

def remove_eli_strick_production():
    """Remove Eli Strick and all related data from the PRODUCTION database"""
    
    print("=" * 70)
    print("WARNING: REMOVING ELI STRICK FROM PRODUCTION RAILWAY DATABASE")
    print("=" * 70)
    
    conn = get_production_db_connection()
    cur = conn.cursor()
    
    try:
        # First, find Eli Strick's user record
        print('\n--- Looking for Eli Strick in PRODUCTION users table ---')
        cur.execute("""
            SELECT id, email, first_name, last_name, club_id, series_id 
            FROM users 
            WHERE LOWER(first_name) = 'eli' AND LOWER(last_name) = 'strick'
        """)
        eli_users = cur.fetchall()
        
        if not eli_users:
            print('No user records found for Eli Strick in PRODUCTION')
            return
        
        print(f'Found {len(eli_users)} user records for Eli Strick in PRODUCTION:')
        for user in eli_users:
            print(f'  ID: {user[0]}, Email: {user[1]}, Name: {user[2]} {user[3]}, Club ID: {user[4]}, Series ID: {user[5]}')
        
        # Get Eli's email for related data cleanup
        eli_email = eli_users[0][1]
        
        # Check and remove from user_activity_logs table
        print('\n--- Checking PRODUCTION user_activity_logs table ---')
        cur.execute("""
            SELECT COUNT(*) 
            FROM user_activity_logs
            WHERE user_email = %s
        """, (eli_email,))
        activity_count = cur.fetchone()[0]
        
        if activity_count > 0:
            print(f'Found {activity_count} activity log records for Eli Strick in PRODUCTION')
            cur.execute("""
                DELETE FROM user_activity_logs 
                WHERE user_email = %s
            """, (eli_email,))
            deleted_activity = cur.rowcount
            print(f'Deleted {deleted_activity} activity log records from PRODUCTION')
        else:
            print('No activity log records found for Eli Strick in PRODUCTION')
        
        # Check and remove from user_instructions table
        print('\n--- Checking PRODUCTION user_instructions table ---')
        cur.execute("""
            SELECT COUNT(*) 
            FROM user_instructions
            WHERE user_email = %s
        """, (eli_email,))
        instructions_count = cur.fetchone()[0]
        
        if instructions_count > 0:
            print(f'Found {instructions_count} instruction records for Eli Strick in PRODUCTION')
            cur.execute("""
                DELETE FROM user_instructions 
                WHERE user_email = %s
            """, (eli_email,))
            deleted_instructions = cur.rowcount
            print(f'Deleted {deleted_instructions} instruction records from PRODUCTION')
        else:
            print('No instruction records found for Eli Strick in PRODUCTION')
        
        # Check and remove from player_availability table
        print('\n--- Checking PRODUCTION player_availability table ---')
        cur.execute("""
            SELECT COUNT(*) 
            FROM player_availability
            WHERE LOWER(player_name) = 'eli strick'
        """)
        availability_count = cur.fetchone()[0]
        
        if availability_count > 0:
            print(f'Found {availability_count} availability records for Eli Strick in PRODUCTION')
            cur.execute("""
                DELETE FROM player_availability 
                WHERE LOWER(player_name) = 'eli strick'
            """)
            deleted_availability = cur.rowcount
            print(f'Deleted {deleted_availability} availability records from PRODUCTION')
        else:
            print('No availability records found for Eli Strick in PRODUCTION')
        
        # Check and remove from player_availability_backup table
        print('\n--- Checking PRODUCTION player_availability_backup table ---')
        cur.execute("""
            SELECT COUNT(*) 
            FROM player_availability_backup
            WHERE LOWER(player_name) = 'eli strick'
        """)
        backup_count = cur.fetchone()[0]
        
        if backup_count > 0:
            print(f'Found {backup_count} backup availability records for Eli Strick in PRODUCTION')
            cur.execute("""
                DELETE FROM player_availability_backup 
                WHERE LOWER(player_name) = 'eli strick'
            """)
            deleted_backup = cur.rowcount
            print(f'Deleted {deleted_backup} backup availability records from PRODUCTION')
        else:
            print('No backup availability records found for Eli Strick in PRODUCTION')
        
        # Finally, delete the user record itself
        print('\n--- Removing user record from PRODUCTION ---')
        cur.execute("""
            DELETE FROM users 
            WHERE LOWER(first_name) = 'eli' AND LOWER(last_name) = 'strick'
        """)
        deleted_users = cur.rowcount
        print(f'Deleted {deleted_users} user records from PRODUCTION')
        
        # Commit all changes
        conn.commit()
        print('\n' + "=" * 70)
        print('ALL ELI STRICK DATA HAS BEEN SUCCESSFULLY REMOVED FROM PRODUCTION')
        print("=" * 70)
        
        # Summary
        print('\nSummary of PRODUCTION deletions:')
        if activity_count > 0:
            print(f'  - Activity logs: {deleted_activity} records')
        if instructions_count > 0:
            print(f'  - Instructions: {deleted_instructions} records')
        if availability_count > 0:
            print(f'  - Availability: {deleted_availability} records')
        if backup_count > 0:
            print(f'  - Backup availability: {deleted_backup} records')
        print(f'  - User account: {deleted_users} records')
        
    except Exception as e:
        print(f'ERROR during PRODUCTION removal: {e}')
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    # Confirm this is intentional
    print("Are you sure you want to remove Eli Strick from the PRODUCTION Railway database?")
    print("This action cannot be undone!")
    confirmation = input("Type 'YES DELETE FROM PRODUCTION' to confirm: ")
    
    if confirmation == "YES DELETE FROM PRODUCTION":
        remove_eli_strick_production()
    else:
        print("Operation cancelled.") 
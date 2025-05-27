#!/usr/bin/env python3
"""
Check the actual local Rally Tennis database to get exact current data
"""
import os
import sys
import psycopg2
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def check_local_database():
    """Check what data is currently in the local Rally Tennis database"""
    logger.info("Checking local Rally Tennis database...")
    
    # Try different local database connection options
    local_db_configs = [
        {
            'dbname': 'rally',
            'user': 'rossfreedman',
            'host': 'localhost',
            'port': 5432
        },
        {
            'dbname': 'rally_tennis',
            'user': 'rossfreedman', 
            'host': 'localhost',
            'port': 5432
        },
        {
            'dbname': 'rally',
            'user': 'postgres',
            'host': 'localhost',
            'port': 5432
        },
        {
            'dbname': 'rally_tennis',
            'user': 'postgres',
            'host': 'localhost',
            'port': 5432
        }
    ]
    
    for config in local_db_configs:
        try:
            logger.info(f"Trying to connect to local database: {config['dbname']} as {config['user']}")
            conn = psycopg2.connect(**config)
            
            with conn.cursor() as cursor:
                logger.info(f"Connected to local database: {config['dbname']}")
                
                # Check clubs
                cursor.execute("SELECT id, name FROM clubs ORDER BY id;")
                clubs = cursor.fetchall()
                logger.info(f"Local clubs ({len(clubs)} total):")
                for club in clubs:
                    logger.info(f"  {club[0]}: {club[1]}")
                
                # Check series
                cursor.execute("SELECT id, name FROM series ORDER BY id;")
                series = cursor.fetchall()
                logger.info(f"Local series ({len(series)} total):")
                for s in series:
                    logger.info(f"  {s[0]}: {s[1]}")
                
                # Check users
                cursor.execute("SELECT id, email, first_name, last_name, club_id, series_id FROM users ORDER BY id;")
                users = cursor.fetchall()
                logger.info(f"Local users ({len(users)} total):")
                for user in users:
                    logger.info(f"  {user[0]}: {user[1]} ({user[2]} {user[3]}) - Club: {user[4]}, Series: {user[5]}")
                
                conn.close()
                return True
                
        except Exception as e:
            logger.warning(f"Failed to connect to {config['dbname']} as {config['user']}: {str(e)}")
            continue
    
    logger.error("Could not connect to any local database")
    return False

if __name__ == "__main__":
    success = check_local_database()
    if success:
        logger.info("✅ Local database check completed successfully!")
        sys.exit(0)
    else:
        logger.error("❌ Local database check failed!")
        sys.exit(1) 
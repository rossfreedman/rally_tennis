#!/usr/bin/env python3
"""
Check current data in Railway database
"""
import os
import sys
from database_config import get_db
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def check_current_data():
    """Check what data is currently in the database"""
    logger.info("Checking current database data...")
    
    # Set Railway environment
    os.environ['RAILWAY_ENVIRONMENT'] = 'production'
    
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                logger.info("Connected to Railway database successfully")
                
                # Check clubs
                cursor.execute("SELECT id, name FROM clubs ORDER BY id;")
                clubs = cursor.fetchall()
                logger.info("Current clubs:")
                for club in clubs:
                    logger.info(f"  {club[0]}: {club[1]}")
                
                # Check series
                cursor.execute("SELECT id, name FROM series ORDER BY id;")
                series = cursor.fetchall()
                logger.info("Current series:")
                for s in series:
                    logger.info(f"  {s[0]}: {s[1]}")
                
                # Check users
                cursor.execute("SELECT id, email, first_name, last_name, club_id, series_id FROM users ORDER BY id;")
                users = cursor.fetchall()
                logger.info("Current users:")
                for user in users:
                    logger.info(f"  {user[0]}: {user[1]} ({user[2]} {user[3]}) - Club: {user[4]}, Series: {user[5]}")
                
                return True
                
    except Exception as e:
        logger.error(f"Data check failed: {str(e)}")
        return False

if __name__ == "__main__":
    success = check_current_data()
    if success:
        logger.info("✅ Data check completed successfully!")
        sys.exit(0)
    else:
        logger.error("❌ Data check failed!")
        sys.exit(1) 
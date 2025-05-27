#!/usr/bin/env python3
"""
Remove all users except Ross Freedman from Railway database
"""
import os
import sys
from database_config import get_db
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def remove_other_users():
    """Remove all users except Ross Freedman from Railway database"""
    logger.info("Removing all users except Ross Freedman from Railway database...")
    
    # Set Railway environment
    os.environ['RAILWAY_ENVIRONMENT'] = 'production'
    
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                logger.info("Connected to Railway database successfully")
                
                # First, check current users
                cursor.execute("SELECT id, email, first_name, last_name FROM users ORDER BY id;")
                current_users = cursor.fetchall()
                logger.info(f"Current users ({len(current_users)} total):")
                for user in current_users:
                    logger.info(f"  {user[0]}: {user[1]} ({user[2]} {user[3]})")
                
                # Delete all users except Ross Freedman
                logger.info("Deleting all users except rossfreedman@gmail.com...")
                cursor.execute("""
                    DELETE FROM users 
                    WHERE email != 'rossfreedman@gmail.com';
                """)
                
                deleted_count = cursor.rowcount
                logger.info(f"Deleted {deleted_count} users")
                
                conn.commit()
                
                # Verify the result
                cursor.execute("SELECT id, email, first_name, last_name, club_id, series_id, is_admin FROM users;")
                remaining_users = cursor.fetchall()
                logger.info(f"Remaining users ({len(remaining_users)} total):")
                for user in remaining_users:
                    logger.info(f"  {user[0]}: {user[1]} ({user[2]} {user[3]}) - Club: {user[4]}, Series: {user[5]}, Admin: {user[6]}")
                
                # Get club and series info for Ross
                cursor.execute("""
                    SELECT u.email, c.name as club, s.name as series 
                    FROM users u 
                    JOIN clubs c ON u.club_id = c.id 
                    JOIN series s ON u.series_id = s.id 
                    WHERE u.email = 'rossfreedman@gmail.com';
                """)
                user_info = cursor.fetchone()
                
                logger.info("User cleanup completed successfully!")
                logger.info(f"Remaining user: {user_info[0]} - {user_info[1]} - {user_info[2]}")
                
                return True
                
    except Exception as e:
        logger.error(f"User cleanup failed: {str(e)}")
        return False

if __name__ == "__main__":
    success = remove_other_users()
    if success:
        logger.info("✅ User cleanup completed successfully!")
        sys.exit(0)
    else:
        logger.error("❌ User cleanup failed!")
        sys.exit(1) 
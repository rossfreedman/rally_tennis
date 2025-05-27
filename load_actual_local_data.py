#!/usr/bin/env python3
"""
Load actual current local database data to Railway
"""
import os
import sys
from database_config import get_db
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Actual clubs data from local database
ACTUAL_CLUBS_DATA = [
    (1, "Tennaqua"),
    (4, "Winnetka"),
    (6, "Hinsdale PC"),
    (7, "Onwentsia"),
    (10, "Glen View"),
    (12, "Lake Forest"),
    (18, "Butterfield"),
    (23, "Westmoreland"),
    (29, "North Shore"),
    (31, "Michigan Shores"),
    (181, "Birchwood"),
    (182, "Ravinia Green"),
    (183, "Wilmette")
]

# Actual series data from local database
ACTUAL_SERIES_DATA = [
    (182, "Series 1"),
    (183, "Series 2A"),
    (184, "Series 2B"),
    (185, "Series 3")
]

# Actual users data from local database
ACTUAL_USERS_DATA = [
    (7, "rossfreedman@gmail.com", "Ross", "Freedman", 1, 184, True),
    (8, "jessfreedman@gmail.com", "Jess", "Freedman", 1, 182, False),
    (10, "gswender@gmail.com", "Greg", "Swender", 1, 182, False),
    (11, "eli@gmail.com", "Eli", "Strick", 1, 182, False),
    (12, "brian@gmail.com", "Brian", "Fox", 1, 185, False),
    (13, "scott@gmail.com", "Scott", "Osterman", 1, 184, False)
]

def load_actual_local_data():
    """Load actual current local database data to Railway"""
    logger.info("Loading actual local database data to Railway...")
    
    # Set Railway environment
    os.environ['RAILWAY_ENVIRONMENT'] = 'production'
    
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                logger.info("Connected to Railway database successfully")
                
                # Clear existing data completely
                logger.info("Clearing existing data...")
                cursor.execute("DELETE FROM users;")
                cursor.execute("DELETE FROM clubs;")
                cursor.execute("DELETE FROM series;")
                
                # Insert actual clubs data
                logger.info("Inserting actual clubs data...")
                for club_id, club_name in ACTUAL_CLUBS_DATA:
                    cursor.execute("""
                        INSERT INTO clubs (id, name) VALUES (%s, %s);
                    """, (club_id, club_name))
                
                # Insert actual series data
                logger.info("Inserting actual series data...")
                for series_id, series_name in ACTUAL_SERIES_DATA:
                    cursor.execute("""
                        INSERT INTO series (id, name) VALUES (%s, %s);
                    """, (series_id, series_name))
                
                # Insert actual users data
                logger.info("Inserting actual users data...")
                for user_id, email, first_name, last_name, club_id, series_id, is_admin in ACTUAL_USERS_DATA:
                    cursor.execute("""
                        INSERT INTO users (id, email, password, password_hash, first_name, last_name, club_id, series_id, is_admin)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """, (
                        user_id,
                        email,
                        'password123',  # Default password for all users
                        'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f',  # SHA256 of password123
                        first_name,
                        last_name,
                        club_id,
                        series_id,
                        is_admin
                    ))
                
                # Reset sequences to correct values
                cursor.execute("SELECT setval('clubs_id_seq', (SELECT MAX(id) FROM clubs));")
                cursor.execute("SELECT setval('series_id_seq', (SELECT MAX(id) FROM series));")
                cursor.execute("SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));")
                
                conn.commit()
                
                # Verify the update
                cursor.execute("SELECT COUNT(*) FROM clubs;")
                club_count = cursor.fetchone()[0]
                
                cursor.execute("SELECT COUNT(*) FROM series;")
                series_count = cursor.fetchone()[0]
                
                cursor.execute("SELECT COUNT(*) FROM users;")
                user_count = cursor.fetchone()[0]
                
                cursor.execute("""
                    SELECT u.email, c.name as club, s.name as series 
                    FROM users u 
                    JOIN clubs c ON u.club_id = c.id 
                    JOIN series s ON u.series_id = s.id 
                    WHERE u.email = 'rossfreedman@gmail.com';
                """)
                user_info = cursor.fetchone()
                
                logger.info("Actual local data loaded successfully!")
                logger.info(f"Clubs: {club_count}, Series: {series_count}, Users: {user_count}")
                logger.info(f"Test user: {user_info[0]} - {user_info[1]} - {user_info[2]}")
                
                return True
                
    except Exception as e:
        logger.error(f"Data loading failed: {str(e)}")
        return False

if __name__ == "__main__":
    success = load_actual_local_data()
    if success:
        logger.info("✅ Actual local data loaded successfully!")
        sys.exit(0)
    else:
        logger.error("❌ Data loading failed!")
        sys.exit(1) 
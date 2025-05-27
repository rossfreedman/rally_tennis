#!/usr/bin/env python3
"""
Load exact data from local backup to Railway database
"""
import os
import sys
from database_config import get_db
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Exact clubs data from local backup (includes both Chicago and Philadelphia)
EXACT_CLUBS_DATA = [
    (1, "Tennaqua"),
    (2, "Wilmette PD"),
    (3, "Sunset Ridge"),
    (4, "Winnetka"),
    (5, "Exmoor"),
    (6, "Hinsdale PC"),
    (7, "Onwentsia"),
    (8, "Salt Creek"),
    (9, "Lakeshore S&F"),
    (10, "Glen View"),
    (11, "Prairie Club"),
    (12, "Lake Forest"),
    (13, "Evanston"),
    (14, "Midt-Bannockburn"),
    (15, "Briarwood"),
    (16, "Birchwood"),
    (17, "Hinsdale GC"),
    (18, "Butterfield"),
    (19, "Chicago Highlands"),
    (20, "Glen Ellyn"),
    (21, "Skokie"),
    (22, "Winter Club"),
    (23, "Westmoreland"),
    (24, "Valley Lo"),
    (25, "South Barrington"),
    (26, "Saddle & Cycle"),
    (27, "Ruth Lake"),
    (28, "Northmoor"),
    (29, "North Shore"),
    (30, "Midtown - Chicago"),
    (31, "Michigan Shores"),
    (32, "Lake Shore CC"),
    (33, "Knollwood"),
    (34, "Indian Hill"),
    (35, "Glenbrook RC"),
    (36, "Hawthorn Woods"),
    (37, "Lake Bluff"),
    (38, "Barrington Hills CC"),
    (39, "River Forest PD"),
    (40, "Edgewood Valley"),
    (41, "Park Ridge CC"),
    (42, "Medinah"),
    (43, "LaGrange CC"),
    (44, "Dunham Woods"),
    (45, "Bryn Mawr"),
    (46, "Glen Oak"),
    (47, "Inverness"),
    (48, "White Eagle"),
    (49, "Legends"),
    (50, "River Forest CC"),
    (51, "Oak Park CC"),
    (52, "Royal Melbourne"),
    (105, "Germantown Cricket Club"),
    (106, "Philadelphia Cricket Club"),
    (107, "Merion Cricket Club"),
    (108, "Waynesborough Country Club"),
    (109, "Aronimink Golf Club"),
    (110, "Overbrook Golf Club"),
    (111, "Radnor Valley Country Club"),
    (112, "White Manor Country Club")
]

# Exact series data from local backup (includes both Chicago and generic series)
EXACT_SERIES_DATA = [
    (1, "Chicago 1"),
    (2, "Chicago 2"),
    (3, "Chicago 3"),
    (4, "Chicago 4"),
    (5, "Chicago 5"),
    (6, "Chicago 6"),
    (7, "Chicago 7"),
    (8, "Chicago 8"),
    (9, "Chicago 9"),
    (10, "Chicago 10"),
    (11, "Chicago 11"),
    (12, "Chicago 12"),
    (13, "Chicago 13"),
    (14, "Chicago 14"),
    (15, "Chicago 15"),
    (16, "Chicago 16"),
    (17, "Chicago 17"),
    (18, "Chicago 18"),
    (19, "Chicago 19"),
    (20, "Chicago 20"),
    (21, "Chicago 21"),
    (22, "Chicago 22"),
    (23, "Chicago 23"),
    (24, "Chicago 24"),
    (25, "Chicago 25"),
    (26, "Chicago 26"),
    (27, "Chicago 27"),
    (28, "Chicago 28"),
    (29, "Chicago 29"),
    (30, "Chicago 30"),
    (31, "Chicago 31"),
    (32, "Chicago 32"),
    (33, "Chicago 33"),
    (34, "Chicago 34"),
    (35, "Chicago 35"),
    (36, "Chicago 36"),
    (37, "Chicago 37"),
    (38, "Chicago 38"),
    (39, "Chicago 39"),
    (40, "Chicago Legends"),
    (41, "Chicago 7 SW"),
    (42, "Chicago 9 SW"),
    (43, "Chicago 11 SW"),
    (44, "Chicago 13 SW"),
    (45, "Chicago 15 SW"),
    (46, "Chicago 17 SW"),
    (47, "Chicago 19 SW"),
    (48, "Chicago 21 SW"),
    (49, "Chicago 23 SW"),
    (50, "Chicago 25 SW"),
    (51, "Chicago 27 SW"),
    (52, "Chicago 29 SW"),
    (105, "Series 1"),
    (106, "Series 2"),
    (107, "Series 3"),
    (108, "Series 4"),
    (109, "Series 5"),
    (110, "Series 6"),
    (111, "Series 7"),
    (112, "Series 8")
]

def load_exact_local_data():
    """Load exact data from local backup to match local database"""
    logger.info("Loading exact local data to Railway database...")
    
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
                
                # Insert exact clubs data
                logger.info("Inserting exact clubs data...")
                for club_id, club_name in EXACT_CLUBS_DATA:
                    cursor.execute("""
                        INSERT INTO clubs (id, name) VALUES (%s, %s);
                    """, (club_id, club_name))
                
                # Insert exact series data
                logger.info("Inserting exact series data...")
                for series_id, series_name in EXACT_SERIES_DATA:
                    cursor.execute("""
                        INSERT INTO series (id, name) VALUES (%s, %s);
                    """, (series_id, series_name))
                
                # Create the test user with exact local data (Tennaqua, Chicago 22)
                logger.info("Creating test user with exact local configuration...")
                cursor.execute("""
                    INSERT INTO users (email, password, password_hash, first_name, last_name, club_id, series_id, is_admin)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    'rossfreedman@gmail.com',
                    'password123',
                    'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f',  # SHA256 of password123
                    'Ross',
                    'Freedman',
                    1,  # Tennaqua
                    22,  # Chicago 22
                    True
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
                
                cursor.execute("""
                    SELECT u.email, c.name as club, s.name as series 
                    FROM users u 
                    JOIN clubs c ON u.club_id = c.id 
                    JOIN series s ON u.series_id = s.id 
                    WHERE u.email = 'rossfreedman@gmail.com';
                """)
                user_info = cursor.fetchone()
                
                logger.info("Exact local data loaded successfully!")
                logger.info(f"Clubs: {club_count}, Series: {series_count}")
                logger.info(f"Test user: {user_info[0]} - {user_info[1]} - {user_info[2]}")
                
                return True
                
    except Exception as e:
        logger.error(f"Data loading failed: {str(e)}")
        return False

if __name__ == "__main__":
    success = load_exact_local_data()
    if success:
        logger.info("✅ Exact local data loaded successfully!")
        sys.exit(0)
    else:
        logger.error("❌ Data loading failed!")
        sys.exit(1) 
#!/usr/bin/env python3
"""
Update Railway database with correct Chicago tennis clubs and series data
"""
import os
import sys
from database_config import get_db
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Correct clubs data from backup
CLUBS_DATA = [
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
    (52, "Royal Melbourne")
]

# Correct series data from backup
SERIES_DATA = [
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
    (52, "Chicago 29 SW")
]

def update_correct_data():
    """Replace test data with correct Chicago tennis data"""
    logger.info("Updating Railway database with correct Chicago tennis data...")
    
    # Set Railway environment
    os.environ['RAILWAY_ENVIRONMENT'] = 'production'
    
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                logger.info("Connected to Railway database successfully")
                
                # Update existing clubs data first
                logger.info("Updating clubs data...")
                for club_id, club_name in CLUBS_DATA:
                    cursor.execute("""
                        INSERT INTO clubs (id, name) VALUES (%s, %s)
                        ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
                    """, (club_id, club_name))
                
                # Update existing series data
                logger.info("Updating series data...")
                for series_id, series_name in SERIES_DATA:
                    cursor.execute("""
                        INSERT INTO series (id, name) VALUES (%s, %s)
                        ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
                    """, (series_id, series_name))
                
                # Now update the test user to use Tennaqua (id=1) and Chicago 22 (id=22)
                logger.info("Updating test user with correct club and series...")
                cursor.execute("""
                    UPDATE users 
                    SET club_id = 1, series_id = 22 
                    WHERE email = 'rossfreedman@gmail.com';
                """)
                
                # Delete clubs that aren't in our list (but preserve those referenced by users)
                club_ids = [str(club[0]) for club in CLUBS_DATA]
                cursor.execute(f"""
                    DELETE FROM clubs 
                    WHERE id NOT IN ({','.join(club_ids)})
                    AND id NOT IN (SELECT DISTINCT club_id FROM users WHERE club_id IS NOT NULL);
                """)
                
                # Delete series that aren't in our list (but preserve those referenced by users)
                series_ids = [str(series[0]) for series in SERIES_DATA]
                cursor.execute(f"""
                    DELETE FROM series 
                    WHERE id NOT IN ({','.join(series_ids)})
                    AND id NOT IN (SELECT DISTINCT series_id FROM users WHERE series_id IS NOT NULL);
                """)
                
                # Reset sequences to correct values
                cursor.execute("SELECT setval('clubs_id_seq', (SELECT MAX(id) FROM clubs));")
                cursor.execute("SELECT setval('series_id_seq', (SELECT MAX(id) FROM series));")
                
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
                
                logger.info("Data update completed successfully!")
                logger.info(f"Clubs: {club_count}, Series: {series_count}")
                logger.info(f"Test user: {user_info[0]} - {user_info[1]} - {user_info[2]}")
                
                return True
                
    except Exception as e:
        logger.error(f"Data update failed: {str(e)}")
        return False

if __name__ == "__main__":
    success = update_correct_data()
    if success:
        logger.info("✅ Data update completed successfully!")
        sys.exit(0)
    else:
        logger.error("❌ Data update failed!")
        sys.exit(1) 
#!/usr/bin/env python3
"""
Create a test user in the Railway database
"""
import os
import sys
from database_config import get_db
import logging
import hashlib

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def hash_password(password):
    """Simple password hashing (you might want to use bcrypt in production)"""
    return hashlib.sha256(password.encode()).hexdigest()

def create_test_user():
    """Create a test user for login testing"""
    logger.info("Creating test user...")
    
    # Set Railway environment
    os.environ['RAILWAY_ENVIRONMENT'] = 'production'
    
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                logger.info("Connected to Railway database successfully")
                
                # Check if user already exists
                cursor.execute("""
                    SELECT id, email FROM users WHERE email = %s
                """, ('rossfreedman@gmail.com',))
                
                existing_user = cursor.fetchone()
                if existing_user:
                    logger.info(f"User already exists: {existing_user[1]} (ID: {existing_user[0]})")
                    
                    # Update password_hash if it's missing
                    cursor.execute("""
                        SELECT password, password_hash FROM users WHERE email = %s
                    """, ('rossfreedman@gmail.com',))
                    user_data = cursor.fetchone()
                    
                    if user_data and not user_data[1]:  # password_hash is None
                        hashed_password = hash_password('password123')
                        cursor.execute("""
                            UPDATE users SET password_hash = %s WHERE email = %s
                        """, (hashed_password, 'rossfreedman@gmail.com'))
                        conn.commit()
                        logger.info("Updated password_hash for existing user")
                    
                    return True
                
                # Create new test user
                logger.info("Creating new test user...")
                hashed_password = hash_password('password123')
                
                cursor.execute("""
                    INSERT INTO users (email, password, password_hash, first_name, last_name, club_id, series_id, is_admin)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    'rossfreedman@gmail.com',
                    'password123',  # Keep original for compatibility
                    hashed_password,  # New hashed version
                    'Ross',
                    'Freedman',
                    1,  # First club
                    1,  # First series
                    True  # Admin user
                ))
                
                conn.commit()
                
                logger.info("Test user created successfully!")
                logger.info("Email: rossfreedman@gmail.com")
                logger.info("Password: password123")
                
                return True
                
    except Exception as e:
        logger.error(f"User creation failed: {str(e)}")
        return False

if __name__ == "__main__":
    success = create_test_user()
    if success:
        logger.info("✅ Test user setup completed successfully!")
        sys.exit(0)
    else:
        logger.error("❌ Test user setup failed!")
        sys.exit(1) 
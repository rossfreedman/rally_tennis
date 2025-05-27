#!/usr/bin/env python3
"""
Fix the password column issue in Railway database
Add password_hash column and migrate existing data
"""
import os
import sys
from database_config import get_db
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def fix_password_column():
    """Add password_hash column and migrate data"""
    logger.info("Starting password column fix...")
    
    # Set Railway environment
    os.environ['RAILWAY_ENVIRONMENT'] = 'production'
    
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                logger.info("Connected to Railway database successfully")
                
                # Check if password_hash column exists
                cursor.execute("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'users' AND column_name = 'password_hash';
                """)
                
                if cursor.fetchone():
                    logger.info("password_hash column already exists")
                    return True
                
                # Add password_hash column
                logger.info("Adding password_hash column...")
                cursor.execute("""
                    ALTER TABLE users 
                    ADD COLUMN password_hash VARCHAR(255);
                """)
                
                # Copy data from password to password_hash
                logger.info("Migrating password data to password_hash...")
                cursor.execute("""
                    UPDATE users 
                    SET password_hash = password 
                    WHERE password_hash IS NULL;
                """)
                
                # Commit changes
                conn.commit()
                
                # Verify the fix
                cursor.execute("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'users' AND column_name IN ('password', 'password_hash')
                    ORDER BY column_name;
                """)
                columns = cursor.fetchall()
                
                logger.info("Database schema fix completed successfully!")
                logger.info(f"User table now has columns: {[col[0] for col in columns]}")
                
                return True
                
    except Exception as e:
        logger.error(f"Database fix failed: {str(e)}")
        return False

if __name__ == "__main__":
    success = fix_password_column()
    if success:
        logger.info("✅ Password column fix completed successfully!")
        sys.exit(0)
    else:
        logger.error("❌ Password column fix failed!")
        sys.exit(1) 
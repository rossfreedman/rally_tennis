#!/usr/bin/env python3
"""
Initialize Railway PostgreSQL database with Rally Tennis schema
"""
import os
import sys
from database_config import get_db
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def read_sql_file(filename):
    """Read SQL file content"""
    try:
        with open(filename, 'r') as f:
            return f.read()
    except FileNotFoundError:
        logger.error(f"SQL file {filename} not found")
        return None

def initialize_database():
    """Initialize the Railway database with schema"""
    logger.info("Starting Railway database initialization...")
    
    # Check if we're targeting Railway
    if not os.getenv('DATABASE_PUBLIC_URL') and not os.getenv('DATABASE_URL'):
        logger.error("No Railway database URL found. Please set DATABASE_URL or DATABASE_PUBLIC_URL environment variable.")
        return False
    
    # Read the schema file - prefer the simpler init file for Railway
    schema_sql = read_sql_file('init_rally_tennis.sql')
    if not schema_sql:
        # Fallback to local schema
        schema_sql = read_sql_file('local_schema.sql')
        if not schema_sql:
            logger.error("No schema file found")
            return False
    
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                logger.info("Connected to Railway database successfully")
                
                # Execute the schema
                logger.info("Executing database schema...")
                cursor.execute(schema_sql)
                conn.commit()
                
                # Verify tables were created
                cursor.execute("""
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = 'public'
                    ORDER BY table_name;
                """)
                tables = cursor.fetchall()
                
                logger.info("Database initialization completed successfully!")
                logger.info(f"Created tables: {[table[0] for table in tables]}")
                
                return True
                
    except Exception as e:
        logger.error(f"Database initialization failed: {str(e)}")
        return False

if __name__ == "__main__":
    # Set Railway environment flag
    os.environ['RAILWAY_ENVIRONMENT'] = 'production'
    
    success = initialize_database()
    if success:
        logger.info("✅ Railway database initialized successfully!")
        sys.exit(0)
    else:
        logger.error("❌ Railway database initialization failed!")
        sys.exit(1) 
#!/usr/bin/env python3
"""
Startup script for Rally Tennis app on Railway
Handles database connection issues gracefully during deployment
"""

import os
import sys
import time
import logging
from database_config import test_db_connection, get_db_url

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def wait_for_database(max_wait_time=300, check_interval=10):
    """
    Wait for database to become available
    Returns True if database is available, False if timeout
    """
    logger.info("=== Railway Tennis App Startup ===")
    logger.info(f"Checking database connectivity...")
    logger.info(f"Database URL: {get_db_url().split('@')[0]}@[REDACTED]")
    
    start_time = time.time()
    
    while time.time() - start_time < max_wait_time:
        try:
            success, error = test_db_connection()
            if success:
                logger.info("✅ Database connection successful!")
                return True
            else:
                logger.warning(f"❌ Database connection failed: {error}")
                
        except Exception as e:
            logger.warning(f"❌ Database connection error: {str(e)}")
        
        logger.info(f"⏳ Retrying in {check_interval} seconds...")
        time.sleep(check_interval)
    
    logger.error(f"❌ Database connection timeout after {max_wait_time} seconds")
    return False

def start_application():
    """Start the Flask application"""
    logger.info("🚀 Starting Rally Tennis application...")
    
    # Import and run the Flask app
    try:
        from server import app
        
        # Get port from environment
        port = int(os.environ.get('PORT', 3000))
        host = '0.0.0.0'
        
        logger.info(f"🌐 Starting server on {host}:{port}")
        
        # Start the Flask development server
        # Note: In production, this should be replaced with gunicorn
        app.run(host=host, port=port, debug=False)
        
    except Exception as e:
        logger.error(f"❌ Failed to start application: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    # Check if we should wait for database
    wait_for_db = os.environ.get('WAIT_FOR_DB', 'true').lower() == 'true'
    
    if wait_for_db:
        # Wait for database to be available
        db_available = wait_for_database()
        
        if not db_available:
            logger.warning("⚠️  Database not available, but starting app anyway...")
            logger.warning("⚠️  Some features may not work until database is connected")
    else:
        logger.info("⏭️  Skipping database connectivity check")
    
    # Start the application
    start_application() 
import os
import psycopg2
from psycopg2.extras import DictCursor
from urllib.parse import urlparse
import logging

# Set up logging
logger = logging.getLogger(__name__)

def get_db_connection():
    """Get a PostgreSQL database connection"""
    try:
        # Get DATABASE_URL from environment
        database_url = os.getenv('DATABASE_URL')
        
        if database_url:
            # Handle Railway's postgres:// URLs
            if database_url.startswith('postgres://'):
                database_url = database_url.replace('postgres://', 'postgresql://', 1)
            
            # Parse the URL
            parsed = urlparse(database_url)
            
            # Determine SSL mode - require for Railway connections
            hostname = parsed.hostname or ''
            sslmode = 'require' if ('railway.app' in hostname or 'rlwy.net' in hostname or 'railway.internal' in hostname) else 'prefer'
            
            # Use Railway's timeout setting if available, otherwise use a shorter default
            connect_timeout = int(os.getenv('PGCONNECT_TIMEOUT', '30'))
            
            conn = psycopg2.connect(
                dbname=parsed.path[1:],
                user=parsed.username,
                password=parsed.password,
                host=parsed.hostname,
                port=parsed.port or 5432,
                sslmode=sslmode,
                connect_timeout=connect_timeout,
                application_name='rally_tennis_admin',
                keepalives_idle=600,
                keepalives_interval=30,
                keepalives_count=3,
                tcp_user_timeout=30000,  # 30 seconds in milliseconds
                target_session_attrs='read-write'
            )
        else:
            # Fallback to individual environment variables for local development
            conn = psycopg2.connect(
                dbname=os.getenv('POSTGRES_DB', 'rally'),
                user=os.getenv('POSTGRES_USER', 'postgres'),
                password=os.getenv('POSTGRES_PASSWORD'),
                host=os.getenv('POSTGRES_HOST', 'localhost'),
                port=os.getenv('POSTGRES_PORT', '5432')
            )
        return conn
    except Exception as e:
        logger.error(f"Error connecting to database: {str(e)}")
        raise

def execute_query(query, params=None):
    """Execute a query and return all results"""
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=DictCursor) as cursor:
            cursor.execute(query, params or {})
            results = cursor.fetchall()
            return [dict(row) for row in results]
    finally:
        conn.close()

def execute_query_one(query, params=None):
    """Execute a query and return one result"""
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=DictCursor) as cursor:
            cursor.execute(query, params or {})
            result = cursor.fetchone()
            return dict(result) if result else None
    finally:
        conn.close()

def execute_update(query, params=None):
    """Execute an update query and return success status"""
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(query, params or {})
            conn.commit()
            return True
    except Exception as e:
        print(f"Error executing update: {str(e)}")
        conn.rollback()
        return False
    finally:
        conn.close() 
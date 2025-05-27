import os
import psycopg2
from psycopg2.extras import DictCursor
from contextlib import contextmanager
from dotenv import load_dotenv
from urllib.parse import urlparse
import logging

# Load environment variables
load_dotenv()

# Set up logging
logger = logging.getLogger(__name__)

def get_db_url():
    """Get database URL from environment or use default"""
    url = os.getenv('DATABASE_URL', 'postgresql://localhost/rally')
    
    # Handle Railway's postgres:// URLs
    if url.startswith('postgres://'):
        url = url.replace('postgres://', 'postgresql://', 1)
    
    return url

def parse_db_url(url):
    """Parse database URL into connection parameters"""
    parsed = urlparse(url)
    
    # Determine SSL mode - require for Railway connections
    hostname = parsed.hostname or ''
    sslmode = 'require' if ('railway.app' in hostname or 'rlwy.net' in hostname or 'railway.internal' in hostname) else 'prefer'
    
    # Use Railway's timeout setting if available, otherwise use a shorter default
    connect_timeout = int(os.getenv('PGCONNECT_TIMEOUT', '30'))
    
    return {
        'dbname': parsed.path[1:],
        'user': parsed.username,
        'password': parsed.password,
        'host': parsed.hostname,
        'port': parsed.port or 5432,
        'sslmode': sslmode,
        'connect_timeout': connect_timeout,
        'application_name': 'rally_tennis_core',
        'keepalives_idle': 600,
        'keepalives_interval': 30,
        'keepalives_count': 3,
        'tcp_user_timeout': 30000,  # 30 seconds in milliseconds
        'target_session_attrs': 'read-write'
    }

@contextmanager
def get_db():
    """Get database connection"""
    db_params = parse_db_url(get_db_url())
    try:
        conn = psycopg2.connect(**db_params)
        yield conn
    except Exception as e:
        logger.error(f"Database connection error: {str(e)}")
        logger.error(f"Connection params (excluding password): {dict(dbname=db_params['dbname'], user=db_params['user'], host=db_params['host'], port=db_params['port'], sslmode=db_params['sslmode'])}")
        raise
    finally:
        if 'conn' in locals():
            conn.close() 
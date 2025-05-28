import os
from sqlalchemy import create_engine, MetaData, Table, Column, Integer, String, Boolean, Date, DateTime, ForeignKey, Text
from sqlalchemy.sql import text
from sqlalchemy.ext.declarative import declarative_base
from dotenv import load_dotenv
from urllib.parse import urlparse
import logging
from sqlalchemy.engine import URL
from sqlalchemy import event
from sqlalchemy.exc import OperationalError, SQLAlchemyError
from sqlalchemy.dialects.postgresql import TIMESTAMP

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

def get_railway_url():
    """Get the appropriate Railway database URL"""
    # Use the working connection URL with the proxy domain
    return "postgresql://postgres:OoxuYNiTfyRqbqyoFTNTUHRGjtjHVscf@trolley.proxy.rlwy.net:34555/railway"

RAILWAY_DB_URL = get_railway_url()

# Create SQLAlchemy base
Base = declarative_base()

# Define models based on your schema
class Series(Base):
    __tablename__ = 'series'
    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False, unique=True)

class Club(Base):
    __tablename__ = 'clubs'
    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False, unique=True)

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    email = Column(String(255), nullable=False, unique=True)
    password_hash = Column(String(255), nullable=False)
    first_name = Column(String(255), nullable=False)
    last_name = Column(String(255), nullable=False)
    club_id = Column(Integer, ForeignKey('clubs.id'))
    series_id = Column(Integer, ForeignKey('series.id'))
    club_automation_password = Column(String(255))
    created_at = Column(DateTime, server_default=text('CURRENT_TIMESTAMP'))
    last_login = Column(DateTime)
    is_admin = Column(Boolean, nullable=False, server_default=text('false'))

class PlayerAvailability(Base):
    __tablename__ = 'player_availability'
    id = Column(Integer, primary_key=True)
    player_name = Column(String(255), nullable=False)
    match_date = Column(TIMESTAMP(timezone=True), nullable=False)
    availability_status = Column(Integer, nullable=False, server_default=text('3'))
    updated_at = Column(DateTime, server_default=text('CURRENT_TIMESTAMP'))
    series_id = Column(Integer, ForeignKey('series.id'), nullable=False)

class UserActivityLog(Base):
    __tablename__ = 'user_activity_logs'
    id = Column(Integer, primary_key=True)
    user_email = Column(String(255), nullable=False)
    activity_type = Column(String(255), nullable=False)
    page = Column(String(255))
    action = Column(Text)
    details = Column(Text)
    ip_address = Column(String(45))
    timestamp = Column(DateTime, server_default=text('CURRENT_TIMESTAMP'))

class UserInstruction(Base):
    __tablename__ = 'user_instructions'
    id = Column(Integer, primary_key=True)
    user_email = Column(String(255), nullable=False)
    instruction = Column(Text, nullable=False)
    team_id = Column(Integer)
    created_at = Column(DateTime, server_default=text('CURRENT_TIMESTAMP'))
    is_active = Column(Boolean, nullable=False, server_default=text('true'))

def create_engine_with_timezone():
    """Create SQLAlchemy engine with proper timezone configuration"""
    url = get_railway_url()
    
    # Add timezone configuration to the connection
    engine = create_engine(
        url,
        pool_pre_ping=True,
        pool_recycle=300,
        connect_args={
            "options": "-c timezone=America/Chicago"
        }
    )
    
    # Set timezone for all connections
    @event.listens_for(engine, "connect")
    def set_timezone(dbapi_connection, connection_record):
        with dbapi_connection.cursor() as cursor:
            cursor.execute("SET timezone = 'America/Chicago'")
    
    return engine

def sync_schema():
    """Sync the schema with Railway database"""
    try:
        engine = create_engine_with_timezone()
        
        logger.info("Connecting to Railway database...")
        
        # Test connection
        with engine.connect() as conn:
            result = conn.execute(text("SELECT current_setting('timezone') as tz"))
            tz = result.fetchone()[0]
            logger.info(f"Connected successfully! Database timezone: {tz}")
        
        logger.info("Creating/updating tables...")
        
        # Create all tables
        Base.metadata.create_all(engine)
        
        logger.info("Schema sync completed successfully!")
        
        # Verify the schema
        with engine.connect() as conn:
            # Check if player_availability table has the correct column type
            result = conn.execute(text("""
                SELECT column_name, data_type, is_nullable
                FROM information_schema.columns
                WHERE table_name = 'player_availability'
                AND column_name = 'match_date'
            """))
            
            column_info = result.fetchone()
            if column_info:
                logger.info(f"player_availability.match_date column: {column_info[1]} (nullable: {column_info[2]})")
            else:
                logger.warning("Could not verify player_availability.match_date column")
        
    except Exception as e:
        logger.error(f"Error syncing schema: {str(e)}")
        raise

if __name__ == "__main__":
    sync_schema() 
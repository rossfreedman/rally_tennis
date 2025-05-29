"""
Date utilities for consistent timezone-aware date handling
Addresses the timezone issues with Railway PostgreSQL
"""

from datetime import datetime, date, timezone
import pytz

# Application timezone - all dates should be interpreted in this timezone
APP_TIMEZONE = pytz.timezone('America/Chicago')

def date_to_db_timestamp(date_obj):
    """
    Convert a date object to a timezone-aware timestamp for database storage.
    After TIMESTAMPTZ migration, stores at midnight UTC for consistency.
    
    Args:
        date_obj: datetime.date, datetime.datetime, or string in various formats (YYYY-MM-DD, MM/DD/YYYY, etc.)
    
    Returns:
        datetime: Timezone-aware datetime at midnight UTC
    """
    if isinstance(date_obj, str):
        # First normalize the date string to YYYY-MM-DD format
        normalized_date_str = normalize_date_string(date_obj)
        date_obj = datetime.strptime(normalized_date_str, '%Y-%m-%d').date()
    elif isinstance(date_obj, datetime):
        date_obj = date_obj.date()
    
    # Create midnight timestamp in UTC
    midnight_dt = datetime.combine(date_obj, datetime.min.time())
    return midnight_dt.replace(tzinfo=timezone.utc)

def db_timestamp_to_date(timestamp_obj):
    """
    Convert a database timestamp back to a date object.
    
    Args:
        timestamp_obj: timezone-aware datetime from database
    
    Returns:
        date: Date object in application timezone
    """
    if timestamp_obj is None:
        return None
    
    # Convert to application timezone and extract date
    local_dt = timestamp_obj.astimezone(APP_TIMEZONE)
    return local_dt.date()

def normalize_date_string(date_str):
    """
    Normalize various date string formats to YYYY-MM-DD.
    
    Args:
        date_str: Date string in various formats
    
    Returns:
        str: Date string in YYYY-MM-DD format
    """
    if not date_str:
        return None
    
    # Try different formats
    formats = [
        '%Y-%m-%d',     # 2025-05-26
        '%m/%d/%Y',     # 05/26/2025
        '%m/%d/%y',     # 05/26/25
        '%Y/%m/%d',     # 2025/05/26
    ]
    
    for fmt in formats:
        try:
            dt = datetime.strptime(date_str, fmt)
            return dt.strftime('%Y-%m-%d')
        except ValueError:
            continue
    
    raise ValueError(f"Unable to parse date string: {date_str}")

def format_date_for_display(date_obj):
    """
    Format a date for display with day of week.
    
    Args:
        date_obj: date object or YYYY-MM-DD string
    
    Returns:
        str: Formatted date like "Monday 5/26/25"
    """
    if isinstance(date_obj, str):
        date_obj = datetime.strptime(date_obj, '%Y-%m-%d').date()
    
    day_of_week = date_obj.strftime('%A')
    date_str = date_obj.strftime('%-m/%-d/%y')  # Remove leading zeros
    return f"{day_of_week} {date_str}"

def is_same_date(date1, date2):
    """
    Compare two dates for equality, handling various input types.
    
    Args:
        date1, date2: date objects, datetime objects, or YYYY-MM-DD strings
    
    Returns:
        bool: True if dates represent the same day
    """
    def normalize_to_date(d):
        if isinstance(d, str):
            return datetime.strptime(normalize_date_string(d), '%Y-%m-%d').date()
        elif isinstance(d, datetime):
            return d.date()
        return d
    
    return normalize_to_date(date1) == normalize_to_date(date2)

# Database query helpers
def build_date_query(table_alias="", date_column="match_date"):
    """
    Build SQL for date comparison with TIMESTAMPTZ columns.
    
    After migration to TIMESTAMPTZ with midnight UTC storage, we can use simple DATE() extraction.
    
    Returns:
        str: SQL fragment like "DATE(match_date)"
    """
    prefix = f"{table_alias}." if table_alias else ""
    return f"DATE({prefix}{date_column})"

def build_date_params(date_value):
    """
    Build parameters for date queries with TIMESTAMPTZ columns.
    
    Args:
        date_value: date, datetime, or string
    
    Returns:
        datetime: Timezone-aware datetime at midnight UTC for database queries
    """
    return date_to_db_timestamp(date_value) 
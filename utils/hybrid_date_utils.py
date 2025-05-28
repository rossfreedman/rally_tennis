"""
Hybrid date approach: Store as strings, operate as dates
This provides the predictability of strings with the functionality of dates
"""

import re
from datetime import datetime, date
from typing import Union, Optional, List

class DateString:
    """
    A date-like class that stores dates as strings internally
    but provides date functionality for operations
    """
    
    def __init__(self, value: Union[str, date, datetime]):
        """Initialize with various date types"""
        if isinstance(value, str):
            self._value = self._normalize_string(value)
        elif isinstance(value, (date, datetime)):
            self._value = value.strftime('%Y-%m-%d')
        else:
            raise ValueError(f"Invalid date value: {value}")
    
    def _normalize_string(self, date_str: str) -> str:
        """Normalize date string to YYYY-MM-DD format"""
        # Remove any extra whitespace
        date_str = date_str.strip()
        
        # If already in correct format, return as-is
        if re.match(r'^\d{4}-\d{2}-\d{2}$', date_str):
            return date_str
        
        # Try various formats
        formats = [
            '%m/%d/%Y',     # 05/26/2025
            '%m/%d/%y',     # 05/26/25
            '%Y/%m/%d',     # 2025/05/26
            '%d-%m-%Y',     # 26-05-2025
            '%Y.%m.%d',     # 2025.05.26
        ]
        
        for fmt in formats:
            try:
                dt = datetime.strptime(date_str, fmt)
                return dt.strftime('%Y-%m-%d')
            except ValueError:
                continue
        
        raise ValueError(f"Cannot parse date string: {date_str}")
    
    @property
    def value(self) -> str:
        """Get the string value"""
        return self._value
    
    def to_date(self) -> date:
        """Convert to Python date object"""
        return datetime.strptime(self._value, '%Y-%m-%d').date()
    
    def to_display(self) -> str:
        """Format for display like 'Monday 5/26/25'"""
        dt = self.to_date()
        day_of_week = dt.strftime('%A')
        date_str = dt.strftime('%-m/%-d/%y')
        return f"{day_of_week} {date_str}"
    
    def __str__(self) -> str:
        return self._value
    
    def __repr__(self) -> str:
        return f"DateString('{self._value}')"
    
    def __eq__(self, other) -> bool:
        if isinstance(other, DateString):
            return self._value == other._value
        elif isinstance(other, str):
            try:
                other_normalized = DateString(other)._value
                return self._value == other_normalized
            except ValueError:
                return False
        elif isinstance(other, (date, datetime)):
            return self._value == other.strftime('%Y-%m-%d')
        return False
    
    def __lt__(self, other) -> bool:
        if isinstance(other, DateString):
            return self._value < other._value
        elif isinstance(other, str):
            other_normalized = DateString(other)._value
            return self._value < other_normalized
        elif isinstance(other, (date, datetime)):
            return self._value < other.strftime('%Y-%m-%d')
        return NotImplemented
    
    def __le__(self, other) -> bool:
        return self == other or self < other
    
    def __gt__(self, other) -> bool:
        return not self <= other
    
    def __ge__(self, other) -> bool:
        return not self < other

# Utility functions for database operations
def create_date_string(value) -> DateString:
    """Create a DateString from any date-like value"""
    return DateString(value)

def query_dates_between(start_date, end_date) -> str:
    """Generate SQL for date range queries"""
    start = DateString(start_date).value
    end = DateString(end_date).value
    return f"match_date BETWEEN '{start}' AND '{end}'"

def sort_date_strings(date_list: List[str]) -> List[str]:
    """Sort a list of date strings chronologically"""
    date_objects = [DateString(d) for d in date_list]
    sorted_objects = sorted(date_objects)
    return [d.value for d in sorted_objects]

# Database schema for hybrid approach
HYBRID_SCHEMA = """
-- Using VARCHAR with check constraint for date format validation
CREATE TABLE player_availability (
    id SERIAL PRIMARY KEY,
    player_name VARCHAR(255) NOT NULL,
    match_date VARCHAR(10) NOT NULL CHECK (match_date ~ '^\\d{4}-\\d{2}-\\d{2}$'),
    availability_status INTEGER NOT NULL,
    series_id INTEGER REFERENCES series(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(player_name, match_date, series_id)
);

-- Index for efficient date range queries
CREATE INDEX idx_player_availability_date ON player_availability(match_date);
""" 
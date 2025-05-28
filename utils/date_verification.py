"""
Date verification utilities for ensuring correct dates in database operations
Conservative approach that works with existing schema
"""

from datetime import datetime, date, timedelta
import logging

# Set up logging for date operations
logger = logging.getLogger(__name__)

def verify_and_fix_date_for_storage(input_date, intended_display_date=None):
    """
    Verify and potentially fix a date before storing in database.
    
    This function addresses the Railway PostgreSQL timezone issue by ensuring
    the stored date matches the user's intended date.
    
    Args:
        input_date: The date to be stored (string, date, or datetime)
        intended_display_date: What the user sees on screen (for verification)
    
    Returns:
        tuple: (corrected_date_string, verification_info)
    """
    verification_info = {
        'original_input': str(input_date),
        'intended_display': str(intended_display_date) if intended_display_date else None,
        'correction_applied': False,
        'final_date': None,
        'warning': None
    }
    
    try:
        # Normalize input date to YYYY-MM-DD format
        if isinstance(input_date, str):
            normalized_date = normalize_date_string(input_date)
        elif isinstance(input_date, (date, datetime)):
            normalized_date = input_date.strftime('%Y-%m-%d')
        else:
            raise ValueError(f"Invalid date type: {type(input_date)}")
        
        verification_info['final_date'] = normalized_date
        
        # If we have an intended display date, verify consistency
        if intended_display_date:
            intended_normalized = normalize_date_string(str(intended_display_date))
            
            if normalized_date != intended_normalized:
                # Dates don't match - this indicates a timezone issue
                logger.warning(f"Date mismatch detected: input={normalized_date}, intended={intended_normalized}")
                
                # Apply correction based on the intended display date
                verification_info['final_date'] = intended_normalized
                verification_info['correction_applied'] = True
                verification_info['warning'] = f"Corrected {normalized_date} to {intended_normalized}"
                
                logger.info(f"Applied date correction: {normalized_date} -> {intended_normalized}")
        
        logger.info(f"Date verification complete: {verification_info}")
        return verification_info['final_date'], verification_info
        
    except Exception as e:
        logger.error(f"Error in date verification: {e}")
        verification_info['warning'] = f"Error: {str(e)}"
        return str(input_date), verification_info

def verify_date_from_database(stored_date, expected_display_format=None):
    """
    Verify a date retrieved from database and ensure it displays correctly.
    
    Args:
        stored_date: Date from database
        expected_display_format: Expected format like "Monday 5/26/25"
    
    Returns:
        tuple: (display_date_string, verification_info)
    """
    verification_info = {
        'stored_value': str(stored_date),
        'correction_applied': False,
        'display_date': None,
        'warning': None
    }
    
    try:
        # Convert stored date to display format
        if isinstance(stored_date, str):
            date_obj = datetime.strptime(stored_date, '%Y-%m-%d').date()
        elif isinstance(stored_date, (date, datetime)):
            date_obj = stored_date if isinstance(stored_date, date) else stored_date.date()
        else:
            raise ValueError(f"Invalid stored date type: {type(stored_date)}")
        
        # Check if we need to apply Railway correction
        corrected_date = check_railway_date_correction(date_obj)
        if corrected_date != date_obj:
            verification_info['correction_applied'] = True
            verification_info['warning'] = f"Applied Railway correction: {date_obj} -> {corrected_date}"
            date_obj = corrected_date
            logger.info(f"Applied Railway date correction: {stored_date} -> {corrected_date}")
        
        # Format for display
        display_date = format_date_for_display(date_obj)
        verification_info['display_date'] = display_date
        
        logger.info(f"Date retrieval verification: {verification_info}")
        return display_date, verification_info
        
    except Exception as e:
        logger.error(f"Error in date retrieval verification: {e}")
        verification_info['warning'] = f"Error: {str(e)}"
        return str(stored_date), verification_info

def check_railway_date_correction(date_obj):
    """
    Check if a date needs Railway timezone correction.
    
    This addresses the known issue where Railway PostgreSQL stores dates
    one day behind due to timezone handling.
    
    Args:
        date_obj: date object to check
    
    Returns:
        date: Corrected date if needed, original date otherwise
    """
    # For now, we'll detect the Railway environment and apply correction
    # You can refine this logic based on your specific needs
    
    import os
    is_railway = os.getenv('RAILWAY_ENVIRONMENT') is not None or os.getenv('DATABASE_URL', '').find('railway') != -1
    
    if is_railway:
        # On Railway, dates are typically stored one day behind
        # Add one day to compensate
        corrected_date = date_obj + timedelta(days=1)
        logger.info(f"Railway correction applied: {date_obj} -> {corrected_date}")
        return corrected_date
    
    return date_obj

def normalize_date_string(date_str):
    """
    Normalize various date string formats to YYYY-MM-DD.
    """
    if not date_str:
        return None
    
    date_str = str(date_str).strip()
    
    # If already in YYYY-MM-DD format, return as-is
    if len(date_str) == 10 and date_str.count('-') == 2:
        try:
            # Validate it's actually a valid date
            datetime.strptime(date_str, '%Y-%m-%d')
            return date_str
        except ValueError:
            pass
    
    # Try different formats
    formats = [
        '%m/%d/%Y',     # 05/26/2025
        '%m/%d/%y',     # 05/26/25
        '%Y/%m/%d',     # 2025/05/26
        '%Y-%m-%d',     # 2025-05-26
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
    """
    if isinstance(date_obj, str):
        date_obj = datetime.strptime(date_obj, '%Y-%m-%d').date()
    
    day_of_week = date_obj.strftime('%A')
    date_str = date_obj.strftime('%-m/%-d/%y')  # Remove leading zeros
    return f"{day_of_week} {date_str}"

def log_date_operation(operation, input_data, output_data, verification_info):
    """
    Log date operations for debugging and monitoring.
    """
    logger.info(f"""
=== DATE OPERATION LOG ===
Operation: {operation}
Input: {input_data}
Output: {output_data}
Verification: {verification_info}
=========================""") 
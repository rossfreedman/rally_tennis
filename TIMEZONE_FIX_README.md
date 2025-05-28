# Timezone Date Issue Fix

## Problem Description

The Rally Tennis application was experiencing a timezone-related date issue where dates stored in the PostgreSQL database were appearing one day behind the intended date. This was happening because:

1. **DATE vs TIMESTAMPTZ**: The `player_availability` table was using PostgreSQL's `DATE` data type, which doesn't store timezone information
2. **Timezone Mismatch**: Railway's PostgreSQL runs in UTC, while the application logic assumes Central Time (America/Chicago)
3. **Date Conversion Issues**: When dates were converted between timezones during storage/retrieval, they could shift by one day

## Root Cause

PostgreSQL's `DATE` data type only stores the date without time information. When used in conjunction with timezone-sensitive operations, this can cause the displayed date to be off by one day if:

- The database timezone doesn't match the application timezone
- Date parsing/conversion logic doesn't account for timezone differences
- Dates are stored at midnight and cross timezone boundaries

## Solution Overview

The fix involves several coordinated changes:

### 1. Database Schema Migration
- Convert `match_date` column from `DATE` to `TIMESTAMPTZ` (timestamp with timezone)
- Store dates at noon in Central Time to avoid edge cases
- Add a helper function for consistent date normalization

### 2. Application Code Updates
- Add timezone-aware date handling using `pytz`
- Implement consistent date normalization across all date operations
- Update database connection to set timezone explicitly

### 3. Database Connection Configuration
- Set session timezone to 'America/Chicago' for all connections
- Add timezone options to connection parameters

## Files Modified

### Database Schema
- `migrations/fix_timezone_date_issue.sql` - Main migration script
- `sync_railway_schema.py` - Updated SQLAlchemy schema definition

### Application Code
- `database_config.py` - Added timezone configuration to database connections
- `routes/act/availability.py` - Updated availability handling with timezone support
- `server.py` - Updated availability functions to use new timezone handling
- `requirements.txt` - Added `pytz` dependency

### Testing and Migration
- `run_timezone_migration.py` - Script to run migration and test the fix
- `TIMEZONE_FIX_README.md` - This documentation

## How to Apply the Fix

### Step 1: Install Dependencies
```bash
pip install pytz==2024.1
```

### Step 2: Run the Migration
```bash
python run_timezone_migration.py
```

This script will:
- Verify current database schema
- Run the migration to convert DATE to TIMESTAMPTZ
- Test the fix with various date formats
- Verify everything works correctly

### Step 3: Deploy to Railway
After testing locally, deploy the changes to Railway:

```bash
# Commit all changes
git add .
git commit -m "Fix timezone date issue - convert DATE to TIMESTAMPTZ"
git push

# Railway will automatically deploy the changes
```

### Step 4: Run Migration on Railway
Once deployed, you can run the migration on Railway either:

1. **Via Railway Console**: Execute the SQL migration script directly
2. **Via Application**: The migration script can be run through the application

## Technical Details

### Date Normalization Function
```python
def normalize_date_for_db(date_input, target_timezone='America/Chicago'):
    """
    Normalize date input to a consistent TIMESTAMPTZ format.
    Always stores dates at noon in the target timezone to avoid edge cases.
    """
```

### Database Query Changes
Before:
```sql
WHERE match_date = DATE(%(match_date)s)
```

After:
```sql
WHERE DATE(match_date AT TIME ZONE 'America/Chicago') = DATE(%(match_date)s AT TIME ZONE 'America/Chicago')
```

### Connection Configuration
```python
connect_args={
    "options": "-c timezone=America/Chicago"
}
```

## Testing

The fix includes comprehensive testing:

1. **Date Format Compatibility**: Tests MM/DD/YYYY and YYYY-MM-DD formats
2. **Cross-Format Retrieval**: Ensures dates stored in one format can be retrieved using another
3. **Edge Cases**: Tests end-of-month dates and timezone boundaries
4. **Schema Verification**: Confirms database schema changes are applied correctly

## Benefits

After applying this fix:

1. **Consistent Date Storage**: All dates are stored with timezone information
2. **No More Off-by-One Errors**: Dates will display correctly regardless of timezone
3. **Format Flexibility**: Application can handle multiple date input formats
4. **Future-Proof**: Timezone handling is built into the database schema

## Rollback Plan

If issues arise, the migration creates a backup table (`player_availability_backup`) that can be used to restore the original data:

```sql
-- Emergency rollback (if needed)
DROP TABLE player_availability;
ALTER TABLE player_availability_backup RENAME TO player_availability;
-- Note: You'll need to recreate indexes and constraints
```

## Monitoring

After deployment, monitor:

1. **Date Display**: Verify dates appear correctly in the UI
2. **Availability Updates**: Test setting and retrieving player availability
3. **Error Logs**: Watch for any timezone-related errors
4. **Database Performance**: Ensure queries perform well with new column type

## Support

If you encounter issues:

1. Check the application logs for timezone-related errors
2. Verify the database timezone setting: `SELECT current_setting('timezone')`
3. Test date operations using the provided test script
4. Review the migration backup table if data restoration is needed 
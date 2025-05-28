-- Migration to fix timezone date issues
-- This converts DATE columns to TIMESTAMPTZ to prevent off-by-one date issues

BEGIN;

-- Step 1: Set the session timezone to ensure consistent behavior
SET timezone = 'America/Chicago';

-- Step 2: Create a backup of the current data
CREATE TABLE IF NOT EXISTS player_availability_backup AS 
SELECT * FROM player_availability;

-- Step 3: Add a new column with TIMESTAMPTZ type
ALTER TABLE player_availability 
ADD COLUMN match_datetime TIMESTAMPTZ;

-- Step 4: Populate the new column with proper timezone handling
-- Convert DATE to TIMESTAMPTZ at noon in the specified timezone to avoid edge cases
UPDATE player_availability 
SET match_datetime = (match_date::text || ' 12:00:00')::timestamp AT TIME ZONE 'America/Chicago';

-- Step 5: Verify the conversion worked correctly
DO $$
DECLARE
    date_count INTEGER;
    datetime_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO date_count FROM player_availability WHERE match_date IS NOT NULL;
    SELECT COUNT(*) INTO datetime_count FROM player_availability WHERE match_datetime IS NOT NULL;
    
    IF date_count != datetime_count THEN
        RAISE EXCEPTION 'Date conversion failed: % dates vs % datetimes', date_count, datetime_count;
    END IF;
    
    RAISE NOTICE 'Successfully converted % date records to timestamptz', datetime_count;
END $$;

-- Step 6: Drop the old DATE column and rename the new one
ALTER TABLE player_availability DROP COLUMN match_date;
ALTER TABLE player_availability RENAME COLUMN match_datetime TO match_date;

-- Step 7: Make the new column NOT NULL
ALTER TABLE player_availability ALTER COLUMN match_date SET NOT NULL;

-- Step 8: Recreate the unique constraint with the new column
ALTER TABLE player_availability DROP CONSTRAINT IF EXISTS player_availability_player_name_match_date_series_id_key;
ALTER TABLE player_availability ADD CONSTRAINT player_availability_player_name_match_date_series_id_key 
    UNIQUE (player_name, match_date, series_id);

-- Step 9: Recreate the index for better performance
DROP INDEX IF EXISTS idx_player_availability;
CREATE INDEX idx_player_availability ON player_availability(player_name, match_date, series_id);

-- Step 10: Add a function to ensure dates are always stored consistently
CREATE OR REPLACE FUNCTION normalize_match_date(input_date TEXT, tz TEXT DEFAULT 'America/Chicago')
RETURNS TIMESTAMPTZ AS $$
BEGIN
    -- Convert input date to timestamptz at noon in the specified timezone
    -- This prevents timezone conversion issues
    RETURN (input_date || ' 12:00:00')::timestamp AT TIME ZONE tz;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMIT;

-- Verification queries (run these after the migration)
-- SELECT 'Migration completed successfully' as status;
-- SELECT COUNT(*) as total_records FROM player_availability;
-- SELECT match_date, timezone('America/Chicago', match_date) as local_time 
-- FROM player_availability LIMIT 5; 
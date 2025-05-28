-- Migration to fix date handling issues
-- This addresses the timezone problems with DATE type on Railway

BEGIN;

-- Step 1: Add new column with proper timezone handling
ALTER TABLE player_availability 
ADD COLUMN match_date_tz TIMESTAMPTZ;

-- Step 2: Migrate existing data, assuming stored dates are in Chicago timezone
UPDATE player_availability 
SET match_date_tz = (match_date::text || ' 12:00:00')::timestamp AT TIME ZONE 'America/Chicago';

-- Step 3: Drop old column and rename new one
ALTER TABLE player_availability DROP COLUMN match_date;
ALTER TABLE player_availability RENAME COLUMN match_date_tz TO match_date;

-- Step 4: Add check constraint to ensure we only store "noon" times (date-only semantics)
ALTER TABLE player_availability 
ADD CONSTRAINT check_noon_time 
CHECK (EXTRACT(hour FROM match_date AT TIME ZONE 'America/Chicago') = 12 
       AND EXTRACT(minute FROM match_date AT TIME ZONE 'America/Chicago') = 0);

COMMIT;

-- Usage examples:
-- Insert a date: INSERT INTO player_availability (match_date, ...) 
--                VALUES ('2025-05-26 12:00:00'::timestamp AT TIME ZONE 'America/Chicago', ...);
-- Query by date: WHERE DATE(match_date AT TIME ZONE 'America/Chicago') = '2025-05-26' 
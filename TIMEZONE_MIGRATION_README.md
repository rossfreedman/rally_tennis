# Timezone Migration: Fix DATE to TIMESTAMPTZ

## 🎯 Problem Statement

The `player_availability` table was using a `DATE` column type for `match_date`, which doesn't store timezone information. This caused **off-by-one-day errors** when:

1. **Railway's PostgreSQL** (UTC timezone) stored dates
2. **Application/UI** interpreted dates in different timezones (America/Chicago)
3. **Date conversions** happened between client and server

### Example of the Bug
- User selects: `June 1, 2025` in the UI
- Database stores: `2025-05-31` (off by one day)
- User sees: Wrong date when viewing availability

---

## ✅ Solution Overview

**Convert `match_date` from `DATE` to `TIMESTAMPTZ`** and store all dates as **midnight UTC** for consistency.

### Key Changes:
1. **Database Schema**: `DATE` → `TIMESTAMPTZ` with midnight UTC constraint
2. **Code Updates**: Simplified date handling, removed complex timezone conversions
3. **Consistency**: All date operations now use midnight UTC as the standard

---

## 🚀 Migration Details

### Migration File
```
alembic/versions/1c2bac3892b6_fix_timezone_date_issue_convert_date_to_.py
```

### What the Migration Does:

1. **Converts Column Type**:
   ```sql
   ALTER COLUMN match_date TYPE TIMESTAMPTZ USING match_date::timestamptz
   ```

2. **Adds Midnight UTC Constraint**:
   ```sql
   CHECK (date_part('hour', match_date AT TIME ZONE 'UTC') = 0 AND ...)
   ```

3. **Updates `updated_at` Column**: Also converts to `TIMESTAMPTZ`

4. **Creates Optimized Index**: For date-based queries

### Data Safety
- ✅ **Preserves existing data** by casting `DATE` values to midnight UTC timestamps
- ✅ **Rollback available** via `downgrade()` function
- ✅ **No data loss** during conversion

---

## 🔧 Code Changes

### Updated Functions

#### `routes/act/availability.py`
- **`normalize_date_for_db()`**: Now stores as midnight UTC instead of noon Chicago time
- **`get_player_availability()`**: Simplified query without timezone conversions
- **`update_player_availability()`**: Removed complex timezone handling

#### `utils/date_utils.py`
- **`date_to_db_timestamp()`**: Returns midnight UTC timestamps
- **`build_date_query()`**: Simplified to `DATE(match_date)` instead of timezone-specific queries

#### `server.py`
- **`get_player_availability()`**: Updated query to use simplified date comparison

### Before vs After

#### Before (Complex Timezone Handling):
```sql
WHERE DATE(match_date AT TIME ZONE 'America/Chicago') = DATE(%(date)s AT TIME ZONE 'America/Chicago')
```

#### After (Simple Date Comparison):
```sql
WHERE DATE(match_date) = DATE(%(date)s)
```

---

## 🧪 Testing

### Test Script
Run the test script to verify all components work:
```bash
python test_migration.py
```

### Test Results
- ✅ Date normalization handles all input types
- ✅ UTC timezone consistency across functions
- ✅ Migration file structure validated
- ✅ Function consistency verified

---

## 📋 Running the Migration

### 1. **Backup Database** (Recommended)
```bash
# Create a backup before running migration
pg_dump $DATABASE_URL > backup_before_timezone_migration.sql
```

### 2. **Run Migration**
```bash
# Apply the migration
alembic upgrade head
```

### 3. **Verify Migration**
```sql
-- Check column type
\d player_availability

-- Verify constraint exists
SELECT conname, pg_get_constraintdef(oid) 
FROM pg_constraint 
WHERE conrelid = 'player_availability'::regclass;

-- Test date storage
SELECT match_date, 
       date_part('hour', match_date AT TIME ZONE 'UTC') as hour_utc,
       date_part('minute', match_date AT TIME ZONE 'UTC') as minute_utc
FROM player_availability 
LIMIT 5;
```

### 4. **Rollback (if needed)**
```bash
# Rollback to previous version
alembic downgrade -1
```

---

## 🎯 Benefits After Migration

### 1. **Eliminates Off-by-One-Day Bugs**
- Dates stored consistently as midnight UTC
- No more timezone conversion issues
- UI and database always in sync

### 2. **Simplified Code**
- Removed complex timezone handling logic
- Cleaner, more maintainable queries
- Consistent date operations across the app

### 3. **Better Performance**
- Simplified queries run faster
- Optimized index for date-based operations
- Reduced computational overhead

### 4. **Railway Compatibility**
- Works seamlessly with Railway's UTC timezone
- No more Railway UI date editing issues
- Consistent behavior across environments

---

## 🔍 Monitoring

### After Migration, Monitor:

1. **Date Accuracy**: Verify dates display correctly in UI
2. **Availability Updates**: Test setting availability for future dates
3. **Query Performance**: Monitor date-based query performance
4. **Error Logs**: Watch for any timezone-related errors

### Key Queries to Test:
```python
# Test availability setting
update_player_availability("John Doe", "2025-06-01", 1, "Series A")

# Test availability retrieval  
get_player_availability("John Doe", "2025-06-01", "Series A")

# Test date range queries
# Should work consistently across timezones
```

---

## 🚨 Troubleshooting

### If Dates Still Appear Wrong:

1. **Check Browser Timezone**: Ensure frontend handles UTC dates correctly
2. **Verify Migration Applied**: Check database schema with `\d player_availability`
3. **Clear Cache**: Restart application to ensure new code is loaded
4. **Check Constraint**: Verify midnight UTC constraint exists

### Common Issues:

- **Old cached queries**: Restart application
- **Frontend timezone handling**: Update JavaScript date parsing
- **Mixed date formats**: Ensure all inputs use consistent format

---

## 📚 Technical Details

### Database Schema After Migration:
```sql
CREATE TABLE player_availability (
    id SERIAL PRIMARY KEY,
    player_name VARCHAR(255) NOT NULL,
    match_date TIMESTAMPTZ NOT NULL,  -- Changed from DATE
    availability_status INTEGER NOT NULL DEFAULT 3,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,  -- Changed from TIMESTAMP
    series_id INTEGER NOT NULL REFERENCES series(id),
    
    CONSTRAINT match_date_must_be_midnight_utc 
        CHECK (date_part('hour', match_date AT TIME ZONE 'UTC') = 0 AND 
               date_part('minute', match_date AT TIME ZONE 'UTC') = 0 AND 
               date_part('second', match_date AT TIME ZONE 'UTC') = 0)
);
```

### Date Storage Standard:
- **Format**: `2025-06-01 00:00:00+00:00` (midnight UTC)
- **Constraint**: Enforces midnight time component
- **Queries**: Use `DATE(match_date)` for date comparisons

---

## ✅ Migration Checklist

- [ ] Database backup created
- [ ] Migration file reviewed and tested
- [ ] Test script passes all checks
- [ ] Migration applied with `alembic upgrade head`
- [ ] Database schema verified
- [ ] Application restarted
- [ ] Date functionality tested in UI
- [ ] Availability setting/getting tested
- [ ] No timezone-related errors in logs
- [ ] Performance monitoring in place

---

**Migration Created**: 2025-05-29  
**Migration ID**: `1c2bac3892b6`  
**Status**: Ready for deployment 
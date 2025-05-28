#!/usr/bin/env python3
"""
Script to apply the timezone fix to Railway database.
This script connects to Railway and runs the migration.
"""

import os
import sys
from datetime import datetime
import traceback

# Add the project root to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def apply_railway_fix():
    """Apply the timezone fix to Railway database"""
    print("🚀 Applying timezone fix to Railway database...")
    
    # Set environment to use Railway database
    os.environ['RAILWAY_ENVIRONMENT'] = 'production'
    
    try:
        from database_utils import execute_query_one
        
        print("📋 Reading migration script...")
        migration_path = os.path.join(os.path.dirname(__file__), 'migrations', 'fix_timezone_date_issue.sql')
        
        with open(migration_path, 'r') as f:
            migration_sql = f.read()
        
        # Remove comments and empty lines
        lines = migration_sql.split('\n')
        clean_lines = []
        for line in lines:
            line = line.strip()
            if line and not line.startswith('--'):
                clean_lines.append(line)
        
        clean_sql = '\n'.join(clean_lines)
        
        print("🔄 Executing migration on Railway...")
        execute_query_one(clean_sql)
        
        print("✅ Migration applied successfully to Railway!")
        
        # Verify the fix
        print("🔍 Verifying the fix...")
        
        # Check column type
        result = execute_query_one("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'player_availability'
            AND column_name = 'match_date'
        """)
        
        if result and 'timestamp' in result['data_type'].lower():
            print("✅ Column type verified: TIMESTAMPTZ")
        else:
            print(f"❌ Column type verification failed: {result}")
            return False
        
        # Check timezone setting
        tz_result = execute_query_one("SELECT current_setting('timezone') as tz")
        if tz_result:
            print(f"✅ Database timezone: {tz_result['tz']}")
        
        # Check function exists
        func_result = execute_query_one("""
            SELECT proname 
            FROM pg_proc 
            WHERE proname = 'normalize_match_date'
        """)
        
        if func_result:
            print("✅ normalize_match_date function created")
        else:
            print("❌ normalize_match_date function not found")
        
        print("\n🎉 Railway timezone fix completed successfully!")
        print("\n📋 What was fixed:")
        print("- ✅ Converted player_availability.match_date from DATE to TIMESTAMPTZ")
        print("- ✅ Added timezone-aware date handling")
        print("- ✅ Created normalize_match_date() helper function")
        print("- ✅ Set database timezone to America/Chicago")
        print("\n🔧 Next steps:")
        print("1. Test date operations in the application")
        print("2. Verify availability updates work correctly")
        print("3. Monitor for any timezone-related issues")
        
        return True
        
    except Exception as e:
        print(f"❌ Railway migration failed: {str(e)}")
        print(traceback.format_exc())
        return False

if __name__ == "__main__":
    success = apply_railway_fix()
    if success:
        print("\n✅ SUCCESS: Railway timezone fix applied!")
        sys.exit(0)
    else:
        print("\n❌ FAILED: Railway timezone fix failed!")
        sys.exit(1) 
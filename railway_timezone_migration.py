#!/usr/bin/env python3
"""
Railway-specific timezone migration script
Safely applies the timezone migration to Railway PostgreSQL
"""

import os
import sys
import traceback
from datetime import datetime

# Add current directory to path for imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def check_railway_environment():
    """Verify we're running in Railway environment"""
    railway_env = os.getenv('RAILWAY_ENVIRONMENT')
    database_url = os.getenv('DATABASE_URL')
    
    print(f"🌐 Railway Environment: {railway_env}")
    print(f"🗄️  Database URL: {'✅ Set' if database_url else '❌ Not set'}")
    
    if not database_url:
        print("❌ DATABASE_URL not found. This script must run on Railway.")
        return False
    
    return True

def backup_railway_database():
    """Create a backup of the Railway database before migration"""
    print("\n📦 Creating Railway database backup...")
    
    try:
        # Use Railway's DATABASE_URL to create backup
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = f"railway_backup_before_timezone_migration_{timestamp}.sql"
        
        os.system(f"pg_dump $DATABASE_URL > {backup_file}")
        
        # Check if backup was created
        if os.path.exists(backup_file) and os.path.getsize(backup_file) > 0:
            print(f"✅ Backup created: {backup_file}")
            print(f"📊 Backup size: {os.path.getsize(backup_file)} bytes")
            return backup_file
        else:
            print(f"❌ Backup failed or is empty")
            return None
            
    except Exception as e:
        print(f"❌ Backup error: {str(e)}")
        return None

def check_migration_status():
    """Check current Alembic migration status"""
    print("\n🔍 Checking current migration status...")
    
    try:
        from database_utils import execute_query_one
        
        # Check current Alembic version
        result = execute_query_one("SELECT version_num FROM alembic_version")
        if result:
            current_version = result['version_num']
            print(f"📋 Current migration: {current_version}")
            
            if current_version == '1c2bac3892b6':
                print("✅ Timezone migration already applied!")
                return 'already_applied'
            elif current_version == 'c30453403ba8':
                print("📝 Ready to apply timezone migration")
                return 'ready'
            else:
                print(f"⚠️  Unexpected migration version: {current_version}")
                return 'unknown'
        else:
            print("❌ Could not determine migration status")
            return 'error'
            
    except Exception as e:
        print(f"❌ Migration status check failed: {str(e)}")
        return 'error'

def verify_current_schema():
    """Verify current database schema before migration"""
    print("\n🔍 Verifying current database schema...")
    
    try:
        from database_utils import execute_query_one
        
        # Check match_date column type
        result = execute_query_one("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'player_availability'
            AND column_name = 'match_date'
        """)
        
        if result:
            print(f"📊 match_date column: {result['data_type']}")
            
            if result['data_type'] == 'date':
                print("✅ Column is DATE type (ready for migration)")
                return True
            elif 'timestamp' in result['data_type'].lower():
                print("⚠️  Column is already TIMESTAMPTZ (migration may be applied)")
                return True
            else:
                print(f"❌ Unexpected column type: {result['data_type']}")
                return False
        else:
            print("❌ Could not find match_date column")
            return False
            
    except Exception as e:
        print(f"❌ Schema verification failed: {str(e)}")
        return False

def apply_timezone_migration():
    """Apply the timezone migration using Alembic"""
    print("\n🚀 Applying timezone migration...")
    
    try:
        import subprocess
        
        # Run Alembic upgrade
        result = subprocess.run(['alembic', 'upgrade', 'head'], 
                               capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Alembic migration completed successfully!")
            print(f"📋 Output: {result.stdout}")
            return True
        else:
            print(f"❌ Alembic migration failed!")
            print(f"📋 Error: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Migration application failed: {str(e)}")
        return False

def verify_migration_success():
    """Verify that the migration was applied successfully"""
    print("\n✅ Verifying migration success...")
    
    try:
        from database_utils import execute_query_one
        
        # Check updated column type
        result = execute_query_one("""
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_name = 'player_availability'
            AND column_name = 'match_date'
        """)
        
        if result and 'timestamp' in result['data_type'].lower():
            print(f"✅ match_date is now: {result['data_type']}")
        else:
            print(f"❌ Column type verification failed: {result}")
            return False
        
        # Check constraint exists
        constraint_result = execute_query_one("""
            SELECT conname 
            FROM pg_constraint 
            WHERE conrelid = 'player_availability'::regclass
            AND conname = 'match_date_must_be_midnight_utc'
        """)
        
        if constraint_result:
            print("✅ Midnight UTC constraint exists")
        else:
            print("❌ Midnight UTC constraint not found")
            return False
        
        # Test a sample query
        sample_result = execute_query_one("""
            SELECT match_date, 
                   date_part('hour', match_date AT TIME ZONE 'UTC') as hour_utc
            FROM player_availability 
            LIMIT 1
        """)
        
        if sample_result:
            print(f"✅ Sample data: {sample_result['match_date']} (UTC hour: {sample_result['hour_utc']})")
            if sample_result['hour_utc'] == 0:
                print("✅ Data is properly stored as midnight UTC")
            else:
                print("⚠️  Data may need UTC conversion")
        
        return True
        
    except Exception as e:
        print(f"❌ Verification failed: {str(e)}")
        return False

def test_application_functions():
    """Test that application functions work correctly after migration"""
    print("\n🧪 Testing application functions...")
    
    try:
        from routes.act.availability import update_player_availability, get_player_availability
        
        test_player = "Railway Test User"
        test_date = "2025-06-01"
        test_series = "Series 2B"
        test_status = 1
        
        print(f"🧪 Testing availability update for {test_player} on {test_date}")
        
        # Test update
        success = update_player_availability(test_player, test_date, test_status, test_series)
        if success:
            print("✅ Availability update successful")
        else:
            print("❌ Availability update failed")
            return False
        
        # Test retrieval
        status = get_player_availability(test_player, test_date, test_series)
        if status == test_status:
            print(f"✅ Availability retrieval successful: {status}")
        else:
            print(f"❌ Availability retrieval failed: got {status}, expected {test_status}")
            return False
        
        # Cleanup test data
        from database_utils import execute_query_one
        execute_query_one(
            "DELETE FROM player_availability WHERE player_name = %(name)s",
            {'name': test_player}
        )
        print("✅ Test cleanup completed")
        
        return True
        
    except Exception as e:
        print(f"❌ Application function test failed: {str(e)}")
        print(traceback.format_exc())
        return False

def main():
    """Main migration function"""
    print("🚀 Railway Timezone Migration Script")
    print("=" * 50)
    
    # Step 1: Verify Railway environment
    if not check_railway_environment():
        return False
    
    # Step 2: Check current migration status
    migration_status = check_migration_status()
    if migration_status == 'already_applied':
        print("\n✅ Migration already applied. Proceeding to verification...")
    elif migration_status == 'ready':
        print("\n📝 Migration ready to apply.")
    else:
        print("\n❌ Cannot proceed with migration.")
        return False
    
    # Step 3: Verify current schema
    if not verify_current_schema():
        print("\n❌ Schema verification failed.")
        return False
    
    # Step 4: Create backup (only if not already applied)
    if migration_status == 'ready':
        backup_file = backup_railway_database()
        if not backup_file:
            print("\n❌ Backup failed. Migration aborted for safety.")
            return False
    
    # Step 5: Apply migration (only if not already applied)
    if migration_status == 'ready':
        if not apply_timezone_migration():
            print("\n❌ Migration failed.")
            return False
    
    # Step 6: Verify migration success
    if not verify_migration_success():
        print("\n❌ Migration verification failed.")
        return False
    
    # Step 7: Test application functions
    if not test_application_functions():
        print("\n❌ Application function tests failed.")
        return False
    
    print("\n🎉 Railway timezone migration completed successfully!")
    print("\n📋 Summary:")
    print("- ✅ Database schema updated to TIMESTAMPTZ")
    print("- ✅ Midnight UTC constraint applied")
    print("- ✅ Application functions working correctly")
    print("- ✅ Data integrity verified")
    
    return True

if __name__ == "__main__":
    success = main()
    if not success:
        print("\n❌ Migration failed. Check logs and consider rollback if needed.")
        sys.exit(1)
    else:
        print("\n✅ Migration completed successfully!")
        sys.exit(0) 
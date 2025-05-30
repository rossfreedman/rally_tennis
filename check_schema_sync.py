#!/usr/bin/env python3
"""
Check database schema sync between local and Railway
Specifically focuses on users table password columns
"""

import os
import sys
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
from urllib.parse import urlparse

load_dotenv()

def get_table_schema(cursor, table_name):
    """Get detailed schema for a table"""
    cursor.execute("""
        SELECT 
            column_name,
            data_type,
            is_nullable,
            column_default,
            character_maximum_length
        FROM information_schema.columns 
        WHERE table_name = %s AND table_schema = 'public'
        ORDER BY ordinal_position;
    """, (table_name,))
    return cursor.fetchall()

def connect_to_database(db_type="local"):
    """Connect to database based on type"""
    if db_type == "local":
        # Connect to local database
        url = "postgresql://localhost:5432/rally_tennis"
    else:
        # Connect to Railway database - force Railway environment
        os.environ['RAILWAY_ENVIRONMENT'] = 'production'
        url = os.getenv('DATABASE_URL')
        if not url:
            print("❌ DATABASE_URL not found for Railway connection")
            return None
        
        # Ensure we're not connecting to localhost for Railway
        if 'localhost' in url:
            print("❌ WARNING: DATABASE_URL points to localhost, not Railway!")
            # Try to use DATABASE_PUBLIC_URL instead
            url = os.getenv('DATABASE_PUBLIC_URL')
            if not url:
                print("❌ Neither DATABASE_URL nor DATABASE_PUBLIC_URL found for Railway")
                return None
    
    # Handle Railway's postgres:// URLs
    if url.startswith('postgres://'):
        url = url.replace('postgres://', 'postgresql://', 1)
    
    try:
        # Parse URL
        parsed = urlparse(url)
        hostname = parsed.hostname or ''
        sslmode = 'require' if ('railway.app' in hostname or 'rlwy.net' in hostname or 'railway.internal' in hostname) else 'prefer'
        
        conn = psycopg2.connect(url, sslmode=sslmode, connect_timeout=30)
        print(f"✅ Connected to {db_type} database: {hostname}")
        return conn
    except Exception as e:
        print(f"❌ Failed to connect to {db_type} database: {str(e)}")
        return None

def compare_schemas():
    """Compare schemas between local and Railway"""
    print("=== Database Schema Comparison ===\n")
    
    # Connect to both databases
    local_conn = connect_to_database("local")
    railway_conn = connect_to_database("railway")
    
    if not local_conn or not railway_conn:
        print("❌ Could not connect to both databases")
        return False
    
    try:
        local_cursor = local_conn.cursor(cursor_factory=RealDictCursor)
        railway_cursor = railway_conn.cursor(cursor_factory=RealDictCursor)
        
        # Check users table schema specifically
        print("📋 Comparing 'users' table schema:\n")
        
        local_schema = get_table_schema(local_cursor, 'users')
        railway_schema = get_table_schema(railway_cursor, 'users')
        
        print("LOCAL DATABASE - users table:")
        for col in local_schema:
            nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
            print(f"  {col['column_name']}: {col['data_type']} {nullable}")
        
        print("\nRAILWAY DATABASE - users table:")
        for col in railway_schema:
            nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
            print(f"  {col['column_name']}: {col['data_type']} {nullable}")
        
        # Compare password-related columns specifically
        print("\n🔐 PASSWORD COLUMN ANALYSIS:")
        
        local_password_cols = [col for col in local_schema if 'password' in col['column_name'].lower()]
        railway_password_cols = [col for col in railway_schema if 'password' in col['column_name'].lower()]
        
        print(f"\nLocal password columns: {len(local_password_cols)}")
        for col in local_password_cols:
            nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
            print(f"  - {col['column_name']}: {col['data_type']} {nullable}")
        
        print(f"\nRailway password columns: {len(railway_password_cols)}")
        for col in railway_password_cols:
            nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
            print(f"  - {col['column_name']}: {col['data_type']} {nullable}")
        
        # Identify schema differences
        local_cols = {col['column_name']: col for col in local_schema}
        railway_cols = {col['column_name']: col for col in railway_schema}
        
        print(f"\n🔍 SCHEMA DIFFERENCES:")
        
        only_local = set(local_cols.keys()) - set(railway_cols.keys())
        only_railway = set(railway_cols.keys()) - set(local_cols.keys())
        
        if only_local:
            print(f"\nColumns only in LOCAL:")
            for col_name in only_local:
                col = local_cols[col_name]
                nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
                print(f"  - {col_name}: {col['data_type']} {nullable}")
        
        if only_railway:
            print(f"\nColumns only in RAILWAY:")
            for col_name in only_railway:
                col = railway_cols[col_name]
                nullable = "NULL" if col['is_nullable'] == 'YES' else "NOT NULL"
                print(f"  - {col_name}: {col['data_type']} {nullable}")
        
        # Check for differences in common columns
        common_cols = set(local_cols.keys()) & set(railway_cols.keys())
        differences = []
        
        for col_name in common_cols:
            local_col = local_cols[col_name]
            railway_col = railway_cols[col_name]
            
            if (local_col['data_type'] != railway_col['data_type'] or 
                local_col['is_nullable'] != railway_col['is_nullable']):
                differences.append({
                    'column': col_name,
                    'local': f"{local_col['data_type']} {'NULL' if local_col['is_nullable'] == 'YES' else 'NOT NULL'}",
                    'railway': f"{railway_col['data_type']} {'NULL' if railway_col['is_nullable'] == 'YES' else 'NOT NULL'}"
                })
        
        if differences:
            print(f"\nDifferences in common columns:")
            for diff in differences:
                print(f"  - {diff['column']}:")
                print(f"    Local:   {diff['local']}")
                print(f"    Railway: {diff['railway']}")
        
        # Conclusion
        if only_local or only_railway or differences:
            print(f"\n❌ DATABASES ARE NOT IN SYNC")
            print(f"   - Columns only in local: {len(only_local)}")
            print(f"   - Columns only in Railway: {len(only_railway)}")
            print(f"   - Different column definitions: {len(differences)}")
            return False
        else:
            print(f"\n✅ DATABASES ARE IN SYNC")
            return True
            
    finally:
        local_conn.close()
        railway_conn.close()

if __name__ == "__main__":
    success = compare_schemas()
    if not success:
        print(f"\n🔧 NEXT STEPS:")
        print(f"1. Run database migrations on both environments")
        print(f"2. Consider running schema sync script")
        print(f"3. Verify fix_password_column.py runs against Railway")
        sys.exit(1)
    else:
        print(f"\n🎉 Schema comparison completed successfully!")
        sys.exit(0) 
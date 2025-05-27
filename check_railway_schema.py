#!/usr/bin/env python3

import psycopg2
from psycopg2.extras import RealDictCursor

def check_railway_schema():
    """Check the actual schema of the Railway database"""
    
    # Use the Railway DATABASE_PUBLIC_URL directly
    database_url = "postgresql://postgres:ihxpdgQMcXGoMCNvYqzWWmidKTnkdsoM@metro.proxy.rlwy.net:19439/railway"
    
    print(f"Checking Railway database schema...")
    
    try:
        conn = psycopg2.connect(database_url, sslmode='require', connect_timeout=30)
        print("✅ Connected to Railway database successfully!")
        
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            # Check users table columns
            cursor.execute('''
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'users' 
                ORDER BY ordinal_position
            ''')
            
            columns = cursor.fetchall()
            
            print("\n=== USERS TABLE COLUMNS ===")
            for col in columns:
                print(f"  {col['column_name']}: {col['data_type']} (nullable: {col['is_nullable']})")
            
            # Check if club_automation_password column exists
            has_club_automation_password = any(col['column_name'] == 'club_automation_password' for col in columns)
            print(f"\nclub_automation_password column exists: {has_club_automation_password}")
            
            # Check sample user data
            print("\n=== SAMPLE USER DATA ===")
            cursor.execute('SELECT * FROM users WHERE email = %s', ('rossfreedman@gmail.com',))
            user = cursor.fetchone()
            
            if user:
                print("Ross Freedman user data:")
                for key, value in user.items():
                    print(f"  {key}: {value}")
            else:
                print("Ross Freedman user not found")
        
        conn.close()
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    check_railway_schema() 
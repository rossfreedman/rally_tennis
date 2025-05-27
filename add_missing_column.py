#!/usr/bin/env python3

import psycopg2
from psycopg2.extras import RealDictCursor

def add_missing_column():
    """Add the missing club_automation_password column to Railway database"""
    
    # Use the Railway DATABASE_PUBLIC_URL directly
    database_url = "postgresql://postgres:ihxpdgQMcXGoMCNvYqzWWmidKTnkdsoM@metro.proxy.rlwy.net:19439/railway"
    
    print(f"Adding missing club_automation_password column to Railway database...")
    
    try:
        conn = psycopg2.connect(database_url, sslmode='require', connect_timeout=30)
        print("✅ Connected to Railway database successfully!")
        
        with conn.cursor() as cursor:
            # Add the missing column
            print("Adding club_automation_password column...")
            cursor.execute('''
                ALTER TABLE users 
                ADD COLUMN IF NOT EXISTS club_automation_password VARCHAR(255) DEFAULT ''
            ''')
            
            conn.commit()
            print("✅ Column added successfully!")
            
            # Verify the column was added
            cursor.execute('''
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'users' AND column_name = 'club_automation_password'
            ''')
            
            result = cursor.fetchone()
            if result:
                print(f"✅ Verified: club_automation_password column exists: {result}")
            else:
                print("❌ Column was not added successfully")
            
            # Test the settings query now
            print("\n=== Testing settings query ===")
            cursor.execute('''
                SELECT u.first_name, u.last_name, u.email, u.club_automation_password,
                       c.name as club, s.name as series
                FROM users u
                LEFT JOIN clubs c ON u.club_id = c.id
                LEFT JOIN series s ON u.series_id = s.id
                WHERE u.email = %s
            ''', ('rossfreedman@gmail.com',))
            
            user_data = cursor.fetchone()
            
            if user_data:
                print("✅ Settings query now works!")
                print(f"User data: {user_data}")
            else:
                print("❌ Settings query still failing")
        
        conn.close()
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    add_missing_column() 
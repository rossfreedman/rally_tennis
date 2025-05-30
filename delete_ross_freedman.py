#!/usr/bin/env python3
"""
Script to delete 'ross freedman' from the local database.
This script will:
1. Search for users with the name 'ross freedman' 
2. Display the matching records for confirmation
3. Delete the user record(s) if found
"""

import sys
from database_config import get_db
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def search_ross_freedman():
    """Search for users named 'ross freedman' or similar variations"""
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                # Search for ross freedman with case-insensitive matching
                search_queries = [
                    # Exact match (case insensitive)
                    "SELECT * FROM users WHERE LOWER(first_name) = 'ross' AND LOWER(last_name) = 'freedman'",
                    # Fuzzy match for similar names
                    "SELECT * FROM users WHERE LOWER(first_name) LIKE '%ross%' AND LOWER(last_name) LIKE '%freed%'",
                    # Email-based search in case the name is in the email
                    "SELECT * FROM users WHERE LOWER(email) LIKE '%ross%' OR LOWER(email) LIKE '%freedman%'"
                ]
                
                all_matches = []
                
                for i, query in enumerate(search_queries):
                    cursor.execute(query)
                    results = cursor.fetchall()
                    
                    if results:
                        logger.info(f"Search query {i+1} found {len(results)} match(es):")
                        for row in results:
                            user_data = {
                                'id': row[0],
                                'email': row[1],
                                'first_name': row[3],
                                'last_name': row[4],
                                'club_id': row[5],
                                'series_id': row[6],
                                'is_admin': row[7],
                                'created_at': row[8]
                            }
                            all_matches.append(user_data)
                            logger.info(f"  ID: {user_data['id']}, Email: {user_data['email']}, "
                                      f"Name: {user_data['first_name']} {user_data['last_name']}, "
                                      f"Admin: {user_data['is_admin']}")
                
                return all_matches
                
    except Exception as e:
        logger.error(f"Error searching for ross freedman: {str(e)}")
        return []

def delete_user_by_id(user_id):
    """Delete a user by their ID"""
    try:
        with get_db() as conn:
            with conn.cursor() as cursor:
                # First, get the user details for confirmation
                cursor.execute("SELECT email, first_name, last_name FROM users WHERE id = %s", (user_id,))
                user = cursor.fetchone()
                
                if not user:
                    logger.warning(f"No user found with ID {user_id}")
                    return False
                
                email, first_name, last_name = user
                logger.info(f"Found user to delete: {first_name} {last_name} ({email})")
                
                # Delete related records first (foreign key constraints)
                logger.info("Deleting related user instructions...")
                cursor.execute("DELETE FROM user_instructions WHERE user_email = %s", (email,))
                instructions_deleted = cursor.rowcount
                
                logger.info("Deleting related activity logs...")
                cursor.execute("DELETE FROM user_activity_logs WHERE user_email = %s", (email,))
                logs_deleted = cursor.rowcount
                
                # Delete the user record
                logger.info("Deleting user record...")
                cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))
                user_deleted = cursor.rowcount
                
                if user_deleted > 0:
                    conn.commit()
                    logger.info(f"Successfully deleted user '{first_name} {last_name}' (ID: {user_id})")
                    logger.info(f"Also deleted: {instructions_deleted} instructions, {logs_deleted} activity logs")
                    return True
                else:
                    logger.warning("User deletion failed - no rows affected")
                    conn.rollback()
                    return False
                    
    except Exception as e:
        logger.error(f"Error deleting user {user_id}: {str(e)}")
        if 'conn' in locals():
            conn.rollback()
        return False

def main():
    """Main function to search for and delete ross freedman"""
    logger.info("Searching for 'ross freedman' in the database...")
    
    # Search for the user
    matches = search_ross_freedman()
    
    if not matches:
        logger.info("No users found matching 'ross freedman'")
        return
    
    # Display matches and ask for confirmation
    logger.info(f"\nFound {len(matches)} matching user(s):")
    for i, user in enumerate(matches, 1):
        logger.info(f"{i}. ID: {user['id']}, Email: {user['email']}, "
                   f"Name: {user['first_name']} {user['last_name']}")
    
    # For safety, let's be explicit about which users to delete
    ross_freedman_users = []
    for user in matches:
        if (user['first_name'].lower() == 'ross' and 
            user['last_name'].lower() == 'freedman'):
            ross_freedman_users.append(user)
    
    if not ross_freedman_users:
        logger.warning("No exact matches for 'ross freedman' found among the results")
        return
    
    # Delete the exact matches
    logger.info(f"\nDeleting {len(ross_freedman_users)} exact match(es) for 'ross freedman':")
    for user in ross_freedman_users:
        success = delete_user_by_id(user['id'])
        if success:
            logger.info(f"✓ Deleted user: {user['first_name']} {user['last_name']} ({user['email']})")
        else:
            logger.error(f"✗ Failed to delete user: {user['first_name']} {user['last_name']} ({user['email']})")

if __name__ == "__main__":
    main() 
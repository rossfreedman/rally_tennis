#!/usr/bin/env python3

from database_utils import execute_query_one, execute_query
import os

def main():
    # Check your user record
    user = execute_query_one('''
        SELECT u.id, u.email, u.first_name, u.last_name, u.club_id, u.series_id,
               c.name as club_name, s.name as series_name
        FROM users u
        JOIN clubs c ON u.club_id = c.id
        JOIN series s ON u.series_id = s.id
        WHERE LOWER(u.email) = LOWER(%s)
    ''', ('rossfreedman@gmail.com',))

    print('=== YOUR USER RECORD ===')
    if user:
        for key, value in user.items():
            print(f'{key}: {value}')
    else:
        print('User not found!')

    print('\n=== ALL CLUBS ===')
    clubs = execute_query('SELECT id, name FROM clubs ORDER BY name')
    for club in clubs:
        print(f'ID {club["id"]}: {club["name"]}')

    print('\n=== ALL SERIES ===')
    series = execute_query('SELECT id, name FROM series ORDER BY name')
    for s in series:
        print(f'ID {s["id"]}: {s["name"]}')

    # Check what should be the correct IDs
    print('\n=== CORRECT VALUES FOR SERIES 2B TENNAQUA ===')
    correct_club = execute_query_one('SELECT id, name FROM clubs WHERE name = %s', ('Tennaqua',))
    correct_series = execute_query_one('SELECT id, name FROM series WHERE name = %s', ('tennaqua series 2B',))
    
    if correct_club:
        print(f'Correct club ID: {correct_club["id"]} ({correct_club["name"]})')
    else:
        print('Tennaqua club not found!')
        
    if correct_series:
        print(f'Correct series ID: {correct_series["id"]} ({correct_series["name"]})')
    else:
        print('tennaqua series 2B not found!')

if __name__ == '__main__':
    main() 
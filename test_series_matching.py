#!/usr/bin/env python3

import re

# Test the current logic
user_series = 'tennaqua series 2B'
player_series_2a = 'Series 2A'
player_series_2b = 'Series 2B'

print('Testing current regex logic:')
print(f'User series: {user_series}')
print(f'Player series 2A: {player_series_2a}')
print(f'Player series 2B: {player_series_2b}')

# Current logic from server.py
player_series_match_2a = re.search(r'Series\s+(\w+)', player_series_2a)
player_series_match_2b = re.search(r'Series\s+(\w+)', player_series_2b)
user_series_match = re.search(r'(\w+)$', user_series)

if player_series_match_2a and user_series_match:
    player_series_id_2a = player_series_match_2a.group(1)
    user_series_id = user_series_match.group(1)
    print(f'Player 2A series ID: {player_series_id_2a}')
    print(f'User series ID: {user_series_id}')
    print(f'2A matches user? {player_series_id_2a.lower() == user_series_id.lower()}')

if player_series_match_2b and user_series_match:
    player_series_id_2b = player_series_match_2b.group(1)
    user_series_id = user_series_match.group(1)
    print(f'Player 2B series ID: {player_series_id_2b}')
    print(f'User series ID: {user_series_id}')
    print(f'2B matches user? {player_series_id_2b.lower() == user_series_id.lower()}')

print('\n--- Testing with utils.series_matcher ---')
from utils.series_matcher import series_match

print(f'series_match("{player_series_2a}", "{user_series}"): {series_match(player_series_2a, user_series)}')
print(f'series_match("{player_series_2b}", "{user_series}"): {series_match(player_series_2b, user_series)}') 
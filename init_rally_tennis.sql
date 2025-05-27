-- Rally Tennis Database Initialization Script
-- This script creates all necessary tables for the Rally Tennis application

-- Create clubs table
CREATE TABLE IF NOT EXISTS clubs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

-- Create series table
CREATE TABLE IF NOT EXISTS series (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    club_id INTEGER REFERENCES clubs(id),
    series_id INTEGER REFERENCES series(id),
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create user_instructions table
CREATE TABLE IF NOT EXISTS user_instructions (
    id SERIAL PRIMARY KEY,
    user_email VARCHAR(255) NOT NULL,
    instruction TEXT NOT NULL,
    team_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create player_availability table
CREATE TABLE IF NOT EXISTS player_availability (
    id SERIAL PRIMARY KEY,
    player_name VARCHAR(255) NOT NULL,
    match_date DATE NOT NULL,
    availability_status INTEGER NOT NULL DEFAULT 3, -- 1: available, 2: unavailable, 3: not sure
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    series_id INTEGER NOT NULL REFERENCES series(id),
    UNIQUE(player_name, match_date, series_id),
    CONSTRAINT valid_availability_status CHECK (availability_status IN (1, 2, 3))
);

-- Create user_activity_logs table
CREATE TABLE IF NOT EXISTS user_activity_logs (
    id SERIAL PRIMARY KEY,
    user_email VARCHAR(255) NOT NULL,
    activity_type VARCHAR(255) NOT NULL,
    page VARCHAR(255),
    action TEXT,
    details TEXT,
    ip_address VARCHAR(45),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default tennis clubs (Philadelphia area)
INSERT INTO clubs (name) VALUES 
    ('Germantown Cricket Club'),
    ('Philadelphia Cricket Club'),
    ('Merion Cricket Club'),
    ('Waynesborough Country Club'),
    ('Aronimink Golf Club'),
    ('Overbrook Golf Club'),
    ('Radnor Valley Country Club'),
    ('White Manor Country Club')
ON CONFLICT (name) DO NOTHING;

-- Insert default series
INSERT INTO series (name) VALUES 
    ('Series 1'),
    ('Series 2'),
    ('Series 3'),
    ('Series 4'),
    ('Series 5'),
    ('Series 6'),
    ('Series 7'),
    ('Series 8')
ON CONFLICT (name) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_user_instructions_email ON user_instructions(user_email);
CREATE INDEX IF NOT EXISTS idx_player_availability ON player_availability(player_name, match_date, series_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_user_email ON user_activity_logs(user_email, timestamp);

-- Create Alembic version table for migration tracking
CREATE TABLE IF NOT EXISTS alembic_version (
    version_num VARCHAR(32) NOT NULL,
    CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);

-- Insert the current migration version
INSERT INTO alembic_version (version_num) VALUES ('22cdc4d8bba3') ON CONFLICT DO NOTHING;

SELECT 'Rally Tennis database initialized successfully!' as result; 
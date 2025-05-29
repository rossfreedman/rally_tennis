"""fix_timezone_date_issue_convert_date_to_timestamptz

Revision ID: 1c2bac3892b6
Revises: 22cdc4d8bba3
Create Date: 2025-05-29 08:08:44.348159

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import TIMESTAMP


# revision identifiers, used by Alembic.
revision: str = '1c2bac3892b6'
down_revision: Union[str, None] = '22cdc4d8bba3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """
    Convert player_availability.match_date from DATE to TIMESTAMPTZ to fix timezone issues.
    
    This addresses the problem where DATE columns without timezone info cause off-by-one-day
    errors when the app/UI interprets dates in different timezones (UTC vs America/Chicago).
    
    The conversion safely preserves existing data by casting DATE values to midnight UTC timestamps.
    """
    
    # Step 1: Convert the column type from DATE to TIMESTAMPTZ
    # This automatically casts existing date values to midnight UTC timestamps
    op.alter_column(
        'player_availability',
        'match_date',
        existing_type=sa.Date(),
        type_=TIMESTAMP(timezone=True),
        existing_nullable=False,
        postgresql_using='match_date::timestamptz'
    )
    
    # Step 2: Add a check constraint to ensure all dates are stored as midnight UTC
    # This prevents accidental insertion of times other than 00:00:00
    op.create_check_constraint(
        'match_date_must_be_midnight_utc',
        'player_availability',
        "date_part('hour', match_date AT TIME ZONE 'UTC') = 0 AND "
        "date_part('minute', match_date AT TIME ZONE 'UTC') = 0 AND "
        "date_part('second', match_date AT TIME ZONE 'UTC') = 0"
    )
    
    # Step 3: Update the updated_at column to also use TIMESTAMPTZ for consistency
    op.alter_column(
        'player_availability',
        'updated_at',
        existing_type=sa.TIMESTAMP(),
        type_=TIMESTAMP(timezone=True),
        existing_nullable=True,
        existing_server_default=sa.text('CURRENT_TIMESTAMP'),
        server_default=sa.text('CURRENT_TIMESTAMP')
    )
    
    # Step 4: Re-create the unique constraint that may have been affected by Railway migration
    # The Railway migration 22cdc4d8bba3 removed this constraint, so we need to recreate it
    try:
        op.create_unique_constraint(
            'player_availability_player_name_match_date_series_id_key',
            'player_availability',
            ['player_name', 'match_date', 'series_id']
        )
        print("✅ Recreated unique constraint")
    except Exception as e:
        print(f"⚠️  Unique constraint already exists or creation failed: {e}")
        pass
    
    # Step 5: Create an index to optimize date-based queries  
    # The Railway migration also removed the old index, so create a new optimized one
    try:
        op.create_index(
            'idx_player_availability_date_series',
            'player_availability',
            ['match_date', 'series_id'],
            unique=False
        )
        print("✅ Created optimized date index")
    except Exception as e:
        print(f"⚠️  Index already exists or creation failed: {e}")
        pass


def downgrade() -> None:
    """
    Rollback the timezone fix by converting TIMESTAMPTZ back to DATE.
    
    WARNING: This will lose timezone information and may reintroduce the off-by-one-day bug.
    """
    
    # Step 1: Drop the indexes and constraints we created
    op.drop_index('idx_player_availability_date_series', table_name='player_availability')
    op.drop_constraint('match_date_must_be_midnight_utc', 'player_availability', type_='check')
    
    # Step 2: Convert TIMESTAMPTZ back to DATE (loses timezone info)
    op.alter_column(
        'player_availability',
        'match_date',
        existing_type=TIMESTAMP(timezone=True),
        type_=sa.Date(),
        existing_nullable=False,
        postgresql_using='match_date::date'
    )
    
    # Step 3: Revert updated_at column back to TIMESTAMP without timezone
    op.alter_column(
        'player_availability',
        'updated_at',
        existing_type=TIMESTAMP(timezone=True),
        type_=sa.TIMESTAMP(),
        existing_nullable=True,
        existing_server_default=sa.text('CURRENT_TIMESTAMP'),
        server_default=sa.text('CURRENT_TIMESTAMP')
    )

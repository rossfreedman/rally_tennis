"""add_address_to_clubs

Revision ID: c30453403ba8
Revises: 22cdc4d8bba3
Create Date: 2025-05-27 10:46:05.067080

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c30453403ba8'
down_revision: Union[str, None] = '22cdc4d8bba3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Add address column to clubs table
    op.add_column('clubs', sa.Column('address', sa.String(length=500), nullable=True))


def downgrade() -> None:
    """Downgrade schema."""
    # Remove address column from clubs table
    op.drop_column('clubs', 'address')

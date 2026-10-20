"""lepas unique global sisa 001 (per-owner uniqueness, sesuai model)

Constraint global `skills.name` dan `projects.slug` bentrok dengan pola
multitenant (dua user boleh punya nama skill / slug project sama). Migrasi
002 hanya melepas pasangan projects di PostgreSQL; migrasi ini menuntaskan
keduanya untuk database yang sudah menerapkan 002 sebelumnya.

SQLite tidak mendukung ALTER CONSTRAINT via op biasa; model SQLAlchemy sudah
menyimpan constraint per-owner, jadi migrasi ini hanya menarget PostgreSQL
(dialek produksi), pola sama dengan 002.

Revision ID: 003_per_owner_uniques
Revises: 002_multitenant
Create Date: 2026-10-20
"""

from alembic import op
import sqlalchemy as sa

revision = "003_per_owner_uniques"
down_revision = "002_multitenant"
branch_labels = None
depends_on = None


def upgrade() -> None:
  if op.get_bind().dialect.name != "postgresql":
    return
  op.execute("ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_slug_key")
  op.execute("ALTER TABLE skills DROP CONSTRAINT IF EXISTS skills_name_key")
  op.create_unique_constraint(
      "uq_skills_owner_name", "skills", ["owner_id", "name"]
  )


def downgrade() -> None:
  if op.get_bind().dialect.name != "postgresql":
    return
  op.drop_constraint("uq_skills_owner_name", "skills", type_="unique")
  op.create_unique_constraint("skills_name_key", "skills", ["name"])
  op.create_unique_constraint("projects_slug_key", "projects", ["slug"])

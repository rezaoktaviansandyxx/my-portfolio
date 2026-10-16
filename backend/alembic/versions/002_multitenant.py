"""multitenant owner-based

Revision ID: 002_multitenant
Revises: 001_initial_schema
Create Date: 2026-10-16
"""

from alembic import op
import sqlalchemy as sa

revision = "002_multitenant"
down_revision = "001_initial_schema"
branch_labels = None
depends_on = None


def upgrade() -> None:
  op.add_column("users", sa.Column("role", sa.String(10), nullable=False, server_default="user"))
  op.add_column("users", sa.Column("profile_slug", sa.String(60), nullable=True))
  op.add_column("users", sa.Column("is_published", sa.Boolean(), nullable=False, server_default="false"))
  op.create_index("ix_users_profile_slug", "users", ["profile_slug"], unique=True)
  for tbl in ["projects", "skills", "experiences"]:
    op.add_column(tbl, sa.Column("owner_id", sa.Integer(), nullable=True))
  op.add_column("messages", sa.Column("recipient_id", sa.Integer(), nullable=True))
  # backfill ke admin pertama
  conn = op.get_bind()
  admin_id = conn.execute(sa.text("SELECT id FROM users ORDER BY id ASC LIMIT 1")).scalar()
  if admin_id is not None:
    conn.execute(sa.text("UPDATE users SET role='admin', profile_slug='admin', is_published=true WHERE id=:i").bindparams(i=admin_id))
    # spec: user lain tanpa slug dapat slug sementara user-{id}
    conn.execute(sa.text("UPDATE users SET profile_slug='user-' || id WHERE id != :i AND profile_slug IS NULL").bindparams(i=admin_id))
    for tbl in ["projects", "skills", "experiences"]:
      conn.execute(sa.text(f"UPDATE {tbl} SET owner_id=:i WHERE owner_id IS NULL").bindparams(i=admin_id))
    conn.execute(sa.text("UPDATE messages SET recipient_id=:i WHERE recipient_id IS NULL").bindparams(i=admin_id))
  # not-null + index + fk + unique per owner
  for tbl in ["projects", "skills", "experiences"]:
    op.alter_column(tbl, "owner_id", nullable=False)
    op.create_index(f"ix_{tbl}_owner", tbl, ["owner_id"])
    op.create_foreign_key(f"fk_{tbl}_owner", tbl, "users", ["owner_id"], ["id"], ondelete="CASCADE")
  op.alter_column("messages", "recipient_id", nullable=False)
  op.create_index("ix_messages_recipient", "messages", ["recipient_id"])
  op.create_foreign_key("fk_messages_recipient", "messages", "users", ["recipient_id"], ["id"], ondelete="CASCADE")
  # spec: slug unik per owner, bukan global — lepas unique global lama dari 001
  if conn.dialect.name == "postgresql":
    op.execute("ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_slug_key")
  op.create_unique_constraint("uq_project_owner_slug", "projects", ["owner_id", "slug"])


def downgrade() -> None:
  op.drop_constraint("uq_project_owner_slug", "projects", type_="unique")
  op.drop_constraint("fk_messages_recipient", "messages", type_="foreignkey")
  op.drop_index("ix_messages_recipient", "messages")
  op.drop_column("messages", "recipient_id")
  for tbl in ["projects", "skills", "experiences"]:
    op.drop_constraint(f"fk_{tbl}_owner", tbl, type_="foreignkey")
    op.drop_index(f"ix_{tbl}_owner", tbl)
    op.drop_column(tbl, "owner_id")
  op.drop_index("ix_users_profile_slug", "users")
  op.drop_column("users", "is_published")
  op.drop_column("users", "profile_slug")
  op.drop_column("users", "role")

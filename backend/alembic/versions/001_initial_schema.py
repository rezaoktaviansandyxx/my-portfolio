"""initial_schema

Revision ID: 001_initial_schema
Revises:
Create Date: 2026-10-15
"""

from alembic import op
import sqlalchemy as sa

revision = "001_initial_schema"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
  op.create_table(
      "users",
      sa.Column("id", sa.Integer(), primary_key=True),
      sa.Column("username", sa.String(50), nullable=False, unique=True),
      sa.Column("email", sa.String(100), nullable=False, unique=True),
      sa.Column("hashed_password", sa.String(255), nullable=False),
      sa.Column("full_name", sa.String(100), nullable=False),
      sa.Column("headline", sa.String(255), nullable=True),
      sa.Column("bio", sa.Text(), nullable=True),
      sa.Column("avatar_url", sa.String(255), nullable=True),
      sa.Column("resume_url", sa.String(255), nullable=True),
      sa.Column("is_active", sa.Boolean(), default=True),
      sa.Column(
          "created_at",
          sa.DateTime(timezone=True),
          server_default=sa.func.now(),
          nullable=False,
      ),
  )

  op.create_table(
      "skills",
      sa.Column("id", sa.Integer(), primary_key=True),
      sa.Column("name", sa.String(60), nullable=False, unique=True),
      sa.Column("category", sa.String(50), nullable=False, index=True),
      sa.Column("proficiency_level", sa.Integer(), nullable=True),
      sa.Column("icon_url", sa.String(255), nullable=True),
      sa.Column("display_order", sa.Integer(), default=0),
  )

  op.create_table(
      "projects",
      sa.Column("id", sa.Integer(), primary_key=True),
      sa.Column("title", sa.String(150), nullable=False),
      sa.Column("slug", sa.String(160), nullable=False, unique=True),
      sa.Column("summary", sa.Text(), nullable=False),
      sa.Column("problem_statement", sa.Text(), nullable=True),
      sa.Column("solution", sa.Text(), nullable=True),
      sa.Column("key_features", sa.JSON(), default=list),
      sa.Column("cover_image_url", sa.String(255), nullable=True),
      sa.Column("meta_description", sa.String(255), nullable=True),
      sa.Column("live_url", sa.String(255), nullable=True),
      sa.Column("github_url", sa.String(255), nullable=True),
      sa.Column("is_featured", sa.Boolean(), default=False),
      sa.Column("status", sa.String(20), default="published", index=True),
      sa.Column("display_order", sa.Integer(), default=0),
      sa.Column(
          "created_at",
          sa.DateTime(timezone=True),
          server_default=sa.func.now(),
          nullable=False,
      ),
      sa.Column("updated_at", sa.DateTime(timezone=True), nullable=True),
  )

  op.create_table(
      "project_media",
      sa.Column("id", sa.Integer(), primary_key=True),
      sa.Column(
          "project_id",
          sa.Integer(),
          sa.ForeignKey("projects.id", ondelete="CASCADE"),
          nullable=False,
      ),
      sa.Column("media_url", sa.String(255), nullable=False),
      sa.Column("media_type", sa.String(30), default="image"),
      sa.Column("caption", sa.String(255), nullable=True),
      sa.Column("display_order", sa.Integer(), default=0),
      sa.Column(
          "created_at",
          sa.DateTime(timezone=True),
          server_default=sa.func.now(),
          nullable=False,
      ),
  )

  op.create_table(
      "project_skills",
      sa.Column(
          "project_id",
          sa.Integer(),
          sa.ForeignKey("projects.id", ondelete="CASCADE"),
          primary_key=True,
      ),
      sa.Column(
          "skill_id",
          sa.Integer(),
          sa.ForeignKey("skills.id", ondelete="CASCADE"),
          primary_key=True,
      ),
      sa.Column(
          "created_at",
          sa.DateTime(timezone=True),
          server_default=sa.func.now(),
          nullable=False,
      ),
  )

  op.create_table(
      "experiences",
      sa.Column("id", sa.Integer(), primary_key=True),
      sa.Column("role", sa.String(100), nullable=False),
      sa.Column("company", sa.String(100), nullable=False),
      sa.Column("location", sa.String(100), nullable=True),
      sa.Column("employment_type", sa.String(50), default="Full-time"),
      sa.Column("start_date", sa.Date(), nullable=False),
      sa.Column("end_date", sa.Date(), nullable=True),
      sa.Column("is_current", sa.Boolean(), default=False),
      sa.Column("description", sa.Text(), nullable=True),
      sa.Column("technologies_used", sa.JSON(), default=list),
      sa.Column(
          "created_at",
          sa.DateTime(timezone=True),
          server_default=sa.func.now(),
          nullable=False,
      ),
  )

  op.create_table(
      "messages",
      sa.Column("id", sa.Integer(), primary_key=True),
      sa.Column("sender_name", sa.String(100), nullable=False),
      sa.Column("sender_email", sa.String(100), nullable=False),
      sa.Column("subject", sa.String(200), nullable=False),
      sa.Column("content", sa.Text(), nullable=False),
      sa.Column("is_read", sa.Boolean(), default=False, index=True),
      sa.Column("ip_address", sa.String(45), nullable=True),
      sa.Column(
          "created_at",
          sa.DateTime(timezone=True),
          server_default=sa.func.now(),
          nullable=False,
      ),
  )


def downgrade() -> None:
  op.drop_table("messages")
  op.drop_table("experiences")
  op.drop_table("project_skills")
  op.drop_table("project_media")
  op.drop_table("projects")
  op.drop_table("skills")
  op.drop_table("users")
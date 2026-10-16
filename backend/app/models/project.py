from app.core.database import Base
from sqlalchemy import JSON, Boolean, Column, DateTime, ForeignKey, Integer, String, Table, Text, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

# Junction table Many-to-Many antara Project dan Skill
project_skills = Table(
    "project_skills",
    Base.metadata,
    Column(
        "project_id",
        Integer,
        ForeignKey("projects.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "skill_id",
        Integer,
        ForeignKey("skills.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "created_at",
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    ),
)


class Project(Base):
  __tablename__ = "projects"
  __table_args__ = (UniqueConstraint("owner_id", "slug", name="uq_project_owner_slug"),)

  id = Column(Integer, primary_key=True, index=True)
  owner_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
  title = Column(String(150), nullable=False)
  slug = Column(String(160), index=True, nullable=False)
  summary = Column(Text, nullable=False)
  problem_statement = Column(Text, nullable=True)
  solution = Column(Text, nullable=True)
  key_features = Column(JSON, default=list)
  cover_image_url = Column(String(255), nullable=True)
  meta_description = Column(String(255), nullable=True)
  live_url = Column(String(255), nullable=True)
  github_url = Column(String(255), nullable=True)
  is_featured = Column(Boolean, default=False)
  status = Column(String(20), default="published", index=True)  # draft/published
  display_order = Column(Integer, default=0)
  created_at = Column(
      DateTime(timezone=True), server_default=func.now(), nullable=False
  )
  updated_at = Column(
      DateTime(timezone=True), onupdate=func.now(), nullable=True
  )

  media = relationship(
      "ProjectMedia",
      back_populates="project",
      cascade="all, delete-orphan",
      order_by="ProjectMedia.display_order",
  )
  skills = relationship(
      "Skill", secondary=project_skills, back_populates="projects"
  )
  owner = relationship("User")


class ProjectMedia(Base):
  __tablename__ = "project_media"

  id = Column(Integer, primary_key=True, index=True)
  project_id = Column(
      Integer,
      ForeignKey("projects.id", ondelete="CASCADE"),
      nullable=False,
      index=True,
  )
  media_url = Column(String(255), nullable=False)
  media_type = Column(
      String(30), default="image"
  )  # image, diagram, video_demo
  caption = Column(String(255), nullable=True)
  display_order = Column(Integer, default=0)
  created_at = Column(
      DateTime(timezone=True), server_default=func.now(), nullable=False
  )

  project = relationship("Project", back_populates="media")
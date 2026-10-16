from app.core.database import Base
from sqlalchemy import Boolean, Column, DateTime, Integer, String, Text
from sqlalchemy.sql import func


class User(Base):
  __tablename__ = "users"

  id = Column(Integer, primary_key=True, index=True)
  username = Column(String(50), unique=True, index=True, nullable=False)
  email = Column(String(100), unique=True, index=True, nullable=False)
  hashed_password = Column(String(255), nullable=False)
  full_name = Column(String(100), nullable=False)
  headline = Column(String(255), nullable=True)
  bio = Column(Text, nullable=True)
  avatar_url = Column(String(255), nullable=True)
  resume_url = Column(String(255), nullable=True)
  is_active = Column(Boolean, default=True)
  role = Column(String(10), default="user", nullable=False)
  profile_slug = Column(String(60), unique=True, index=True, nullable=True)
  is_published = Column(Boolean, default=False, nullable=False)
  created_at = Column(
      DateTime(timezone=True), server_default=func.now(), nullable=False
  )
from app.core.database import Base
from sqlalchemy import JSON, Boolean, Column, Date, DateTime, Integer, String, Text
from sqlalchemy.sql import func


class Experience(Base):
  __tablename__ = "experiences"

  id = Column(Integer, primary_key=True, index=True)
  role = Column(String(100), nullable=False)
  company = Column(String(100), nullable=False)
  location = Column(String(100), nullable=True)
  employment_type = Column(
      String(50), default="Full-time"
  )  # Full-time, Freelance, Contract
  start_date = Column(Date, nullable=False)
  end_date = Column(Date, nullable=True)
  is_current = Column(Boolean, default=False)
  description = Column(Text, nullable=True)
  technologies_used = Column(JSON, default=list)
  created_at = Column(
      DateTime(timezone=True), server_default=func.now(), nullable=False
  )
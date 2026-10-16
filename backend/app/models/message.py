from app.core.database import Base
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.sql import func


class Message(Base):
  __tablename__ = "messages"

  id = Column(Integer, primary_key=True, index=True)
  recipient_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
  sender_name = Column(String(100), nullable=False)
  sender_email = Column(String(100), nullable=False)
  subject = Column(String(200), nullable=False)
  content = Column(Text, nullable=False)
  is_read = Column(Boolean, default=False, index=True)
  ip_address = Column(String(45), nullable=True)
  created_at = Column(
      DateTime(timezone=True), server_default=func.now(), nullable=False
  )
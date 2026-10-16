from datetime import datetime
from pydantic import BaseModel, EmailStr, Field


class MessageCreate(BaseModel):
  sender_name: str = Field(min_length=2, max_length=100)
  sender_email: EmailStr
  subject: str = Field(min_length=3, max_length=200)
  content: str = Field(min_length=10, max_length=5000)

  model_config = {"str_strip_whitespace": True}


class MessageResponse(MessageCreate):
  id: int
  is_read: bool
  created_at: datetime

  class Config:
    from_attributes = True

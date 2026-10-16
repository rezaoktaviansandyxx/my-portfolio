from typing import Optional
from pydantic import BaseModel, EmailStr


class Token(BaseModel):
  access_token: str
  token_type: str


class TokenPayload(BaseModel):
  sub: Optional[str] = None


class UserBase(BaseModel):
  username: str
  email: EmailStr
  full_name: str
  headline: Optional[str] = None
  bio: Optional[str] = None
  avatar_url: Optional[str] = None
  resume_url: Optional[str] = None


class UserResponse(UserBase):
  id: int
  is_active: bool

  class Config:
    from_attributes = True
from typing import Literal, Optional
from pydantic import BaseModel, EmailStr, Field


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
  role: str
  profile_slug: Optional[str] = None
  is_published: bool

  class Config:
    from_attributes = True


class RegisterRequest(BaseModel):
  username: str = Field(pattern=r"^[a-z0-9_]{3,30}$")
  email: EmailStr
  password: str = Field(min_length=8, max_length=128)
  full_name: str = Field(min_length=2, max_length=100)


class ChangePasswordRequest(BaseModel):
  current_password: str
  new_password: str = Field(min_length=8, max_length=128)


class AdminUserUpdate(BaseModel):
  is_active: Optional[bool] = None
  is_published: Optional[bool] = None
  role: Optional[Literal["admin", "user"]] = None
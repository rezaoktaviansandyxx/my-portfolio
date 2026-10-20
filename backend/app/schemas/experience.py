from datetime import date
from typing import List, Optional
from pydantic import BaseModel, Field


class ExperienceBase(BaseModel):
  role: str = Field(min_length=2, max_length=100)
  company: str = Field(min_length=2, max_length=100)
  location: Optional[str] = Field(default=None, max_length=100)
  employment_type: str = Field(default="Full-time", max_length=50)
  start_date: date
  end_date: Optional[date] = None
  is_current: bool = False
  description: Optional[str] = None
  technologies_used: List[str] = []

  model_config = {"str_strip_whitespace": True}


class ExperienceCreate(ExperienceBase):
  # Khusus admin: buat pengalaman atas nama kreator lain.
  owner_id: Optional[int] = None


class ExperienceUpdate(BaseModel):
  role: Optional[str] = Field(default=None, min_length=2, max_length=100)
  company: Optional[str] = Field(default=None, min_length=2, max_length=100)
  location: Optional[str] = Field(default=None, max_length=100)
  employment_type: Optional[str] = Field(default=None, max_length=50)
  start_date: Optional[date] = None
  end_date: Optional[date] = None
  is_current: Optional[bool] = None
  description: Optional[str] = None
  technologies_used: Optional[List[str]] = None

  model_config = {"str_strip_whitespace": True}


class ExperienceResponse(ExperienceBase):
  id: int

  class Config:
    from_attributes = True

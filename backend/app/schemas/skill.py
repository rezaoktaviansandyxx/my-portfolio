from typing import Literal, Optional
from pydantic import BaseModel, Field


class SkillBase(BaseModel):
  name: str = Field(min_length=1, max_length=60)
  category: Literal["Frontend", "Backend", "Database", "Tools", "Other"] = (
      "Other"
  )
  proficiency_level: Optional[int] = Field(default=None, ge=1, le=100)
  icon_url: Optional[str] = None
  display_order: int = Field(default=0, ge=0)

  model_config = {"str_strip_whitespace": True}


class SkillCreate(SkillBase):
  pass


class SkillUpdate(BaseModel):
  name: Optional[str] = Field(default=None, min_length=1, max_length=60)
  category: Optional[
      Literal["Frontend", "Backend", "Database", "Tools", "Other"]
  ] = None
  proficiency_level: Optional[int] = Field(default=None, ge=1, le=100)
  icon_url: Optional[str] = None
  display_order: Optional[int] = Field(default=None, ge=0)

  model_config = {"str_strip_whitespace": True}


class SkillResponse(SkillBase):
  id: int

  class Config:
    from_attributes = True

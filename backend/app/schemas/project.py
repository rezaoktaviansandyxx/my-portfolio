from datetime import datetime
from typing import List, Literal, Optional
from app.schemas.skill import SkillResponse
from pydantic import BaseModel, Field


class ProjectMediaResponse(BaseModel):
  id: int
  media_url: str
  media_type: str
  caption: Optional[str] = None
  display_order: int

  class Config:
    from_attributes = True


class ProjectBase(BaseModel):
  title: str = Field(min_length=3, max_length=150)
  slug: str = Field(pattern=r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
  summary: str = Field(min_length=10)
  problem_statement: Optional[str] = None
  solution: Optional[str] = None
  key_features: List[str] = []
  cover_image_url: Optional[str] = None
  meta_description: Optional[str] = None
  live_url: Optional[str] = None
  github_url: Optional[str] = None
  is_featured: bool = False
  status: Literal["draft", "published"] = "published"
  display_order: int = Field(default=0, ge=0)

  model_config = {"str_strip_whitespace": True}


class ProjectCreate(ProjectBase):
  skill_ids: List[int] = []


class ProjectUpdate(BaseModel):
  title: Optional[str] = Field(default=None, min_length=3, max_length=150)
  slug: Optional[str] = Field(
      default=None, pattern=r"^[a-z0-9]+(?:-[a-z0-9]+)*$"
  )
  summary: Optional[str] = Field(default=None, min_length=10)
  problem_statement: Optional[str] = None
  solution: Optional[str] = None
  key_features: Optional[List[str]] = None
  cover_image_url: Optional[str] = None
  meta_description: Optional[str] = None
  live_url: Optional[str] = None
  github_url: Optional[str] = None
  is_featured: Optional[bool] = None
  status: Optional[Literal["draft", "published"]] = None
  display_order: Optional[int] = Field(default=None, ge=0)
  skill_ids: Optional[List[int]] = None

  model_config = {"str_strip_whitespace": True}


class OwnerBrief(BaseModel):
  profile_slug: str
  full_name: str
  avatar_url: Optional[str] = None

  class Config:
    from_attributes = True


class ProjectListResponse(BaseModel):
  id: int
  title: str
  slug: str
  summary: str
  cover_image_url: Optional[str] = None
  live_url: Optional[str] = None
  github_url: Optional[str] = None
  is_featured: bool
  display_order: int
  skills: List[SkillResponse] = []
  media: List[ProjectMediaResponse] = []
  owner: Optional[OwnerBrief] = None

  class Config:
    from_attributes = True


class ProjectDetailResponse(ProjectBase):
  id: int
  created_at: datetime
  updated_at: Optional[datetime] = None
  media: List[ProjectMediaResponse] = []
  skills: List[SkillResponse] = []

  class Config:
    from_attributes = True

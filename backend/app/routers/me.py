from typing import List, Optional

from app.core.database import get_db
from app.models.experience import Experience
from app.models.message import Message
from app.models.project import Project, ProjectMedia
from app.models.skill import Skill
from app.models.user import User
from app.routers.deps import get_current_user
from app.schemas.auth import UserResponse
from app.schemas.experience import (
    ExperienceCreate,
    ExperienceResponse,
    ExperienceUpdate,
)
from app.schemas.message import MessageResponse
from app.schemas.project import (
    ProjectCreate,
    ProjectDetailResponse,
    ProjectMediaResponse,
    ProjectUpdate,
)
from app.schemas.skill import SkillCreate, SkillResponse, SkillUpdate
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

router = APIRouter(prefix="/me", tags=["Me"])


class ProfileUpdate(BaseModel):
  full_name: Optional[str] = Field(default=None, min_length=2, max_length=100)
  headline: Optional[str] = Field(default=None, max_length=255)
  bio: Optional[str] = None
  avatar_url: Optional[str] = None
  resume_url: Optional[str] = None
  profile_slug: Optional[str] = Field(
      default=None, pattern=r"^[a-z0-9]+(?:-[a-z0-9]+)*$", max_length=60
  )

  model_config = {"str_strip_whitespace": True}


def _owned_project(db: Session, pid: int, uid: int) -> Project:
  p = (
      db.query(Project)
      .filter(Project.id == pid, Project.owner_id == uid)
      .first()
  )
  if not p:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Proyek tidak ditemukan"
    )
  return p


def _owned_skill(db: Session, sid: int, uid: int) -> Skill:
  s = db.query(Skill).filter(Skill.id == sid, Skill.owner_id == uid).first()
  if not s:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Skill tidak ditemukan"
    )
  return s


def _owned_experience(db: Session, eid: int, uid: int) -> Experience:
  e = (
      db.query(Experience)
      .filter(Experience.id == eid, Experience.owner_id == uid)
      .first()
  )
  if not e:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Experience tidak ditemukan",
    )
  return e


def _resolve_owned_skills(
    db: Session, skill_ids: List[int], uid: int
) -> List[Skill]:
  if not skill_ids:
    return []
  skills = (
      db.query(Skill)
      .filter(Skill.id.in_(skill_ids), Skill.owner_id == uid)
      .all()
  )
  if len(skills) != len(set(skill_ids)):
    raise HTTPException(
        status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
        detail="Skill harus milik sendiri",
    )
  return skills


# --- Profile ---
@router.get("/profile", response_model=UserResponse)
def get_profile(current: User = Depends(get_current_user)):
  return current


@router.put("/profile", response_model=UserResponse)
def update_profile(
    payload: ProfileUpdate,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  if payload.profile_slug and payload.profile_slug != current.profile_slug:
    exists = (
        db.query(User)
        .filter(
            User.profile_slug == payload.profile_slug, User.id != current.id
        )
        .first()
    )
    if exists:
      raise HTTPException(
          status_code=status.HTTP_409_CONFLICT,
          detail="profile_slug sudah dipakai",
      )
  for k, v in payload.model_dump(exclude_unset=True).items():
    setattr(current, k, v)
  try:
    db.commit()
    db.refresh(current)
  except IntegrityError:
    db.rollback()
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT,
        detail="profile_slug sudah dipakai",
    )
  return current


@router.post("/publish")
def publish(
    db: Session = Depends(get_db), current: User = Depends(get_current_user)
):
  if not current.profile_slug:
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="Isi profile_slug dulu",
    )
  current.is_published = True
  db.commit()
  return {"is_published": True}


@router.post("/unpublish")
def unpublish(
    db: Session = Depends(get_db), current: User = Depends(get_current_user)
):
  current.is_published = False
  db.commit()
  return {"is_published": False}


# --- Projects ---
@router.get("/projects", response_model=List[ProjectDetailResponse])
def list_my_projects(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  return (
      db.query(Project)
      .filter(Project.owner_id == current.id)
      .order_by(Project.created_at.desc())
      .offset(skip)
      .limit(limit)
      .all()
  )


@router.post(
    "/projects",
    response_model=ProjectDetailResponse,
    status_code=status.HTTP_201_CREATED,
)
def me_create_project(
    payload: ProjectCreate,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  if (
      db.query(Project)
      .filter(Project.owner_id == current.id, Project.slug == payload.slug)
      .first()
  ):
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT, detail="Slug sudah dipakai"
    )
  skills = _resolve_owned_skills(db, payload.skill_ids or [], current.id)
  p = Project(
      **payload.model_dump(exclude={"skill_ids"}),
      owner_id=current.id,
      skills=skills,
  )
  db.add(p)
  try:
    db.commit()
    db.refresh(p)
  except IntegrityError:
    db.rollback()
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT, detail="Slug sudah dipakai"
    )
  return p


@router.patch("/projects/{project_id}", response_model=ProjectDetailResponse)
def me_update_project(
    project_id: int,
    payload: ProjectUpdate,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  p = _owned_project(db, project_id, current.id)
  if payload.slug and payload.slug != p.slug:
    dup = (
        db.query(Project)
        .filter(Project.owner_id == current.id, Project.slug == payload.slug)
        .first()
    )
    if dup:
      raise HTTPException(
          status_code=status.HTTP_409_CONFLICT, detail="Slug sudah dipakai"
      )
  for k, v in payload.model_dump(exclude_unset=True, exclude={"skill_ids"}).items():
    setattr(p, k, v)
  if payload.skill_ids is not None:
    p.skills = _resolve_owned_skills(db, payload.skill_ids, current.id)
  try:
    db.commit()
    db.refresh(p)
  except IntegrityError:
    db.rollback()
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT, detail="Slug sudah dipakai"
    )
  return p


@router.delete("/projects/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
def me_delete_project(
    project_id: int,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  p = _owned_project(db, project_id, current.id)
  db.delete(p)
  db.commit()
  return None


@router.post(
    "/projects/{project_id}/media",
    response_model=ProjectMediaResponse,
    status_code=status.HTTP_201_CREATED,
)
def me_add_project_media(
    project_id: int,
    media_url: str,
    media_type: str = "image",
    caption: Optional[str] = None,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  _owned_project(db, project_id, current.id)
  m = ProjectMedia(
      project_id=project_id,
      media_url=media_url,
      media_type=media_type,
      caption=caption,
  )
  db.add(m)
  db.commit()
  db.refresh(m)
  return m


# --- Skills ---
@router.get("/skills", response_model=List[SkillResponse])
def list_my_skills(
    db: Session = Depends(get_db), current: User = Depends(get_current_user)
):
  return (
      db.query(Skill)
      .filter(Skill.owner_id == current.id)
      .order_by(Skill.display_order.asc(), Skill.id.asc())
      .all()
  )


@router.post(
    "/skills",
    response_model=SkillResponse,
    status_code=status.HTTP_201_CREATED,
)
def me_create_skill(
    payload: SkillCreate,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  if (
      db.query(Skill)
      .filter(Skill.owner_id == current.id, Skill.name == payload.name)
      .first()
  ):
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT, detail="Skill sudah ada"
    )
  s = Skill(**payload.model_dump(), owner_id=current.id)
  db.add(s)
  try:
    db.commit()
    db.refresh(s)
  except IntegrityError:
    db.rollback()
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT, detail="Skill sudah ada"
    )
  return s


@router.patch("/skills/{skill_id}", response_model=SkillResponse)
def me_update_skill(
    skill_id: int,
    payload: SkillUpdate,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  s = _owned_skill(db, skill_id, current.id)
  if payload.name and payload.name != s.name:
    dup = (
        db.query(Skill)
        .filter(Skill.owner_id == current.id, Skill.name == payload.name)
        .first()
    )
    if dup:
      raise HTTPException(
          status_code=status.HTTP_409_CONFLICT, detail="Skill sudah ada"
      )
  for k, v in payload.model_dump(exclude_unset=True).items():
    setattr(s, k, v)
  try:
    db.commit()
    db.refresh(s)
  except IntegrityError:
    db.rollback()
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT, detail="Skill sudah ada"
    )
  return s


@router.delete("/skills/{skill_id}", status_code=status.HTTP_204_NO_CONTENT)
def me_delete_skill(
    skill_id: int,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  s = _owned_skill(db, skill_id, current.id)
  db.delete(s)
  db.commit()
  return None


# --- Experiences ---
@router.get("/experiences", response_model=List[ExperienceResponse])
def list_my_experiences(
    db: Session = Depends(get_db), current: User = Depends(get_current_user)
):
  return (
      db.query(Experience)
      .filter(Experience.owner_id == current.id)
      .order_by(Experience.start_date.desc())
      .all()
  )


@router.post(
    "/experiences",
    response_model=ExperienceResponse,
    status_code=status.HTTP_201_CREATED,
)
def me_create_experience(
    payload: ExperienceCreate,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  e = Experience(**payload.model_dump(), owner_id=current.id)
  db.add(e)
  db.commit()
  db.refresh(e)
  return e


@router.patch("/experiences/{exp_id}", response_model=ExperienceResponse)
def me_update_experience(
    exp_id: int,
    payload: ExperienceUpdate,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  e = _owned_experience(db, exp_id, current.id)
  for k, v in payload.model_dump(exclude_unset=True).items():
    setattr(e, k, v)
  db.commit()
  db.refresh(e)
  return e


@router.delete("/experiences/{exp_id}", status_code=status.HTTP_204_NO_CONTENT)
def me_delete_experience(
    exp_id: int,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  e = _owned_experience(db, exp_id, current.id)
  db.delete(e)
  db.commit()
  return None


# --- Messages (inbox milik sendiri) ---
@router.get("/messages", response_model=List[MessageResponse])
def list_my_messages(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  return (
      db.query(Message)
      .filter(Message.recipient_id == current.id)
      .order_by(Message.created_at.desc())
      .offset(skip)
      .limit(limit)
      .all()
  )


@router.patch("/messages/{message_id}/read")
def me_mark_message_read(
    message_id: int,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  msg = (
      db.query(Message)
      .filter(Message.id == message_id, Message.recipient_id == current.id)
      .first()
  )
  if not msg:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Pesan tidak ditemukan"
    )
  msg.is_read = True
  db.commit()
  return {"message": "Status pesan berhasil diperbarui"}


@router.delete("/messages/{message_id}", status_code=status.HTTP_204_NO_CONTENT)
def me_delete_message(
    message_id: int,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  msg = (
      db.query(Message)
      .filter(Message.id == message_id, Message.recipient_id == current.id)
      .first()
  )
  if not msg:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Pesan tidak ditemukan"
    )
  db.delete(msg)
  db.commit()
  return None

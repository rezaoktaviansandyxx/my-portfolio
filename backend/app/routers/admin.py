from typing import List, Literal, Optional
from app.core.database import get_db
from app.core.security import get_password_hash
from app.models.experience import Experience
from app.models.message import Message
from app.models.project import Project, ProjectMedia
from app.models.skill import Skill
from app.models.user import User
from app.routers.deps import get_current_admin
from app.schemas.auth import AdminUserUpdate, UserResponse
from app.schemas.experience import (
    ExperienceCreate,
    ExperienceResponse,
    ExperienceUpdate,
)
from app.schemas.message import MessageResponse
from app.schemas.project import (
    ProjectCreate,
    ProjectDetailResponse,
    ProjectUpdate,
)
from app.schemas.skill import SkillCreate, SkillResponse, SkillUpdate
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

router = APIRouter(prefix="/admin", tags=["Admin - CRUD"])


class AdminUserCreate(BaseModel):
  username: str = Field(pattern=r"^[a-z0-9_]{3,30}$")
  email: EmailStr
  password: str = Field(min_length=8, max_length=128)
  full_name: str = Field(min_length=2, max_length=100)
  role: Literal["admin", "user"] = "user"


@router.post(
    "/projects",
    response_model=ProjectDetailResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_project(
    payload: ProjectCreate,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_admin),
):
  existing = (
      db.query(Project)
      .filter(
          Project.owner_id == current.id, Project.slug == payload.slug
      )
      .first()
  )
  if existing:
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="Slug sudah digunakan oleh proyek lain",
    )

  skills = []
  if payload.skill_ids:
    skills = db.query(Skill).filter(Skill.id.in_(payload.skill_ids)).all()

  project_data = payload.model_dump(exclude={"skill_ids"})
  project = Project(**project_data, owner_id=current.id, skills=skills)
  db.add(project)
  try:
    db.commit()
    db.refresh(project)
  except IntegrityError:
    # Race: cek lalu INSERT bisa dilewati dua request serentak; terjemahkan
    # tabrakan constraint DB jadi 409 (bukan 500), pattern sama me_create_project.
    db.rollback()
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT,
        detail="Slug sudah digunakan oleh proyek lain",
    )
  return project


@router.patch("/projects/{project_id}", response_model=ProjectDetailResponse)
def update_project(
    project_id: int,
    payload: ProjectUpdate,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  project = db.query(Project).filter(Project.id == project_id).first()
  if not project:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Proyek tidak ditemukan"
    )
  if payload.slug and payload.slug != project.slug:
    exists = (
        db.query(Project)
        .filter(
            Project.owner_id == project.owner_id,
            Project.slug == payload.slug,
        )
        .first()
    )
    if exists:
      raise HTTPException(
          status_code=status.HTTP_400_BAD_REQUEST,
          detail="Slug sudah digunakan oleh proyek lain",
      )
  data = payload.model_dump(exclude_unset=True, exclude={"skill_ids"})
  for k, v in data.items():
    setattr(project, k, v)
  if payload.skill_ids is not None:
    project.skills = (
        db.query(Skill).filter(Skill.id.in_(payload.skill_ids)).all()
        if payload.skill_ids
        else []
    )
  try:
    db.commit()
    db.refresh(project)
  except IntegrityError:
    db.rollback()
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT,
        detail="Slug sudah digunakan oleh proyek lain",
    )
  return project


@router.delete("/projects/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_project(
    project_id: int,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  project = db.query(Project).filter(Project.id == project_id).first()
  if not project:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Proyek tidak ditemukan"
    )
  db.delete(project)
  db.commit()
  return None


@router.post(
    "/projects/{project_id}/media", status_code=status.HTTP_201_CREATED
)
def add_project_media(
    project_id: int,
    media_url: str,
    media_type: str = "image",
    caption: Optional[str] = None,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  project = db.query(Project).filter(Project.id == project_id).first()
  if not project:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Proyek tidak ditemukan"
    )
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
@router.post(
    "/skills", response_model=SkillResponse, status_code=status.HTTP_201_CREATED
)
def create_skill(
    payload: SkillCreate,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_admin),
):
  if db.query(Skill).filter(Skill.name == payload.name).first():
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="Skill sudah ada"
    )
  s = Skill(**payload.model_dump(), owner_id=current.id)
  db.add(s)
  db.commit()
  db.refresh(s)
  return s


@router.patch("/skills/{skill_id}", response_model=SkillResponse)
def update_skill(
    skill_id: int,
    payload: SkillUpdate,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  s = db.query(Skill).filter(Skill.id == skill_id).first()
  if not s:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Skill tidak ditemukan"
    )
  for k, v in payload.model_dump(exclude_unset=True).items():
    setattr(s, k, v)
  db.commit()
  db.refresh(s)
  return s


@router.delete("/skills/{skill_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_skill(
    skill_id: int,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  s = db.query(Skill).filter(Skill.id == skill_id).first()
  if not s:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Skill tidak ditemukan"
    )
  db.delete(s)
  db.commit()
  return None


# --- Experiences ---
@router.post(
    "/experiences",
    response_model=ExperienceResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_experience(
    payload: ExperienceCreate,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_admin),
):
  e = Experience(**payload.model_dump(), owner_id=current.id)
  db.add(e)
  db.commit()
  db.refresh(e)
  return e


@router.patch("/experiences/{exp_id}", response_model=ExperienceResponse)
def update_experience(
    exp_id: int,
    payload: ExperienceUpdate,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  e = db.query(Experience).filter(Experience.id == exp_id).first()
  if not e:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Experience tidak ditemukan",
    )
  for k, v in payload.model_dump(exclude_unset=True).items():
    setattr(e, k, v)
  db.commit()
  db.refresh(e)
  return e


@router.delete(
    "/experiences/{exp_id}", status_code=status.HTTP_204_NO_CONTENT
)
def delete_experience(
    exp_id: int,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  e = db.query(Experience).filter(Experience.id == exp_id).first()
  if not e:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Experience tidak ditemukan",
    )
  db.delete(e)
  db.commit()
  return None


@router.get("/messages", response_model=List[MessageResponse])
def get_all_messages(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  return (
      db.query(Message)
      .order_by(Message.created_at.desc())
      .offset(skip)
      .limit(limit)
      .all()
  )


@router.patch("/messages/{message_id}/mark-read")
def mark_message_as_read(
    message_id: int, db: Session = Depends(get_db), _=Depends(get_current_admin)
):
  msg = db.query(Message).filter(Message.id == message_id).first()
  if not msg:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Pesan tidak ditemukan"
    )
  msg.is_read = True
  db.commit()
  return {"message": "Status pesan berhasil diperbarui"}


@router.delete(
    "/messages/{message_id}", status_code=status.HTTP_204_NO_CONTENT
)
def delete_message(
    message_id: int, db: Session = Depends(get_db), _=Depends(get_current_admin)
):
  msg = db.query(Message).filter(Message.id == message_id).first()
  if not msg:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Pesan tidak ditemukan"
    )
  db.delete(msg)
  db.commit()
  return None


# --- Moderasi users ---
@router.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def admin_create_user(
    payload: AdminUserCreate,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  existing = (
      db.query(User)
      .filter((User.username == payload.username) | (User.email == payload.email))
      .first()
  )
  if existing:
    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT,
        detail="Username atau email sudah dipakai",
    )
  u = User(
      username=payload.username,
      email=payload.email,
      hashed_password=get_password_hash(payload.password),
      full_name=payload.full_name,
      role=payload.role,
      profile_slug=None,
      is_published=False,
      is_active=True,
  )
  db.add(u)
  db.commit()
  db.refresh(u)
  return u


@router.get("/users", response_model=List[UserResponse])
def admin_list_users(
    db: Session = Depends(get_db), _=Depends(get_current_admin)
):
  return db.query(User).order_by(User.id.asc()).all()


@router.patch("/users/{user_id}", response_model=UserResponse)
def admin_update_user(
    user_id: int,
    payload: AdminUserUpdate,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  u = db.query(User).filter(User.id == user_id).first()
  if not u:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="User tidak ditemukan"
    )
  for k, v in payload.model_dump(exclude_unset=True).items():
    setattr(u, k, v)
  db.commit()
  db.refresh(u)
  return u


# --- Moderasi projects lintas user ---
@router.get("/projects", response_model=List[ProjectDetailResponse])
def admin_list_projects(
    owner_id: Optional[int] = Query(default=None),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  q = db.query(Project).order_by(Project.created_at.desc())
  if owner_id is not None:
    q = q.filter(Project.owner_id == owner_id)
  return q.offset(skip).limit(limit).all()

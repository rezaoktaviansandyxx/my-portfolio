from typing import List, Literal, Optional
from app.core.database import get_db
from app.core.security import get_password_hash
from app.models.experience import Experience
from app.models.message import Message
from app.models.project import Project, ProjectMedia
from app.models.skill import Skill
from app.models.user import User
from app.routers.deps import get_current_admin
from app.routers.me import _resolve_owned_skills
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
from app.services.storage import remove_project_files
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

router = APIRouter(prefix="/admin", tags=["Admin - CRUD"])


class AdminUserCreate(BaseModel):
  username: str = Field(pattern=r"^[a-z0-9_]{3,30}$")
  email: EmailStr
  password: str = Field(min_length=8, max_length=72)  # batas bcrypt
  full_name: str = Field(min_length=2, max_length=100)
  role: Literal["admin", "user"] = "user"
  # Diisi dari POST /admin/upload/resume bila admin mengunggah CV.
  resume_url: Optional[str] = None


def _resolve_owner(db: Session, current: User, owner_id: Optional[int]) -> int:
  """owner_id eksplisit hanya boleh menunjuk user yang ada.

  None = konten milik admin sendiri (perilaku lama dipertahankan).
  """
  if owner_id is None:
    return current.id
  if db.query(User).filter(User.id == owner_id).first() is None:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Pemilik tidak ditemukan"
    )
  return owner_id


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
  owner_id = _resolve_owner(db, current, payload.owner_id)
  existing = (
      db.query(Project)
      .filter(Project.owner_id == owner_id, Project.slug == payload.slug)
      .first()
  )
  if existing:
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="Slug sudah digunakan oleh proyek lain",
    )

  # Skill milik owner lain yang diam-diam hilang = konten portofolio salah;
  # pakai helper yang sama dengan jalur /me agar menolak (422), bukan membuang.
  skills = _resolve_owned_skills(db, payload.skill_ids or [], owner_id)

  project_data = payload.model_dump(exclude={"skill_ids", "owner_id"})
  project = Project(**project_data, owner_id=owner_id, skills=skills)
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
  # Bersihkan file upload terkait (cover + media) sebelum project hilang,
  # agar disk tidak penuh file orphan.
  media_urls = [project.cover_image_url]
  media_urls += [m.media_url for m in project.media]
  remove_project_files(media_urls)
  db.delete(project)
  db.commit()
  return None


@router.post(
    "/projects/{project_id}/media", status_code=status.HTTP_201_CREATED
)
def add_project_media(
    project_id: int,
    media_url: str = Query(
        ...,
        max_length=255,
        pattern=r"^(https?://|/static/)",
        description="URL absolut atau path /static/ hasil upload",
    ),
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
  owner_id = _resolve_owner(db, current, payload.owner_id)
  if (
      db.query(Skill)
      .filter(Skill.owner_id == owner_id, Skill.name == payload.name)
      .first()
  ):
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="Skill sudah ada"
    )
  s = Skill(**payload.model_dump(exclude={"owner_id"}), owner_id=owner_id)
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
  owner_id = _resolve_owner(db, current, payload.owner_id)
  e = Experience(
      **payload.model_dump(exclude={"owner_id"}), owner_id=owner_id
  )
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
      resume_url=payload.resume_url,
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


# --- Moderasi skills & experiences lintas user ---
@router.get("/skills", response_model=List[SkillResponse])
def admin_list_skills(
    owner_id: Optional[int] = Query(default=None),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  q = db.query(Skill).order_by(Skill.id)
  if owner_id is not None:
    q = q.filter(Skill.owner_id == owner_id)
  return q.offset(skip).limit(limit).all()


@router.get("/experiences", response_model=List[ExperienceResponse])
def admin_list_experiences(
    owner_id: Optional[int] = Query(default=None),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  q = db.query(Experience).order_by(
      Experience.start_date.desc(), Experience.id
  )
  if owner_id is not None:
    q = q.filter(Experience.owner_id == owner_id)
  return q.offset(skip).limit(limit).all()

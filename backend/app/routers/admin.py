from typing import List, Optional
from app.core.database import get_db
from app.models.experience import Experience
from app.models.message import Message
from app.models.project import Project, ProjectMedia
from app.models.skill import Skill
from app.routers.deps import get_current_admin
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
from sqlalchemy.orm import Session

router = APIRouter(prefix="/admin", tags=["Admin - CRUD"])


@router.post(
    "/projects",
    response_model=ProjectDetailResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_project(
    payload: ProjectCreate,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  existing = db.query(Project).filter(Project.slug == payload.slug).first()
  if existing:
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="Slug sudah digunakan oleh proyek lain",
    )

  skills = []
  if payload.skill_ids:
    skills = db.query(Skill).filter(Skill.id.in_(payload.skill_ids)).all()

  project_data = payload.model_dump(exclude={"skill_ids"})
  project = Project(**project_data, skills=skills)
  db.add(project)
  db.commit()
  db.refresh(project)
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
    exists = db.query(Project).filter(Project.slug == payload.slug).first()
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
  db.commit()
  db.refresh(project)
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
    _=Depends(get_current_admin),
):
  if db.query(Skill).filter(Skill.name == payload.name).first():
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="Skill sudah ada"
    )
  s = Skill(**payload.model_dump())
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
    _=Depends(get_current_admin),
):
  e = Experience(**payload.model_dump())
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

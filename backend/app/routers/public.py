from typing import List
from app.core.database import get_db
from app.core.rate_limit import limiter
from app.models.experience import Experience
from app.models.message import Message
from app.models.project import Project
from app.models.skill import Skill
from app.models.user import User
from app.schemas.auth import UserResponse
from app.schemas.experience import ExperienceResponse
from app.schemas.message import MessageCreate, MessageResponse
from app.schemas.project import ProjectDetailResponse, ProjectListResponse
from app.schemas.skill import SkillResponse
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

router = APIRouter(prefix="/public", tags=["Public"])


@router.get("/profile", response_model=UserResponse)
def get_public_profile(db: Session = Depends(get_db)):
  user = db.query(User).filter(User.is_active == True).first()
  if not user:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Profil belum dibuat"
    )
  return user


@router.get("/projects", response_model=List[ProjectListResponse])
def get_projects(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
  return (
      db.query(Project)
      .filter(Project.status == "published")
      .order_by(Project.display_order.asc(), Project.created_at.desc())
      .offset(skip)
      .limit(limit)
      .all()
  )


@router.get("/projects/{slug}", response_model=ProjectDetailResponse)
def get_project_by_slug(slug: str, db: Session = Depends(get_db)):
  project = (
      db.query(Project)
      .filter(Project.slug == slug, Project.status == "published")
      .first()
  )
  if not project:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Proyek tidak ditemukan"
    )
  return project


@router.get("/skills", response_model=List[SkillResponse])
def get_skills(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: Session = Depends(get_db),
):
  return (
      db.query(Skill)
      .order_by(Skill.category.asc(), Skill.display_order.asc())
      .offset(skip)
      .limit(limit)
      .all()
  )


@router.get("/experiences", response_model=List[ExperienceResponse])
def get_experiences(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
):
  return (
      db.query(Experience)
      .order_by(Experience.is_current.desc(), Experience.start_date.desc())
      .offset(skip)
      .limit(limit)
      .all()
  )


@router.post(
    "/contact",
    response_model=MessageResponse,
    status_code=status.HTTP_201_CREATED,
)
@limiter.limit("5/minute")
def send_contact_message(
    request: Request,
    payload: MessageCreate,
    db: Session = Depends(get_db),
):
  client_ip = request.client.host if request.client else None
  msg = Message(**payload.model_dump(), ip_address=client_ip)
  db.add(msg)
  db.commit()
  db.refresh(msg)
  return msg

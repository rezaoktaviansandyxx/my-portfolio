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
from sqlalchemy.orm import Session, selectinload

router = APIRouter(prefix="/public", tags=["Public"])


def _get_published_owner(db: Session, slug: str) -> User:
  u = (
      db.query(User)
      .filter(
          User.profile_slug == slug,
          User.is_active == True,  # noqa: E712
          User.is_published == True,  # noqa: E712
      )
      .first()
  )
  if not u:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Profil tidak ditemukan"
    )
  return u


# ---- Gallery (multi-user) ----


@router.get("/gallery/projects", response_model=List[ProjectListResponse])
def gallery_projects(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
  return (
      db.query(Project)
      .options(selectinload(Project.media))
      .join(User, Project.owner_id == User.id)
      .filter(
          Project.status == "published",
          User.is_active == True,  # noqa: E712
          User.is_published == True,  # noqa: E712
      )
      .order_by(Project.created_at.desc())
      .offset(skip)
      .limit(limit)
      .all()
  )


# ---- Per-user pages ----


@router.get("/u/{slug}/profile", response_model=UserResponse)
def u_profile(slug: str, db: Session = Depends(get_db)):
  return _get_published_owner(db, slug)


@router.get("/u/{slug}/projects", response_model=List[ProjectListResponse])
def u_projects(
    slug: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
  u = _get_published_owner(db, slug)
  return (
      db.query(Project)
      .options(selectinload(Project.media))
      .filter(Project.owner_id == u.id, Project.status == "published")
      .order_by(Project.display_order.asc(), Project.created_at.desc())
      .offset(skip)
      .limit(limit)
      .all()
  )


@router.get("/u/{slug}/skills", response_model=List[SkillResponse])
def u_skills(
    slug: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: Session = Depends(get_db),
):
  u = _get_published_owner(db, slug)
  return (
      db.query(Skill)
      .filter(Skill.owner_id == u.id)
      .order_by(Skill.category.asc(), Skill.display_order.asc())
      .offset(skip)
      .limit(limit)
      .all()
  )


@router.get("/u/{slug}/experiences", response_model=List[ExperienceResponse])
def u_experiences(
    slug: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
):
  u = _get_published_owner(db, slug)
  return (
      db.query(Experience)
      .filter(Experience.owner_id == u.id)
      .order_by(Experience.is_current.desc(), Experience.start_date.desc())
      .offset(skip)
      .limit(limit)
      .all()
  )


@router.post(
    "/u/{slug}/contact",
    response_model=MessageResponse,
    status_code=status.HTTP_201_CREATED,
)
@limiter.limit("5/minute")
def u_contact(
    slug: str,
    request: Request,
    payload: MessageCreate,
    db: Session = Depends(get_db),
):
  u = (
      db.query(User)
      .filter(User.profile_slug == slug, User.is_active == True)  # noqa: E712
      .first()
  )
  if not u:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Profil tidak ditemukan"
    )
  client_ip = request.client.host if request.client else None
  msg = Message(
      **payload.model_dump(), recipient_id=u.id, ip_address=client_ip
  )
  db.add(msg)
  db.commit()
  db.refresh(msg)
  return msg

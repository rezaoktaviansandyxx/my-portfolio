from app.core.database import get_db
from app.core.rate_limit import limiter
from app.core.security import (
    create_access_token,
    get_password_hash,
    verify_password,
)
from app.models.user import User
from app.routers.deps import get_current_user
from app.schemas.auth import (
    ChangePasswordRequest,
    RegisterRequest,
    Token,
    UserResponse,
)
from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register", status_code=status.HTTP_201_CREATED)
@limiter.limit("3/hour")
def register(
    request: Request,
    payload: RegisterRequest,
    db: Session = Depends(get_db),
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
  user = User(
      username=payload.username,
      email=payload.email,
      hashed_password=get_password_hash(payload.password),
      full_name=payload.full_name,
      role="user",
      profile_slug=None,
      is_published=False,
      is_active=True,
  )
  db.add(user)
  db.commit()
  db.refresh(user)
  return {"id": user.id, "username": user.username}


@router.get("/me", response_model=UserResponse)
def me(current: User = Depends(get_current_user)):
  return current


@router.patch("/change-password")
def change_password(
    payload: ChangePasswordRequest,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
):
  if not verify_password(payload.current_password, current.hashed_password):
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="Password lama salah"
    )
  current.hashed_password = get_password_hash(payload.new_password)
  db.commit()
  return {"message": "Password diperbarui"}


@router.post("/login", response_model=Token)
@limiter.limit("10/minute")
def login(
    request: Request,
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
  user = (
      db.query(User)
      .filter(
          (User.username == form_data.username)
          | (User.email == form_data.username)
      )
      .first()
  )
  if not user or not verify_password(form_data.password, user.hashed_password):
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Username atau password salah",
        headers={"WWW-Authenticate": "Bearer"},
    )
  if not user.is_active:
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="Akun dinonaktifkan"
    )

  access_token = create_access_token(subject=user.id)
  return {"access_token": access_token, "token_type": "bearer"}
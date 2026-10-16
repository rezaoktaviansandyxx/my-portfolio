from app.core.database import get_db
from app.core.security import create_access_token, verify_password
from app.models.user import User
from app.schemas.auth import Token
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/login", response_model=Token)
def login(
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
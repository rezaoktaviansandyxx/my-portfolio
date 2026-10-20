from app.core.config import settings
from app.core.database import get_db
from app.models.user import User
from app.schemas.auth import TokenPayload
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl=f"{settings.API_V1_STR}/auth/login"
)


def get_current_user(
    db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)
) -> User:
  credentials_exception = HTTPException(
      status_code=status.HTTP_401_UNAUTHORIZED,
      detail="Kredensial autentikasi tidak valid",
      headers={"WWW-Authenticate": "Bearer"},
  )
  try:
    payload = jwt.decode(
        token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
    )
    user_id: str = payload.get("sub")
    if user_id is None:
      raise credentials_exception
    token_data = TokenPayload(sub=user_id)
  except JWTError:
    raise credentials_exception

  try:
    user_pk = int(token_data.sub)
  except (TypeError, ValueError):
    # Token dengan sub aneh (bukan angka) tetap 401, bukan ValueError → 500.
    raise credentials_exception

  user = db.query(User).filter(User.id == user_pk).first()
  if user is None or not user.is_active:
    raise credentials_exception
  return user


def get_current_admin(
    db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)
) -> User:
  user = get_current_user(db, token)
  if user.role != "admin":
    # 403 = sudah login tapi tak berhak (client bisa bedakan dari 401).
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="Hanya admin yang bisa mengakses endpoint ini",
    )
  return user
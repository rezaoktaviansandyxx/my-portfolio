"""Seed admin awal.

Password TIDAK punya nilai bawaan demi keamanan (audit): bila env
ADMIN_PASSWORD tidak diisi, script membangkitkan password acak dan
menampilkannya sekali di stdout.
"""

import os
import secrets

from app.core.database import SessionLocal
from app.core.security import get_password_hash
from app.models.user import User


def _generate_password() -> str:
  """Password acak 32+ karakter langsung pakai, tanpa gudang default."""
  return secrets.token_urlsafe(24)


def _credentials() -> tuple[str, str, str, str]:
  username = os.getenv("ADMIN_USERNAME", "admin")
  email = os.getenv("ADMIN_EMAIL", "admin@example.com")
  slug = os.getenv("ADMIN_SLUG", "admin")
  password = os.getenv("ADMIN_PASSWORD")
  if not password:
    password = _generate_password()
    print("ADMIN_PASSWORD tidak diisi — password acak dibuat, CATAT SEKARANG:")
    print(f"    {password}")
  return username, email, slug, password


def ensure_admin(
    db, username: str, email: str, password: str, slug: str = "admin"
) -> str:
  """Idempoten: buat admin, atau perbaiki data lama yang belum lengkap."""
  existing = (
      db.query(User)
      .filter((User.username == username) | (User.email == email))
      .first()
  )
  if existing:
    changed = False
    if not existing.profile_slug:
      existing.profile_slug = slug
      changed = True
    if not existing.is_published:
      existing.is_published = True
      changed = True
    if not existing.is_active:
      existing.is_active = True
      changed = True
    if changed:
      db.commit()
      return "fixed existing admin"
    return "exists"
  db.add(
      User(
          username=username,
          email=email,
          hashed_password=get_password_hash(password),
          full_name="Admin",
          is_active=True,
          role="admin",
          profile_slug=slug,
          is_published=True,
      )
  )
  db.commit()
  return "seeded"


def main() -> None:
  username, email, slug, password = _credentials()
  db = SessionLocal()
  try:
    status = ensure_admin(db, username, email, password, slug)
    print(status)
  finally:
    db.close()


if __name__ == "__main__":
  main()

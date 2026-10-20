"""Admin membuat user sekaligus menyimpan hasil upload CV."""

from sqlalchemy import text

from app.core.security import get_password_hash
from app.models.user import User
from tests.conftest import TestingSession, get_client


def _reset_db():
  db = TestingSession()
  db.execute(text("DELETE FROM project_skills"))
  for tbl in ("project_media", "messages", "projects", "skills", "experiences"):
    db.execute(text(f"DELETE FROM {tbl}"))
  db.query(User).delete()
  db.add(
      User(
          username="admin",
          email="admin@x.com",
          hashed_password=get_password_hash("admin123"),
          full_name="Admin",
          role="admin",
          profile_slug="admin",
          is_published=True,
          is_active=True,
      )
  )
  db.commit()
  db.close()


def _admin_auth():
  c = get_client()
  r = c.post("/api/v1/auth/login", data={"username": "admin", "password": "admin123"})
  assert r.status_code == 200, r.text
  return {"Authorization": f"Bearer {r.json()['access_token']}"}


def test_admin_create_user_with_resume_url():
  _reset_db()
  r = get_client().post(
      "/api/v1/admin/users",
      json={
          "username": "carol",
          "email": "carol@x.com",
          "password": "password123",
          "full_name": "Carol",
          "resume_url": "/static/uploads/resumes/cv.pdf",
      },
      headers=_admin_auth(),
  )
  assert r.status_code == 201, r.text
  assert r.json()["resume_url"] == "/static/uploads/resumes/cv.pdf"

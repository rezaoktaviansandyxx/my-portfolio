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


def test_admin_create_user_rejects_non_url_resume_scheme():
  # `resume_url` dibaca frontend sebagai CTA publik dan diteruskan apa adanya ke
  # `launchUrl` (tidak ada allowlist skema), jadi `javascript:` yang lolos di
  # sini berakhir jadi XSS yang bisa diklik pengunjung.
  _reset_db()
  r = get_client().post(
      "/api/v1/admin/users",
      json={
          "username": "carol",
          "email": "carol@x.com",
          "password": "password123",
          "full_name": "Carol",
          "resume_url": "javascript:fetch('/admin/users')",
      },
      headers=_admin_auth(),
  )
  assert r.status_code == 422, r.text


def test_admin_update_user_rejects_non_url_avatar_scheme():
  #lubang yang sama pada `AdminUserUpdate.avatar_url`: nilai ini bocor ke
  # `PublicProfileResponse` dan dirender sebagai URL gambar.
  _reset_db()
  c = get_client()
  created = c.post(
      "/api/v1/admin/users",
      json={
          "username": "carol",
          "email": "carol@x.com",
          "password": "password123",
          "full_name": "Carol",
      },
      headers=_admin_auth(),
  )
  assert created.status_code == 201, created.text
  user_id = created.json()["id"]

  r = c.patch(
      f"/api/v1/admin/users/{user_id}",
      json={"avatar_url": "javascript:alert(1)"},
      headers=_admin_auth(),
  )
  assert r.status_code == 422, r.text

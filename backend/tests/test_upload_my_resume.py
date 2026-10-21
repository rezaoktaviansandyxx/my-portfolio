"""User harus bisa mengunggah CV sendiri (sebelumnya hanya admin)."""

import io

from sqlalchemy import text

from app.models.user import User
from tests.conftest import TestingSession, get_client

# PNG 1x1 valid (magic header + IHDR + IDAT + IEND).
_PNG_1PX = bytes.fromhex(
    "89504e470d0a1a0a0000000d4948445200000001000000010806000000"
    "1f15c4890000000a49444154789c6300010000050001"
    "0d0a2db40000000049454e44ae426082"
)


def _reset_db():
  db = TestingSession()
  db.execute(text("DELETE FROM project_skills"))
  for tbl in ("project_media", "messages", "projects", "skills", "experiences"):
    db.execute(text(f"DELETE FROM {tbl}"))
  db.query(User).delete()
  db.commit()
  db.close()


def _register_login(username, email):
  c = get_client()
  r = c.post(
      "/api/v1/auth/register",
      json={
          "username": username,
          "email": email,
          "password": "password123",
          "full_name": username,
      },
  )
  assert r.status_code == 201, r.text
  r = c.post(
      "/api/v1/auth/login",
      data={"username": username, "password": "password123"},
  )
  assert r.status_code == 200, r.text
  return {"Authorization": f"Bearer {r.json()['access_token']}"}


def test_user_uploads_own_resume():
  _reset_db()
  auth = _register_login("alice", "alice@x.com")
  pdf = b"%PDF-1.4\n%fake\n"
  r = get_client().post(
      "/api/v1/me/upload/resume",
      files={"file": ("cv.pdf", io.BytesIO(pdf), "application/pdf")},
      headers=auth,
  )
  assert r.status_code == 200, r.text
  url = r.json()["url"]
  assert url.startswith("/static/")
  assert url.endswith(".pdf")


def test_resume_upload_rejects_non_pdf():
  _reset_db()
  auth = _register_login("alice", "alice@x.com")
  # PNG asli (magic header + IHDR valid) supaya yang ditolak adalah aturan
  # "dokumen harus PDF", bukan cek magic-bytes.
  r = get_client().post(
      "/api/v1/me/upload/resume",
      files={"file": ("x.png", io.BytesIO(_PNG_1PX), "image/png")},
      headers=auth,
  )
  assert r.status_code == 400


def test_resume_upload_requires_auth():
  r = get_client().post(
      "/api/v1/me/upload/resume",
      files={"file": ("cv.pdf", io.BytesIO(b"%PDF-1.4\n"), "application/pdf")},
  )
  assert r.status_code == 401

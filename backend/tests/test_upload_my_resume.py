"""User harus bisa mengunggah CV sendiri (sebelumnya hanya admin)."""

import io

import pytest
from sqlalchemy import text

from app.models.user import User
from app.services.storage import storage_service
from tests.conftest import TestingSession, get_client

# PNG 1x1 valid (magic header + IHDR + IDAT + IEND).
_PNG_1PX = bytes.fromhex(
    "89504e470d0a1a0a0000000d4948445200000001000000010806000000"
    "1f15c4890000000a49444154789c6300010000050001"
    "0d0a2db40000000049454e44ae426082"
)


@pytest.fixture(autouse=True)
def _uploads_to_tmp(tmp_path, monkeypatch):
  """Jangan tulis artefak ke repo — hanya ke tmp_path.

  Endpoint-nya memakai singleton `storage_service` yang diimpor router,
  jadi mengganti `base_dir` di sini mengalihkan seluruh penulisan.
  URL balasan tetap dari `settings.UPLOAD_DIR`, jadi tidak ikut berubah.
  """
  monkeypatch.setattr(storage_service, "base_dir", tmp_path / "uploads")


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
  # Subfolder wajib per-user — kalau regresi ke "resumes" bersama, dua user
  # akan saling menimpa file dan URL ini tetap lolos cek prefix/suffix di atas.
  me = get_client().get("/api/v1/me/profile", headers=auth)
  assert me.status_code == 200, me.text
  assert f"/u/{me.json()['id']}/resumes/" in url


def test_resume_upload_rejects_non_pdf():
  _reset_db()
  auth = _register_login("alice", "alice@x.com")
  # PNG asli (byte-valid, bukan magic header terpotong) supaya test ini gagal
  # kalau `is_document=True` sampai hilang: tanpa flag itu PNG ini lolos sebagai
  # gambar dan jawabannya 200. Penolakan yang benar-benar terjadi di sini adalah
  # allowlist Content-Type dokumen (`image/png` bukan `application/pdf`), yang
  # dijalankan sebelum `_verify_content` dan sebelum cabang magic `%PDF-`.
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
  assert r.status_code == 401, r.text

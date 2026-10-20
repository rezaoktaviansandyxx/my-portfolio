"""Public project payload must expose outbound links and media.

Covers spec section 5.2.1: `ProjectListResponse` previously omitted
`live_url`, `github_url`, and `media`, which silently disabled the Live Demo /
Repository buttons on the public portfolio and left the showcase carousel
without a data source.
"""

from sqlalchemy import text

from app.core.security import get_password_hash
from app.models.user import User
from tests.conftest import TestingSession, get_client


def _reset_db():
  """Seed one published owner. Mirrors tests/test_multitenant.py."""
  db = TestingSession()
  db.execute(text("DELETE FROM project_skills"))
  for tbl in ("project_media", "messages", "projects", "skills", "experiences"):
    db.execute(text(f"DELETE FROM {tbl}"))
  db.query(User).delete()
  db.add(
      User(
          username="detailtester",
          email="detailtester@x.com",
          hashed_password=get_password_hash("password123"),
          full_name="Detail Tester",
          role="user",
          profile_slug="detail-tester",
          is_published=True,
          is_active=True,
      )
  )
  db.commit()
  db.close()


def _login() -> dict:
  c = get_client()
  r = c.post(
      "/api/v1/auth/login",
      data={"username": "detailtester", "password": "password123"},
  )
  assert r.status_code == 200, r.text
  return {"Authorization": f"Bearer {r.json()['access_token']}"}


def test_public_project_exposes_links_and_media():
  _reset_db()
  client = get_client()
  headers = _login()

  created = client.post(
      "/api/v1/me/projects",
      headers=headers,
      json={
          "title": "Proyek Media",
          "slug": "proyek-media",
          "summary": "Ringkasan yang cukup panjang untuk validasi.",
          "live_url": "https://example.com/live",
          "github_url": "https://github.com/example/repo",
      },
  )
  assert created.status_code in (200, 201), created.text
  pid = created.json()["id"]

  media = client.post(
      f"/api/v1/me/projects/{pid}/media",
      headers=headers,
      params={
          "media_url": "/static/uploads/media/a.png",
          "media_type": "image",
      },
  )
  assert media.status_code in (200, 201), media.text

  res = client.get("/api/v1/public/u/detail-tester/projects")
  assert res.status_code == 200, res.text
  items = res.json()
  assert len(items) == 1, items

  item = items[0]
  assert item["live_url"] == "https://example.com/live"
  assert item["github_url"] == "https://github.com/example/repo"
  assert len(item["media"]) == 1
  assert item["media"][0]["media_url"] == "/static/uploads/media/a.png"


def test_gallery_project_exposes_media_too():
  _reset_db()
  client = get_client()
  headers = _login()

  created = client.post(
      "/api/v1/me/projects",
      headers=headers,
      json={
          "title": "Proyek Galeri",
          "slug": "proyek-galeri",
          "summary": "Ringkasan yang cukup panjang untuk validasi.",
          "github_url": "https://github.com/example/gallery",
      },
  )
  pid = created.json()["id"]
  client.post(
      f"/api/v1/me/projects/{pid}/media",
      headers=headers,
      params={"media_url": "/static/uploads/media/g.png", "media_type": "image"},
  )

  res = client.get("/api/v1/public/gallery/projects")
  assert res.status_code == 200, res.text
  row = next(p for p in res.json() if p["slug"] == "proyek-galeri")
  assert row["github_url"] == "https://github.com/example/gallery"
  assert len(row["media"]) == 1
  assert row["owner"]["profile_slug"] == "detail-tester"

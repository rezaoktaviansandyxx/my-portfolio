"""Multitenant isolation tests (spec section 6).

Covers: same slug across owners OK, 404 on other owners' rows,
unpublished hidden until publish, admin takedown removes gallery/profile.
"""

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


def _login(username, password="password123"):
  c = get_client()
  r = c.post("/api/v1/auth/login", data={"username": username, "password": password})
  assert r.status_code == 200, r.text
  return r.json()["access_token"]


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
  return _login(username)


def _auth(token):
  return {"Authorization": f"Bearer {token}"}


def _gallery_slugs():
  c = get_client()
  assert c.get("/api/v1/public/gallery/projects").status_code == 200
  return [
      (p.get("owner") or {}).get("profile_slug")
      for p in c.get("/api/v1/public/gallery/projects").json()
  ]


def _my_project_id(token, slug):
  c = get_client()
  r = c.get("/api/v1/me/projects", headers=_auth(token))
  assert r.status_code == 200, r.text
  for p in r.json():
    if p["slug"] == slug:
      return p["id"]
  raise AssertionError(f"project {slug!r} not found in own list")


def test_same_slug_different_owner_ok():
  _reset_db()
  ta = _register_login("alice", "alice@x.com")
  tb = _register_login("bob", "bob@x.com")
  c = get_client()
  pa = {
      "title": "Proyek Alice",
      "slug": "proyek-x",
      "summary": "Ringkasan cukup panjang untuk validasi",
  }
  pb = {
      "title": "Proyek Bob",
      "slug": "proyek-x",
      "summary": "Ringkasan cukup panjang untuk validasi",
  }
  assert c.post("/api/v1/me/projects", json=pa, headers=_auth(ta)).status_code == 201
  assert c.post("/api/v1/me/projects", json=pb, headers=_auth(tb)).status_code == 201
  # duplicate slug under the SAME owner must 409
  assert c.post("/api/v1/me/projects", json=pa, headers=_auth(ta)).status_code == 409


def test_cannot_touch_other_owner():
  c = get_client()
  ta = _login("alice")
  tb = _login("bob")
  bob_pid = _my_project_id(tb, "proyek-x")
  # other owner's project: PATCH and DELETE must 404 (not 403, no existence leak)
  res = c.patch(
      f"/api/v1/me/projects/{bob_pid}",
      json={"title": "Coba ambil alih"},
      headers=_auth(ta),
  )
  assert res.status_code == 404
  assert c.delete(f"/api/v1/me/projects/{bob_pid}", headers=_auth(ta)).status_code == 404
  # bob's own project still intact
  assert _my_project_id(tb, "proyek-x") == bob_pid
  # inbox isolation: give alice a slug (unpublished is fine for contact),
  # send her a message, bob must not see it
  assert (
      c.put(
          "/api/v1/me/profile",
          json={"profile_slug": "alice", "full_name": "Alice"},
          headers=_auth(ta),
      ).status_code
      == 200
  )
  contact = {
      "sender_name": "Tamu",
      "sender_email": "tamu@x.com",
      "subject": "Halo Alice",
      "content": "Isi pesan yang cukup panjang untuk validasi",
  }
  assert c.post("/api/v1/public/u/alice/contact", json=contact).status_code == 201
  assert c.get("/api/v1/me/messages", headers=_auth(tb)).json() == []
  alice_inbox = c.get("/api/v1/me/messages", headers=_auth(ta)).json()
  assert len(alice_inbox) == 1
  assert alice_inbox[0]["subject"] == "Halo Alice"


def test_unpublished_hidden_then_visible():
  c = get_client()
  # alice has a slug but is not published yet
  assert c.get("/api/v1/public/u/alice/profile").status_code == 404
  assert "alice" not in _gallery_slugs()
  ta = _login("alice")
  assert (
      c.put(
          "/api/v1/me/profile",
          json={"profile_slug": "alice", "full_name": "Alice"},
          headers=_auth(ta),
      ).status_code
      == 200
  )
  assert c.post("/api/v1/me/publish", headers=_auth(ta)).status_code == 200
  assert c.get("/api/v1/public/u/alice/profile").status_code == 200
  assert "alice" in _gallery_slugs()


def test_admin_takedown():
  c = get_client()
  tb = _login("bob")
  # bob publishes first so he is visible, then admin takes him down
  assert (
      c.put(
          "/api/v1/me/profile",
          json={"profile_slug": "bob", "full_name": "Bob"},
          headers=_auth(tb),
      ).status_code
      == 200
  )
  assert c.post("/api/v1/me/publish", headers=_auth(tb)).status_code == 200
  assert c.get("/api/v1/public/u/bob/profile").status_code == 200
  assert "bob" in _gallery_slugs()
  adm = _login("admin", password="admin123")
  users = c.get("/api/v1/admin/users", headers=_auth(adm)).json()
  bob = [u for u in users if u["username"] == "bob"][0]
  r = c.patch(
      f"/api/v1/admin/users/{bob['id']}",
      json={"is_published": False},
      headers=_auth(adm),
  )
  assert r.status_code == 200
  assert c.get("/api/v1/public/u/bob/profile").status_code == 404
  assert "bob" not in _gallery_slugs()
  # alice unaffected
  assert c.get("/api/v1/public/u/alice/profile").status_code == 200

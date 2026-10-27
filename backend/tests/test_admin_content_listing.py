"""Admin harus bisa MEMBACA skill & experience lintas user sebelum mengeditnya."""

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
  return {"Authorization": f"Bearer {r.json()['access_token']}"}


def _register(username, email):
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


def test_admin_lists_skills_across_owners():
  _reset_db()
  _register("alice", "alice@x.com")
  alice = _login("alice")
  c = get_client()
  assert (
      c.post(
          "/api/v1/me/skills",
          json={"name": "Flutter", "category": "Frontend"},
          headers=alice,
      ).status_code
      == 201
  )

  admin = _login("admin", "admin123")
  r = c.get("/api/v1/admin/skills", headers=admin)
  assert r.status_code == 200, r.text
  assert [s["name"] for s in r.json()] == ["Flutter"]


def test_admin_lists_experiences_filtered_by_owner():
  _reset_db()
  _register("alice", "alice@x.com")
  _register("bob", "bob@x.com")
  c = get_client()
  alice = _login("alice")
  bob = _login("bob")
  body = {
      "role": "Engineer",
      "company": "Acme",
      "start_date": "2023-01-01",
  }
  c.post("/api/v1/me/experiences", json=body, headers=alice)
  c.post("/api/v1/me/experiences", json=body, headers=bob)

  admin = _login("admin", "admin123")
  users = c.get("/api/v1/admin/users", headers=admin).json()
  alice_id = next(u["id"] for u in users if u["username"] == "alice")

  r = c.get(
      f"/api/v1/admin/experiences?owner_id={alice_id}", headers=admin
  )
  assert r.status_code == 200, r.text
  assert len(r.json()) == 1
  assert r.json()[0]["company"] == "Acme"


def test_non_admin_cannot_list_admin_skills():
  _reset_db()
  _register("alice", "alice@x.com")
  alice = _login("alice")
  r = get_client().get("/api/v1/admin/skills", headers=alice)
  assert r.status_code == 403


def test_admin_can_create_skill_for_another_owner():
  _reset_db()
  _register("alice", "alice@x.com")
  c = get_client()
  admin = _login("admin", "admin123")
  alice_id = next(
      u["id"]
      for u in c.get("/api/v1/admin/users", headers=admin).json()
      if u["username"] == "alice"
  )

  r = c.post(
      "/api/v1/admin/skills",
      json={"name": "Go", "category": "Backend", "owner_id": alice_id},
      headers=admin,
  )
  assert r.status_code == 201, r.text

  alice = _login("alice")
  mine = c.get("/api/v1/me/skills", headers=alice).json()
  assert [s["name"] for s in mine] == ["Go"]


def test_admin_create_skill_defaults_to_self():
  _reset_db()
  c = get_client()
  admin = _login("admin", "admin123")
  r = c.post(
      "/api/v1/admin/skills",
      json={"name": "Rust", "category": "Backend"},
      headers=admin,
  )
  assert r.status_code == 201, r.text
  assert [s["name"] for s in c.get("/api/v1/me/skills", headers=admin).json()] == [
      "Rust"
  ]


def test_admin_create_for_unknown_owner_is_404():
  _reset_db()
  c = get_client()
  admin = _login("admin", "admin123")
  r = c.post(
      "/api/v1/admin/skills",
      json={"name": "Zig", "category": "Backend", "owner_id": 999999},
      headers=admin,
  )
  assert r.status_code == 404, r.text


def test_admin_create_project_for_unknown_owner_is_404():
  _reset_db()
  c = get_client()
  admin = _login("admin", "admin123")
  r = c.post(
      "/api/v1/admin/projects",
      json={
          "title": "Proyek Gamma",
          "slug": "proyek-gamma",
          "summary": "Ringkasan yang cukup panjang untuk validasi.",
          "owner_id": 999999,
      },
      headers=admin,
  )
  assert r.status_code == 404, r.text


def test_admin_create_experience_for_unknown_owner_is_404():
  _reset_db()
  c = get_client()
  admin = _login("admin", "admin123")
  r = c.post(
      "/api/v1/admin/experiences",
      json={
          "role": "Engineer",
          "company": "Acme",
          "start_date": "2023-01-01",
          "owner_id": 999999,
      },
      headers=admin,
  )
  assert r.status_code == 404, r.text


def test_same_skill_name_allowed_for_two_owners():
  _reset_db()
  _register("alice", "alice@x.com")
  c = get_client()
  admin = _login("admin", "admin123")
  alice_id = next(
      u["id"]
      for u in c.get("/api/v1/admin/users", headers=admin).json()
      if u["username"] == "alice"
  )

  # Constraint skill.UniqueConstraint hanya (owner_id, name): nama yang sama
  # milik dua owner berbeda harus boleh hidup berdampingan.
  first = c.post(
      "/api/v1/admin/skills",
      json={"name": "Go", "category": "Backend", "owner_id": alice_id},
      headers=admin,
  )
  assert first.status_code == 201, first.text

  second = c.post(
      "/api/v1/admin/skills",
      json={"name": "Go", "category": "Backend"},
      headers=admin,
  )
  assert second.status_code == 201, second.text


def test_admin_create_project_rejects_foreign_skill_ids():
  _reset_db()
  _register("alice", "alice@x.com")
  c = get_client()
  alice = _login("alice")
  skill = c.post(
      "/api/v1/me/skills",
      json={"name": "Flutter", "category": "Frontend"},
      headers=alice,
  )
  assert skill.status_code == 201, skill.text
  skill_id = skill.json()["id"]

  # Proyek milik admin (tanpa owner_id) tidak boleh attaches skill milik alice:
  # diam-diam hilang hanya menghasilkan konten portfolio yang salah.
  admin = _login("admin", "admin123")
  r = c.post(
      "/api/v1/admin/projects",
      json={
          "title": "Proyek Delta",
          "slug": "proyek-delta",
          "summary": "Ringkasan yang cukup panjang untuk validasi.",
          "skill_ids": [skill_id],
      },
      headers=admin,
  )
  assert r.status_code == 422, r.text


def test_admin_can_set_avatar_url_for_user():
  # Upload avatar admin hanya berguna kalau URL hasilnya bisa dipersistenkan;
  # tanpa `avatar_url` di AdminUserUpdate, `POST /admin/upload/avatar` tak punya
  # tujuan dan hasil upload hilang begitu tab ditutup.
  _reset_db()
  _register("alice", "alice@x.com")
  c = get_client()
  admin = _login("admin", "admin123")
  alice_id = next(
      u["id"]
      for u in c.get("/api/v1/admin/users", headers=admin).json()
      if u["username"] == "alice"
  )

  r = c.patch(
      f"/api/v1/admin/users/{alice_id}",
      json={"avatar_url": "/static/uploads/avatars/x.png"},
      headers=admin,
  )
  assert r.status_code == 200, r.text
  assert r.json()["avatar_url"] == "/static/uploads/avatars/x.png"


def test_admin_can_clear_avatar_url_for_user():
  # `admin_update_user` memakai `exclude_unset=True`: key yang DIKIRIM tetap
  # di-setattr, termasuk null. Kalau null ikut terbuang, avatar yang sudah
  # terpasang tidak bisa dihapus admin — dialog edit harus bisa mengosongkan.
  _reset_db()
  _register("alice", "alice@x.com")
  c = get_client()
  admin = _login("admin", "admin123")
  alice_id = next(
      u["id"]
      for u in c.get("/api/v1/admin/users", headers=admin).json()
      if u["username"] == "alice"
  )

  seeded = c.patch(
      f"/api/v1/admin/users/{alice_id}",
      json={"avatar_url": "/static/uploads/avatars/y.png"},
      headers=admin,
  )
  assert seeded.status_code == 200, seeded.text
  assert seeded.json()["avatar_url"] == "/static/uploads/avatars/y.png"

  cleared = c.patch(
      f"/api/v1/admin/users/{alice_id}",
      json={"avatar_url": None},
      headers=admin,
  )
  assert cleared.status_code == 200, cleared.text
  assert cleared.json()["avatar_url"] is None

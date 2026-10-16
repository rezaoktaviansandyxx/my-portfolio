from app.core.security import get_password_hash
from app.models.user import User
from tests.conftest import TestingSession, get_client


def setup_module():
  db = TestingSession()
  db.query(User).delete()
  db.add(
      User(
          username="admin",
          email="a@a.com",
          hashed_password=get_password_hash("pass123"),
          full_name="Admin",
          is_active=True,
          role="admin",
      )
  )
  db.commit()
  db.close()


def test_health():
  c = get_client()
  assert c.get("/health").status_code == 200


def test_invalid_project_status_rejected():
  c = get_client()
  r = c.post(
      "/api/v1/auth/login",
      data={"username": "admin", "password": "pass123"},
  )
  assert r.status_code == 200
  token = r.json()["access_token"]
  bad = {"title": "Ab", "slug": "Bad_Slug!!", "summary": "x", "status": "xxx"}
  res = c.post(
      "/api/v1/admin/projects",
      json=bad,
      headers={"Authorization": f"Bearer {token}"},
  )
  assert res.status_code == 422


def test_contact_validation():
  c = get_client()
  res = c.post(
      "/api/v1/public/u/testuser/contact",
      json={
          "sender_name": "x",
          "sender_email": "not-email",
          "subject": "hi",
          "content": "short",
      },
  )
  assert res.status_code == 422

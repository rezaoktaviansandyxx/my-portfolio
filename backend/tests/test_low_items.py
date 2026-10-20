"""Kumpulan perbaikan kelompok Low (backend).

- Non-admin harus 403 (bukan 401) di endpoint admin — 401 dipakai ulang
  membuat client tidak bisa membedakan "belum login" vs "tak berhak".
- Token dengan `sub` non-numerik harus 401, bukan ValueError → 500.
- `/auth/change-password` belum punya rate limit (bruteforce password lama).
- Contact form bisa mengirim ke profil yang TIDAK dipublish.
- Profil publik bocor field internal (id, role, is_active, is_published).
- Password >72 byte meledak di bcrypt → 500 (harus ditolak rapi).
- `media_url` query param tanpa validasi (panjang & format bebas).
- `delete_file` tidak punya guard traversal dan tak pernah dipanggil
  (file upload jadi orphan setelah project dihapus).
"""

import uuid

import pytest
from app.routers.deps import get_current_user
from fastapi.testclient import TestClient
from sqlalchemy import select

from app.core.config import settings
from app.core.security import create_access_token
from app.main import app
from app.models.project import Project
from app.models.user import User
from app.schemas.auth import ChangePasswordRequest
from tests.conftest import TestingSession

API = settings.API_V1_STR  # sudah berawal "/"  (mis. /api/v1)


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)


def _user(db, username, *, role="user", published=True, slug=None):
    # test.db adalah file sqlite persisten — suffix unik mencegah bentrok
    # dengan data run sebelumnya.
    suffix = uuid.uuid4().hex[:8]
    username = f"{username}{suffix}"
    u = User(
        username=username,
        email=f"{username}@example.com",
        hashed_password="x" * 60,
        full_name=username.title(),
        is_active=True,
        role=role,
        is_published=published,
        profile_slug=f"{slug}-{suffix}" if slug else f"u-{suffix}",
    )
    db.add(u)
    db.commit()
    db.refresh(u)
    return u


# --- deps: 401 vs 403 & sub non-numerik ----------------------------------


def test_non_admin_gets_403_not_401(client: TestClient):
    db = TestingSession()
    user = _user(db, "lowuser")
    token = create_access_token(subject=user.id)
    resp = client.get(
        f"{API}/admin/users",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 403, resp.text


def test_non_numeric_sub_returns_401_not_500():
    from app.routers.deps import get_current_user
    from fastapi import HTTPException

    token = create_access_token(subject="bukan-angka")
    db = TestingSession()
    with pytest.raises(HTTPException) as exc:
        get_current_user(db=db, token=token)
    assert exc.value.status_code == 401


# --- rate limit /change-password ------------------------------------------


def test_change_password_is_rate_limited():
    from app.core.rate_limit import limiter

    registered = list(limiter._route_limits)
    assert any("change_password" in key for key in registered), (
        f"change_password belum dilimit; terdaftar: {registered}"
    )


def test_change_password_bad_payload_not_500(client: TestClient):
    """Sanity: password lama salah → 400 rapi, pasti bukan crash 5xx."""
    db = TestingSession()
    user = _user(db, "pwlowlow", role="user", published=False)
    token = create_access_token(subject=user.id)
    resp = client.patch(
        f"{API}/auth/change-password",
        headers={"Authorization": f"Bearer {token}"},
        json={"current_password": "x", "new_password": "y"},
    )
    # Password lama tidak cocok → cukup 400, pasti bukan crash 5xx.
    assert resp.status_code < 500, resp.text


# --- contact ke profil unpublished -----------------------------------------


def test_contact_to_unpublished_profile_returns_404(client: TestClient):
    db = TestingSession()
    user = _user(db, "unpub", published=False, slug="unpub")
    resp = client.post(
        f"{API}/public/u/{user.profile_slug}/contact",
        json={
            "sender_name": "Pengirim",
            "sender_email": "pengirim@example.com",
            "subject": "Sapaan hangat",
            "content": "Halo, ini pesan dari pengunjung profil.",
        },
    )
    assert resp.status_code == 404, resp.text


# --- kebocoran field profil publik ------------------------------------------


def test_public_profile_hides_internal_fields(client: TestClient):
    db = TestingSession()
    user = _user(db, "pubuser", published=True, slug="pubuser")
    resp = client.get(f"{API}/public/u/{user.profile_slug}/profile")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    for leaked in ("id", "role", "is_active", "is_published", "email"):
        assert leaked not in body, f"field internal {leaked} bocor"
    assert body.get("full_name")


# --- password >72 byte ------------------------------------------------------


def test_register_password_over_72_bytes_rejected_neatly(client: TestClient):
    resp = client.post(
        f"{API}/auth/register",
        json={
            "username": "longpw",
            "email": "longpw@example.com",
            "password": "p" * 100,
            "full_name": "Long Password",
        },
    )
    assert resp.status_code == 422, resp.text


def test_change_password_schema_caps_at_72():
    with pytest.raises(Exception):
        ChangePasswordRequest(
            current_password="current-ok",
            new_password="n" * 100,
        )


# --- media_url tervalidasi ---------------------------------------------------


def _auth_as(user):
    app.dependency_overrides[get_current_user] = lambda: user


def _project_for(db, user):
    p = Project(owner_id=user.id, title="Proyek", slug="proyek", summary="s")
    db.add(p)
    db.commit()
    db.refresh(p)
    return p


def test_me_media_url_too_long_rejected(client: TestClient):
    db = TestingSession()
    user = _user(db, "medialow")
    project = _project_for(db, user)
    _auth_as(user)
    try:
        resp = client.post(
            f"{API}/me/projects/{project.id}/media",
            params={"media_url": "a" * 300},
        )
        assert resp.status_code == 422, resp.text
    finally:
        app.dependency_overrides.pop(get_current_user, None)


def test_me_media_url_bad_scheme_rejected(client: TestClient):
    db = TestingSession()
    user = _user(db, "medialow2")
    project = _project_for(db, user)
    _auth_as(user)
    try:
        resp = client.post(
            f"{API}/me/projects/{project.id}/media",
            params={"media_url": "javascript:alert(1)"},
        )
        assert resp.status_code == 422, resp.text
    finally:
        app.dependency_overrides.pop(get_current_user, None)


def test_me_media_url_valid_static_accepts(client: TestClient):
    db = TestingSession()
    user = _user(db, "mediagood")
    project = _project_for(db, user)
    _auth_as(user)
    try:
        resp = client.post(
            f"{API}/me/projects/{project.id}/media",
            params={"media_url": "/static/uploads/media/abc.png"},
        )
        assert resp.status_code == 201, resp.text
    finally:
        app.dependency_overrides.pop(get_current_user, None)


# --- delete_file traversal guard & cleanup -----------------------------------


def test_delete_file_blocks_traversal(tmp_path, monkeypatch):
    from app.services.storage import LocalStorageService

    base = tmp_path / "uploads"
    base.mkdir()
    victim = tmp_path / "secret.txt"
    victim.write_text("secret")
    monkeypatch.chdir(base)  # impl lama resolve path vs CWD, bukan base dir

    svc = LocalStorageService(base_dir=str(base))
    assert svc.delete_file("../secret.txt") is False
    assert victim.exists(), "delete_file menghapus file DI LUAR base dir!"


def test_remove_project_files_helper():
    from app.services import storage as storage_mod

    removed: list[str] = []

    class FakeService:
        def delete_file(self, relative_path: str) -> bool:
            removed.append(relative_path)
            return True

    old = storage_mod.storage_service
    storage_mod.storage_service = FakeService()
    try:
        storage_mod.remove_project_files(
            [
                "/static/uploads/covers/a.png",
                "/static/uploads/media/b.png",
                "https://cdn.example.com/remote.png",  # remote: diabaikan
                None,  # url kosong: diabaikan tanpa error
            ]
        )
    finally:
        storage_mod.storage_service = old

    assert removed == [
        "static/uploads/covers/a.png",
        "static/uploads/media/b.png",
    ]

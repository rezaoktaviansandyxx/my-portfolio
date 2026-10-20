"""Konversi IntegrityError race-condition -> 409 (temuan audit Medium #14).

Router admin/auth memeriksa uniqueness lalu INSERT tanpa try/except; dua
request serentak dapat lolos cek dan menabrak constraint DB -> 500. Aturan
yang benar (pattern di me.py): commit dibungkus try/except IntegrityError
yang mengembalikan 409.
"""

from unittest.mock import MagicMock

import pytest
from fastapi import HTTPException, Request
from sqlalchemy.exc import IntegrityError

from app.models.user import User
from app.routers import admin as admin_router
from app.routers import auth as auth_router
from app.schemas.auth import RegisterRequest
from app.schemas.project import ProjectCreate


def _db_with_conflict() -> MagicMock:
    db = MagicMock()
    # Semua query (.query(X).filter(...).first()) harus "tidak ada duplikat".
    db.query.return_value.filter.return_value.first.return_value = None
    db.commit.side_effect = IntegrityError("dup", "params", Exception("unique"))
    db.refresh.side_effect = AssertionError("refresh tidak boleh dipanggil")
    return db


def make_register_payload():
    return RegisterRequest(
        username="andini",
        email="andini@example.com",
        password="password-yang-aman-banget",
        full_name="Andini Pr",
    )


def _dummy_request(path: str = "/api/v1/") -> Request:
    """Slowapi butuh instance.Request nyata walau test lakukan direct call."""
    return Request(
        {
            "type": "http",
            "path": path,
            "headers": [],
            "client": ("testclient", 1),
        }
    )


def test_register_conflict_returns_409_not_500():
    db = _db_with_conflict()
    with pytest.raises(HTTPException) as exc:
        auth_router.register(
            payload=make_register_payload(),
            db=db,
            request=_dummy_request(),
        )
    assert exc.value.status_code == 409
    db.rollback.assert_called_once()


def test_admin_create_project_conflict_returns_409_not_500():
    db = _db_with_conflict()
    admin = User(id=1, username="admin", role="admin", is_active=True)
    payload = ProjectCreate(
        title="Proyek A",
        slug="proyek-a",
        summary="Ringkasan proyek A yang cukup panjang.",
    )
    with pytest.raises(HTTPException) as exc:
        admin_router.create_project(payload=payload, db=db, current=admin)
    assert exc.value.status_code == 409
    db.rollback.assert_called_once()

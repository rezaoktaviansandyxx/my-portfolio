"""Kredensial seed tidak boleh ter-commit (temuan audit Medium #7).

seed_admin/seed_demo memuat password default 'changeme123' yang diketahui
publik. Password wajib datang dari env; kalau tidak ada, script harus
membangkitkan password acak (seed_admin) atau menolak jalan dengan pesan
jelas (seed_demo).
"""

from pathlib import Path

import pytest
from sqlalchemy import select

import app.core.security as security
from tests.conftest import TestingSession

BACKEND = Path(__file__).resolve().parents[1]


@pytest.fixture
def testing_session():
    db = TestingSession()
    yield db
    db.close()


def load_module(name: str) -> dict:
    """Muat script seed tanpa mengeksekusi blok __main__-nya."""
    src = (BACKEND / name).read_text(encoding="utf-8")
    ns = {"__name__": f"audit_{name}"}  # bukan '__main__' → main() tidak jalan
    exec(compile(src, str(BACKEND / name), "exec"), ns)
    return ns


def test_no_committed_default_password():
    """Password demo 'changeme123' tidak boleh ada di source seed lagi."""
    for name in ("seed_admin.py", "seed_demo.py"):
        src = (BACKEND / name).read_text(encoding="utf-8")
        assert "changeme123" not in src, f"{name} masih menyimpan password bawaan"


def test_ensure_admin_hashes_password_and_creates_admin(testing_session):
    """ensure_admin membuat user admin dengan hash password, bukan plaintext."""
    mod = load_module("seed_admin.py")
    ensure_admin = mod["ensure_admin"]

    ensure_admin(
        testing_session,
        username="seedadmin",
        email="seedadmin@example.com",
        password="rahasia-seed-yang-aman",
        slug="seedadmin",
    )
    testing_session.commit()

    user = testing_session.execute(
        select(mod["User"]).where(mod["User"].username == "seedadmin")
    ).scalar_one()
    assert user.role == "admin"
    assert user.hashed_password != "rahasia-seed-yang-aman"
    assert security.verify_password(
        "rahasia-seed-yang-aman", user.hashed_password
    )


def test_ensure_admin_is_idempotent(testing_session):
    mod = load_module("seed_admin.py")
    ensure_admin = mod["ensure_admin"]

    kwargs = dict(
        username="seedadmin2",
        email="seedadmin2@example.com",
        password="pw-2-cukup-panjang",
        slug="seedadmin2",
    )
    ensure_admin(testing_session, **kwargs)
    ensure_admin(testing_session, **kwargs)
    testing_session.commit()

    rows = testing_session.execute(
        select(mod["User"]).where(mod["User"].username == "seedadmin2")
    ).scalars().all()
    assert len(rows) == 1


def test_demo_credentials_require_env(monkeypatch):
    """seed_demo menolak jalan (SystemExit) tanpa ADMIN_USERNAME/ADMIN_PASSWORD."""
    monkeypatch.delenv("ADMIN_USERNAME", raising=False)
    monkeypatch.delenv("ADMIN_PASSWORD", raising=False)
    mod = load_module("seed_demo.py")
    with pytest.raises(SystemExit):
        mod["_demo_credentials"]()


def test_demo_credentials_from_env(monkeypatch):
    monkeypatch.setenv("ADMIN_USERNAME", "budi")
    monkeypatch.setenv("ADMIN_PASSWORD", "s3cret-demo")
    mod = load_module("seed_demo.py")
    assert mod["_demo_credentials"]() == ("budi", "s3cret-demo")


class _FailingFactory:
    def __call__(self):
        raise AssertionError("main() jalan tanpa db seharusnya tidak terjadi")


def test_generated_password_is_strong():
    """Password hasil generate acak minimal 16 karakter dan beragam."""
    mod = load_module("seed_admin.py")
    gen = mod["_generate_password"]
    pw1, pw2 = gen(), gen()
    assert len(pw1) >= 16 and len(pw2) >= 16 and pw1 != pw2

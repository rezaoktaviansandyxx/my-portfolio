"""Backfill admin di migrasi 002 (temuan audit High #3).

Sebelumnya migrasi mempromosikan *user pertama* (ORDER BY id LIMIT 1) jadi
admin — user acak yang kebetulan paling tua. Uji ini memastikan pemilihan
admin mengikuti username admin yang dibuat seed_admin.py.
"""

import importlib.util
from pathlib import Path

import pytest
import sqlalchemy as sa

_MIGRATION = (
    Path(__file__).resolve().parents[1]
    / "alembic"
    / "versions"
    / "002_multitenant.py"
)


def _load_migration():
    spec = importlib.util.spec_from_file_location("migration_002", _MIGRATION)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


@pytest.fixture
def engine():
    eng = sa.create_engine("sqlite:///:memory:")
    with eng.begin() as conn:
        conn.execute(
            sa.text(
                "CREATE TABLE users ("
                "id INTEGER PRIMARY KEY, "
                "username VARCHAR(50), "
                "email VARCHAR(100))"
            )
        )
    return eng


def _insert(conn, user_id, username):
    conn.execute(
        sa.text(
            "INSERT INTO users (id, username, email) "
            "VALUES (:id, :u, :u || '@example.com')"
        ).bindparams(id=user_id, u=username)
    )


def test_canonical_admin_username_wins_even_if_not_first(engine):
    """User 'admin' id=2 dipilih, meski user 'andini' id=1 lebih tua."""
    migration = _load_migration()
    with engine.begin() as conn:
        _insert(conn, 1, "andini")
        _insert(conn, 2, "admin")
        admin_id = migration._select_admin_id(conn)
    assert admin_id == 2


def test_admin_username_is_case_insensitive(engine):
    migration = _load_migration()
    with engine.begin() as conn:
        _insert(conn, 1, "AndIn")
        _insert(conn, 2, "regularuser")
        admin_id = migration._select_admin_id(conn)
    assert admin_id == 1


def test_custom_admin_username_override(engine):
    migration = _load_migration()
    with engine.begin() as conn:
        _insert(conn, 1, "budi")
        _insert(conn, 2, "admin")
        admin_id = migration._select_admin_id(conn, admin_username="budi")
    assert admin_id == 1


def test_falls_back_to_first_user_when_no_admin_username(engine):
    """Tanpa user 'admin', fallback user pertama agar upgrade tetap jalan."""
    migration = _load_migration()
    with engine.begin() as conn:
        _insert(conn, 1, "andini")
        _insert(conn, 2, "budi")
        admin_id = migration._select_admin_id(conn)
    assert admin_id == 1


def test_empty_table_returns_none(engine):
    migration = _load_migration()
    with engine.begin() as conn:
        admin_id = migration._select_admin_id(conn)
    assert admin_id is None

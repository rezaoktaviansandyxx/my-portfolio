"""Konsistensi multitenant di level model (temuan audit Medium #13).

`skills.name` masih unique global dari skema 001, sehingga dua user tidak
bisa punya skill bernama sama. Model harus unik per pemilik, bukan global.
Sesuatu harus per-owner juga: slug project sudah per-owner (uq_project_owner_slug).
"""

import pytest
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError

from app.core.database import Base
from app.models.project import Project
from app.models.skill import Skill
from app.models.user import User


@pytest.fixture
def session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine, autoflush=False)
    db = Session()
    yield db
    db.close()
    engine.dispose()


def _user(session, username: str, slug: str | None = None) -> User:
    u = User(
        username=username,
        email=f"{username}@example.com",
        hashed_password="x" * 60,
        full_name=username.title(),
        is_active=True,
        role="user",
        profile_slug=slug,
    )
    session.add(u)
    return u


def test_two_users_can_have_same_skill_name(session):
    session.add(_user(session, "andini"))
    session.add(_user(session, "budi"))
    session.flush()
    session.add(Skill(name="Flutter", category="Frontend", owner_id=1))
    session.add(Skill(name="Flutter", category="Frontend", owner_id=2))
    session.commit()


def test_same_user_duplicate_skill_name_still_rejected(session):
    session.add(_user(session, "andini"))
    session.add(
        Skill(name="Flutter", category="Frontend", owner_id=1)
    )
    session.add(
        Skill(name="Flutter", category="Frontend", owner_id=1)
    )
    with pytest.raises(IntegrityError):
        session.commit()
    session.rollback()


def test_project_slug_unique_per_owner_not_global(session):
    session.add(_user(session, "andini"))
    session.add(_user(session, "budi"))
    session.flush()
    session.add(
        Project(owner_id=1, title="P", slug="portofolio-uin", summary="s")
    )
    session.add(
        Project(owner_id=2, title="Q", slug="portofolio-uin", summary="s")
    )
    session.commit()


def test_project_slug_duplicate_same_owner_rejected(session):
    session.add(_user(session, "andini"))
    session.flush()
    session.add(
        Project(owner_id=1, title="P", slug="portofolio-uin", summary="s")
    )
    session.add(
        Project(owner_id=1, title="Q", slug="portofolio-uin", summary="s")
    )
    with pytest.raises(IntegrityError):
        session.commit()
    session.rollback()

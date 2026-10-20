import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base, get_db
from app.core.rate_limit import limiter
from app.main import app

engine = create_engine(
    "sqlite:///./test.db", connect_args={"check_same_thread": False}
)
TestingSession = sessionmaker(
    bind=engine, autocommit=False, autoflush=False
)
Base.metadata.create_all(bind=engine)


def override_get_db():
  db = TestingSession()
  try:
    yield db
  finally:
    db.close()


app.dependency_overrides[get_db] = override_get_db


@pytest.fixture(autouse=True)
def _reset_rate_limiter():
  """Isolasi counter slowapi antar test (register/login limits per-IP)."""
  limiter.reset()
  yield
  limiter.reset()


def get_client():
  return TestClient(app)

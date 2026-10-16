from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base, get_db
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


def get_client():
  return TestClient(app)

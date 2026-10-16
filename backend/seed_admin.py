import os

from app.core.database import SessionLocal
from app.core.security import get_password_hash
from app.models.user import User

db = SessionLocal()
username = os.getenv("ADMIN_USERNAME", "admin")
email = os.getenv("ADMIN_EMAIL", "admin@test.com")
password = os.getenv("ADMIN_PASSWORD", "changeme123")
existing = (
    db.query(User)
    .filter((User.username == username) | (User.email == email))
    .first()
)
if not existing:
  db.add(
      User(
          username=username,
          email=email,
          hashed_password=get_password_hash(password),
          full_name="Admin",
          is_active=True,
          role="admin",
      )
  )
  db.commit()
  print("seeded")
else:
  print("exists")
db.close()

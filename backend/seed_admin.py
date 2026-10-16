import os

from app.core.database import SessionLocal
from app.core.security import get_password_hash
from app.models.user import User

db = SessionLocal()
username = os.getenv("ADMIN_USERNAME", "admin")
email = os.getenv("ADMIN_EMAIL", "admin@test.com")
password = os.getenv("ADMIN_PASSWORD", "changeme123")
slug = os.getenv("ADMIN_SLUG", "admin")
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
            profile_slug=slug,
            is_published=True,
        )
    )
    db.commit()
    print("seeded")
else:
    # Perbaiki data lama yang belum punya slug/publish (penyebab 404 publik)
    changed = False
    if not existing.profile_slug:
        existing.profile_slug = slug
        changed = True
    if not existing.is_published:
        existing.is_published = True
        changed = True
    if not existing.is_active:
        existing.is_active = True
        changed = True
    if changed:
        db.commit()
        print("fixed existing admin")
    else:
        print("exists")
db.close()

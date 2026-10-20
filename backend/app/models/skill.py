from app.core.database import Base
from app.models.project import project_skills
from sqlalchemy import Column, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import relationship


class Skill(Base):
  __tablename__ = "skills"
  # nama skill unik PER PEMILIK (multitenant), bukan global — dua user
  # boleh sama-sama punya skill "Flutter" (audit Medium: constraint global
  # sisa skema 001 harus turun).
  __table_args__ = (
      UniqueConstraint("owner_id", "name", name="uq_skills_owner_name"),
  )

  id = Column(Integer, primary_key=True, index=True)
  owner_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
  name = Column(String(60), nullable=False)
  category = Column(
      String(50), nullable=False, index=True
  )  # Frontend, Backend, Tools, Database
  proficiency_level = Column(Integer, nullable=True)  # 1-100 opsional
  icon_url = Column(String(255), nullable=True)
  display_order = Column(Integer, default=0)

  projects = relationship(
      "Project", secondary=project_skills, back_populates="skills"
  )
from app.core.database import Base
from app.models.project import project_skills
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship


class Skill(Base):
  __tablename__ = "skills"

  id = Column(Integer, primary_key=True, index=True)
  name = Column(String(60), unique=True, nullable=False)
  category = Column(
      String(50), nullable=False, index=True
  )  # Frontend, Backend, Tools, Database
  proficiency_level = Column(Integer, nullable=True)  # 1-100 opsional
  icon_url = Column(String(255), nullable=True)
  display_order = Column(Integer, default=0)

  projects = relationship(
      "Project", secondary=project_skills, back_populates="skills"
  )
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
  PROJECT_NAME: str = "Portofolio API"
  API_V1_STR: str = "/api/v1"
  SECRET_KEY: str = "temporary-secret-key"
  ALGORITHM: str = "HS256"
  ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440
  DATABASE_URL: str = (
      "postgresql+psycopg2://postgres:root@localhost:5432/portofolio_db"
  )
  UPLOAD_DIR: str = "static/uploads"
  BACKEND_CORS_ORIGINS: list[str] = [
      "http://localhost:3000",
      "http://localhost:8080",
  ]
  RATE_LIMIT_CONTACT: str = "5/minute"

  model_config = SettingsConfigDict(env_file=".env", case_sensitive=True)


settings = Settings()
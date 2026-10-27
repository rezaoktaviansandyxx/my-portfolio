from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Secret yang diketahui publik (pernah di-commit / fallback kode lama) dan
# placeholder .env.example — tidak boleh dipakai menandatangani JWT.
WEAK_SECRET_VALUES = frozenset(
    {
        "temporary-secret-key",
        "website-portfolio-api-secret-key",
        # Placeholder wajib di .env.example — dipaksa diganti sebelum jalan.
        "GANTI-DENGAN-SECRET-ACAK-64-KARAKTER-openssl-rand-hex-32",
    }
)
MIN_SECRET_KEY_LENGTH = 32


class Settings(BaseSettings):
  PROJECT_NAME: str = "Portfolio API"
  API_V1_STR: str = "/api/v1"
  SECRET_KEY: str = "temporary-secret-key"
  ALGORITHM: str = "HS256"
  ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440
  # Username admin kanonik (dibuat seed_admin.py); dipakai migrasi 002 untuk
  # memilih user yang di-backfill jadi admin, bukan user pertama yang acak.
  ADMIN_USERNAME: str = "admin"
  DATABASE_URL: str = (
      "postgresql+psycopg2://postgres:root@localhost:5432/portfolio_db"
  )
  UPLOAD_DIR: str = "static/uploads"
  BACKEND_CORS_ORIGINS: list[str] = [
      "http://localhost:3000",
      "http://localhost:8080",
      "http://localhost:5000",
      "http://localhost:8000",
      "http://localhost:63314",
      "http://localhost:63316",
  ]
  RATE_LIMIT_CONTACT: str = "5/minute"
  # Batas untuk endpoint baca publik (anti scraping); satu halaman profil
  # publik memuat ~5 request, 60/menit cukup longgar untuk manusia.
  RATE_LIMIT_PUBLIC_READ: str = "60/minute"

  @field_validator("SECRET_KEY")
  @classmethod
  def _reject_weak_secret(cls, value: str) -> str:
    stripped = value.strip()
    if stripped in WEAK_SECRET_VALUES:
      raise ValueError(
          "SECRET_KEY memakai nilai default/placeholder yang diketahui publik. "
          "Buat kunci acak, mis. `openssl rand -hex 32`, lalu isi .env."
      )
    if len(stripped) < MIN_SECRET_KEY_LENGTH:
      raise ValueError(
          "SECRET_KEY minimal 32 karakter agar token tidak mudah "
          "di-brute force. Buat kunci acak dengan `openssl rand -hex 32`."
      )
    return stripped

  model_config = SettingsConfigDict(env_file=".env", case_sensitive=True)


settings = Settings()

import uuid
from pathlib import Path
from app.core.config import settings
from fastapi import HTTPException, UploadFile, status

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
ALLOWED_DOC_TYPES = {"application/pdf"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5 MB


class LocalStorageService:

  def __init__(self, base_dir: str = settings.UPLOAD_DIR):
    self.base_dir = Path(base_dir)

  async def save_file(
      self, file: UploadFile, subfolder: str, is_document: bool = False
  ) -> str:
    allowed = ALLOWED_DOC_TYPES if is_document else ALLOWED_IMAGE_TYPES
    if file.content_type not in allowed:
      raise HTTPException(
          status_code=status.HTTP_400_BAD_REQUEST,
          detail=f"Tipe file tidak didukung: {file.content_type}",
      )

    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE:
      raise HTTPException(
          status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
          detail="Ukuran file melebihi batas 5MB",
      )

    target_dir = self.base_dir / subfolder
    target_dir.mkdir(parents=True, exist_ok=True)

    ext = Path(file.filename or "").suffix.lower()
    filename = f"{uuid.uuid4().hex}{ext}"
    dest_path = target_dir / filename

    with open(dest_path, "wb") as buffer:
      buffer.write(contents)

    return f"/{settings.UPLOAD_DIR}/{subfolder}/{filename}".replace("//", "/")

  def delete_file(self, relative_path: str) -> bool:
    clean_path = Path(relative_path.lstrip("/"))
    if clean_path.exists() and clean_path.is_file():
      clean_path.unlink()
      return True
    return False


storage_service = LocalStorageService()
import io
import uuid
from pathlib import Path
from PIL import Image
from app.core.config import settings
from fastapi import HTTPException, UploadFile, status

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
ALLOWED_DOC_TYPES = {"application/pdf"}
# Ekstensi diizinkan — extension diambil dari filename yang dikontrol user,
# jadi harus allowlist, bukan dipercaya mentah.
ALLOWED_IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp"}
ALLOWED_DOC_EXTS = {".pdf"}
MAGIC_BYTES = {
    b"\xff\xd8\xff": "JPEG",
    b"\x89PNG\r\n\x1a\n": "PNG",
    b"RIFF": "WEBP",  # validasi lanjut pakai Pillow (format WEBP)
    b"%PDF-": "PDF",
}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5 MB


class LocalStorageService:

  def __init__(self, base_dir: str = settings.UPLOAD_DIR):
    self.base_dir = Path(base_dir)

  async def save_file(
      self, file: UploadFile, subfolder: str, is_document: bool = False
  ) -> str:
    if ".." in subfolder or subfolder.startswith("/"):
      raise HTTPException(
          status_code=status.HTTP_400_BAD_REQUEST,
          detail="Subfolder tidak valid",
      )
    allowed_types = ALLOWED_DOC_TYPES if is_document else ALLOWED_IMAGE_TYPES
    if file.content_type not in allowed_types:
      raise HTTPException(
          status_code=status.HTTP_400_BAD_REQUEST,
          detail=f"Tipe file tidak didukung: {file.content_type}",
      )

    ext = Path(file.filename or "").suffix.lower()
    allowed_exts = ALLOWED_DOC_EXTS if is_document else ALLOWED_IMAGE_EXTS
    if ext not in allowed_exts:
      raise HTTPException(
          status_code=status.HTTP_400_BAD_REQUEST,
          detail=f"Ekstensi file tidak diizinkan: {ext or '(tanpa ekstensi)'}",
      )

    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE:
      raise HTTPException(
          status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
          detail="Ukuran file melebihi batas 5MB",
      )

    # Content-Type bisa dipalsukan client — verifikasi isi file, bukan
    # header. Mencegah HTML/SVG diselundupkan sebagai gambar (stored XSS).
    self._verify_content(contents, is_document)

    target_dir = self.base_dir / subfolder
    target_dir.mkdir(parents=True, exist_ok=True)

    filename = f"{uuid.uuid4().hex}{ext}"
    dest_path = target_dir / filename

    with open(dest_path, "wb") as buffer:
      buffer.write(contents)

    return f"/{settings.UPLOAD_DIR}/{subfolder}/{filename}".replace("//", "/")

  @staticmethod
  def _verify_content(contents: bytes, is_document: bool) -> None:
    def _bad(detail):
      return HTTPException(
          status_code=status.HTTP_400_BAD_REQUEST,
          detail=detail,
      )

    matched = next(
        (fmt for magic, fmt in MAGIC_BYTES.items() if contents.startswith(magic)),
        None,
    )
    expected = "PDF" if is_document else None
    if is_document:
      if matched != "PDF":
        raise _bad("Isi file bukan PDF valid")
      return

    # Gambar: verifikasi dekodabilitas penuh via Pillow (mencegah isi
    # acak/palsu lolos cek magic header saja).
    try:
      with Image.open(io.BytesIO(contents)) as img:
        img.verify()
        if matched == "WEBP" and img.format != "WEBP":
          raise _bad("Isi file bukan gambar WEBP valid")
    except HTTPException:
      raise
    except Exception:
      raise _bad("Isi file bukan gambar yang valid")

  def delete_file(self, relative_path: str) -> bool:
    clean_path = Path(relative_path.lstrip("/"))
    if clean_path.exists() and clean_path.is_file():
      clean_path.unlink()
      return True
    return False


storage_service = LocalStorageService()
"""Validasi konten upload (temuan audit High #4).

Content-Type dari client bisa dipalsukan, jadi `save_file` wajib memverifikasi
isi file (magic bytes) dan ekstensi, bukan sekadar melihat content_type.
Vektor XSS: file .html/.svg diselundupkan dengan Content-Type image/png lalu
disajikan StaticFiles sebagai text/html di origin situs.
"""

import asyncio
import io

import pytest
from fastapi import HTTPException, UploadFile
from PIL import Image
from starlette.datastructures import Headers

from app.services.storage import LocalStorageService


def _upload(name: str, data: bytes, content_type: str = "application/octet-stream"):
    return UploadFile(
        filename=name,
        file=io.BytesIO(data),
        size=len(data),
        headers=Headers({"content-type": content_type}),
    )


def _png_bytes() -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (1, 1), "red").save(buf, format="PNG")
    return buf.getvalue()


@pytest.fixture
def service(tmp_path):
    return LocalStorageService(base_dir=str(tmp_path / "uploads"))


def _save(service, upload, subfolder="covers", is_document=False):
    return asyncio.run(
        service.save_file(upload, subfolder, is_document=is_document)
    )


def test_png_named_as_html_is_rejected(service):
    """HTML dengan Content-Type image/png ditolak — vektor stored XSS."""
    with pytest.raises(HTTPException) as exc:
        _save(
            service,
            _upload("evil.html", b"<script>alert(1)</script>", "image/png"),
        )
    assert exc.value.status_code == 400


def test_svg_content_with_image_meta_is_rejected(service):
    """SVG (bisa membawa skrip) bukan format gambar raster yang diizinkan."""
    svg = b'<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script></svg>'
    with pytest.raises(HTTPException):
        _save(service, _upload("stealer.svg", svg, "image/svg+xml"))


def test_wrong_extension_is_rejected_even_if_content_is_image(service):
    """Ekstensi tanpa allowlist (.exe) ditolak meski isinya PNG valid."""
    with pytest.raises(HTTPException) as exc:
        _save(service, _upload("payload.exe", _png_bytes(), "image/png"))
    assert exc.value.status_code == 400


def test_valid_png_with_spoofed_headers_is_saved(service):
    """PNG asli lolos meski metadata client dibuat ambiguous."""
    url = _save(service, _upload("cover.png", _png_bytes(), "image/png"))
    assert url.endswith(".png") and "/covers/" in url


def test_non_image_content_with_image_extension_is_rejected(service):
    """Isi yang bukan gambar (HTML menyamar PNG-signature) tetap ditolak."""
    with pytest.raises(HTTPException):
        _save(service, _upload("x.png", b"\x89PNG\r\n\x1a\n<html>fake!</html>"))


def test_valid_pdf_document_is_saved(service):
    pdf = b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n"
    url = _save(
        service,
        _upload("resume.pdf", pdf, "application/pdf"),
        subfolder="docs",
        is_document=True,
    )
    assert url.endswith(".pdf")


def test_fake_pdf_is_rejected(service):
    """PDF palsu (bukan magic bytes %PDF-) ditolak."""
    with pytest.raises(HTTPException):
        _save(service, _upload("evil.pdf", b"MZ\x90\x00<script>"), subfolder="docs", is_document=True)


def test_image_in_doc_folder_is_rejected(service):
    """Folder dokumen hanya menerima PDF; PNG ditolak di sana."""
    with pytest.raises(HTTPException):
        _save(service, _upload("a.png", _png_bytes(), "image/png"), is_document=True)


def test_missing_filename_is_rejected(service):
    upload = _upload("", _png_bytes(), "image/png")
    upload.filename = None
    with pytest.raises(HTTPException):
        _save(service, upload)

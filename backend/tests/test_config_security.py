"""Guard keamanan SECRET_KEY (temuan audit High #1).

Settings wajib menolak secret default/lemma saat dibangun, agar deployment
baru yang lupa isi .env tidak jalan dengan kunci JWT bawaan yang diketahui
publik.
"""

import pytest
from pydantic import ValidationError

from app.core.config import WEAK_SECRET_VALUES, Settings

STRONG_SECRET = "0fd42ee94b3cd0e94f1a01c52c1e2b0e83d1f57c9b93e2a04ddbe6a5ca7b41e2"


def test_default_dev_secret_rejected():
    """Secret fallback lama ('temporary-secret-key') wajib ditolak."""
    with pytest.raises(ValidationError):
        Settings(SECRET_KEY="temporary-secret-key")


def test_committed_example_secret_rejected():
    """Secret yang pernah di-commit di .env.example wajib ditolak."""
    with pytest.raises(ValidationError):
        Settings(SECRET_KEY="website-portfolio-api-secret-key")


def test_short_secret_rejected():
    """Secret di bawah 32 karakter wajib ditolak (mudah di-brute force)."""
    with pytest.raises(ValidationError):
        Settings(SECRET_KEY="terlalupendek")


def test_placeholder_from_example_rejected():
    """Placeholder, bukan secret asli, yaitu satu-satunya isi .env.example."""
    placeholder = "GANTI-DENGAN-SECRET-ACAK-64-KARAKTER-openssl-rand-hex-32"
    assert placeholder in WEAK_SECRET_VALUES
    with pytest.raises(ValidationError):
        Settings(SECRET_KEY=placeholder)


def test_strong_secret_accepted():
    settings = Settings(SECRET_KEY=STRONG_SECRET)
    assert settings.SECRET_KEY == STRONG_SECRET


def test_env_example_does_not_ship_a_working_secret():
    """File .env.example hanya boleh berisi placeholder yang diblokir."""
    from pathlib import Path

    env_example = Path(__file__).resolve().parents[1] / ".env.example"
    content = env_example.read_text(encoding="utf-8")
    value = next(
        line.split("=", 1)[1].strip().strip('"')
        for line in content.splitlines()
        if line.startswith("SECRET_KEY=")
    )
    assert value in WEAK_SECRET_VALUES

"""Rate limiter sadar proxy + throttle publik (temuan audit Medium #9).

`get_remote_address` memakai request.client.host — di belakang reverse proxy
itu IP proxy, jadi semua user berbagi satu kunci. Kunci sekarang harus
membaca X-Forwarded-For. Ditambah: endpoint galeri publik harus punya limit
agar scraping liar tidak menghimpit DB.
"""

from app.core.config import settings
from app.core.rate_limit import get_client_ip, limiter
from fastapi import Request


def _request(headers: dict[str, str], client_ip: str = "10.0.0.9") -> Request:
    scope = {
        "type": "http",
        "headers": [
            (key.lower().encode(), value.encode()) for key, value in headers.items()
        ],
        "client": (client_ip, 12345),
    }
    return Request(scope)


def test_forwarded_for_first_hop_wins():
    req = _request({"X-Forwarded-For": "203.0.113.7, 10.0.0.1, 10.0.0.2"})
    assert get_client_ip(req) == "203.0.113.7"


def test_forwarded_for_strips_spaces():
    req = _request({"X-Forwarded-For": " 203.0.113.8 , 10.0.0.1"})
    assert get_client_ip(req) == "203.0.113.8"


def test_falls_back_to_client_host_without_proxy():
    req = _request({})
    assert get_client_ip(req) == "10.0.0.9"


def test_empty_forwarded_for_falls_back():
    req = _request({"X-Forwarded-For": " , "})
    assert get_client_ip(req) == "10.0.0.9"


def test_public_read_limit_configured():
    assert settings.RATE_LIMIT_PUBLIC_READ.endswith("/minute")


def test_public_endpoints_are_rate_limited():
    """Galeri & halaman profil publik wajib terdaftar di limiter."""
    route_limits = limiter._route_limits
    assert any("gallery_projects" in key for key in route_limits), (
        f"galeri tidak dilimit; terdaftar: {list(route_limits)}"
    )
    assert any("u_profile" in key for key in route_limits)
    assert any("u_projects" in key for key in route_limits)


def test_auth_and_contact_limits_still_registered():
    route_limits = limiter._route_limits
    assert any("register" in key for key in route_limits)
    assert any("login" in key for key in route_limits)
    assert any("u_contact" in key for key in route_limits)

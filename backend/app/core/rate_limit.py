from slowapi import Limiter
from fastapi import Request

# Key sadar reverse proxy: X-Forwarded-For diisi oleh proxy (Nginx/Cloudflare).
# Tanpa ini semua user tampak satu IP (IP proxy) → limit saling mengunci.
def get_client_ip(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        first = forwarded.split(",")[0].strip()
        if first:
            return first
    client = request.client
    return client.host if client else ""


limiter = Limiter(key_func=get_client_ip)

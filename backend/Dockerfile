FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Jalan sebagai non-root: pudar risiko kalau ada RCE/di-mask image.
RUN useradd --create-home appuser \
    && mkdir -p /app/static/uploads \
    && chown -R appuser:appuser /app
USER appuser

# Migrasi dijalankan sebelum server naik supaya deploy pertama tidak 500
# (compose menunggu db healthy via condition: service_healthy).
CMD ["sh", "-c", "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8000"]

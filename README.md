# FolioSpace — Portofolio Interaktif Multitenant

Aplikasi portofolio pribadi berbasis multitenant: setiap pengguna punya dashboard
untuk mengelola profil, proyek, skill, pengalaman, dan pesan; halaman publiknya
bisa diakses lewat slug (`/u/:slug`). Dibangun dengan **FastAPI (backend)** +
**Flutter Web (frontend)**, tema dark glassmorphism.

## Struktur

```
backend/    FastAPI + SQLAlchemy + Alembic + slowapi (rate limit)
frontend/   Flutter Web (Riverpod, go_router, dio)
docs/       superpowers: spec & plan redesign
```

## Menjalankan Backend

```bash
cd backend
python -m venv .venv
.\.venv\Scripts\pip install -r requirements-dev.txt   # dev (termasuk pytest)
copy .env.example .env                                # isi SENGAJA semua nilai
.\.venv\Scripts\python -m alembic upgrade head        # migrasi DB
.\.venv\Scripts\python -m uvicorn app.main:app --reload
```

Catatan penting:
- `SECRET_KEY` **wajib** ≥32 karakter & bukan nilai lemah — app menolak start
  kalau tidak (validator di `app/core/config.py`).
- Seed admin: `python seed_admin.py` — password **wajib** dari env
  `ADMIN_USERNAME`/`ADMIN_PASSWORD`; kalau password kosong, script membuat
  password acak dan menampilkannya sekali.
- Seed konten demo: `python seed_demo.py` (API server harus hidup).

### Test backend

```bash
cd backend
.\.venv\Scripts\python -m pytest tests -q
```

## Menjalankan Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome        # .env berisi API_BASE_URL
```

- Salin `.env` bila belum ada: minimal `API_BASE_URL=http://127.0.0.1:8000/api/v1`.
  File ini tidak di-commit tapi wajib ada sebelum build (terdaftar sebagai
  asset Flutter); CI membuatnya otomatis.

### Test & analisis frontend

```bash
flutter test
flutter analyze
```

## Docker

```bash
cd backend
docker compose up --build    # db (Postgres, bind 127.0.0.1 saja) + api
```

`api` menunggu Postgres sehat (`pg_isready`), menjalankan `alembic upgrade head`
otomatis, dan berjalan sebagai user non-root.

## Keamanan singkat

- JWT di Bearer header; upload dipaginasi magic-bytes + Pillow (anti stored XSS).
- Rate limit sadar proxy (`X-Forwarded-For`) pada register/login/contact dan
  seluruh endpoint baca publik.
- Password dibatasi 72 byte (batas implementasi bcrypt).

## Keputusan yang masih terbuka

- Token disimpan di localStorage (Flutter Web) — pindah ke httpOnly cookie +
  refresh token perlu desain lewat kontrak API baru; belum dilakukan.
- `backend/test.db` pernah ter-commit; pembersihan history butuh `git
  filter-repo`/BFG dan rewrite push — butuh keputusan manual.

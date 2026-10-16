# Multi-User Portfolio Design (Owner-Based)

**Status:** approved option A by user 2026-10-16
**Scope:** 1 admin + N users. Tiap user kelola dashboard sendiri (profile, projects, skills, experiences, inbox). Publish langsung live. Admin moderasi (takedown). Publik: galeri semua + halaman per user.

## 1. Roles & Auth

- `users.role`: `admin | user`, default `user`.
- Registrasi hybrid:
  - `POST /api/v1/auth/register` publik → buat `role=user`, `is_active=True`, `is_published=False`. Rate-limit `3/hour` per IP. Response 201 tanpa token (minta login setelahnya) agar anti-enumerasi timing.
  - Admin buat user: `POST /api/v1/admin/users` dengan `username, email, password, full_name, role`. 201.
- Login tetap `POST /api/v1/auth/login` (username atau email + password) → JWT `sub=user.id`.
- Baru: `GET /api/v1/auth/me` → profil sendiri (butuh Bearer).
- Baru: `PATCH /api/v1/auth/change-password` body `{current_password, new_password min 8}` → 200.
- Admin: `GET /api/v1/admin/users`, `PATCH /api/v1/admin/users/{id}` (`is_active`, `role`, `is_published`), takedown = `is_active=False` atau `is_published=False`.

## 2. Data Model & Migration (Alembic rev 002)

- `users` tambah: `role VARCHAR(10) DEFAULT 'user' NOT NULL`, `profile_slug VARCHAR(60) UNIQUE NULL`, `is_published BOOLEAN DEFAULT FALSE NOT NULL`.
- Backfill: user id pertama (admin seed) → `role='admin'`, `profile_slug='admin'`, `is_published=True`. User lain tanpa slug → slug = `user-{id}` sementara, wajib diisi saat onboarding.
- `projects`, `skills`, `experiences` tambah: `owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE`, index `owner_id`.
- Backfill `owner_id` = id admin pertama untuk semua row existing.
- `messages` tambah: `recipient_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE`, index. Backfill = admin pertama. `POST /public/contact` wajib `recipient` (profile_slug atau user id) agar inbox masuk ke owner yang benar.
- Constraint: `slug` project unik per owner (bukan global): unique index `(owner_id, slug)`.

## 3. Ownership Enforcement (Backend)

- Helper baru `app/routers/deps.py`: `get_current_user()` (semua user aktif), `get_current_admin()` tetap (role==admin), `require_owner_or_admin(row_owner_id)`.
- Semua endpoint tulis user-scoped pindah ke router baru `app/routers/me.py` prefix `/me` (butuh login user biasa):
  - `GET/PUT /me/profile`, `GET/POST /me/projects`, `PATCH/DELETE /me/projects/{id}`, `POST /me/projects/{id}/media`
  - CRUD sama untuk `/me/skills`, `/me/experiences`
  - `GET /me/messages` (inbox miliknya), `PATCH /me/messages/{id}/read`, `DELETE /me/messages/{id}`
  - `POST /me/publish` → `is_published=True`; `POST /me/unpublish` → False.
- Query tulis selalu filter `owner_id == current_user.id` kecuali admin. Response 404 (bukan 403) bila bukan miliknya agar tidak bocor keberadaan id.
- Attach `skill_ids` ke project hanya boleh skill milik sendiri (`owner_id` sama); selain itu 422.
- Router `/admin/*` existing dipertahankan untuk moderasi lintas user: list dengan `?owner_id`, takedown project (`status=draft`), takedown user.
- Upload (`/admin/upload/*` → pindah/duplikat ke `/me/upload/*` untuk user) simpan ke `static/uploads/u/{user_id}/...` agar terisolasi; URL dikembalikan absolut-relatif.

## 4. Public API

- Galeri: `GET /api/v1/public/gallery/projects?skip&limit` → project `status=published` + `owner.is_published=True` + `owner.is_active=True`, sertakan `owner {profile_slug, full_name, avatar_url}`.
- Per-user: `GET /api/v1/public/u/{profile_slug}/profile`, `/u/{profile_slug}/projects`, `/u/{profile_slug}/skills`, `/u/{profile_slug}/experiences`. 404 bila user belum publish/nonaktif.
- Kompat: endpoint lama `/public/projects`, `/public/profile` dipertahankan sementara sebagai alias galeri admin (deprecated, hapus di rilis berikut) agar frontend lama tidak pecah.
- Contact: `POST /api/v1/public/u/{profile_slug}/contact` body `MessageCreate` (tanpa recipient di body) → `recipient_id` dari slug. Rate-limit `5/minute` per IP (existing limiter). Validasi existing tetap. Endpoint lama `POST /public/contact` deprecated → 410 dengan pesan gunakan endpoint per-user.

## 5. Validation & Security

- Register: `username ^[a-z0-9_]{3,30}$`, `email EmailStr`, `password min 8 max 128`, `full_name min 2`.
- `profile_slug ^[a-z0-9]+(?:-[a-z0-9]+)*$`, max 60, unique.
- Project slug unik per `(owner_id, slug)`; error 409 bila duplikat milik sendiri.
- Rate-limit: register `3/hour`, login `10/minute`, contact `5/minute`.
- CORS tetap eksplisit via `BACKEND_CORS_ORIGINS`. Tidak ada perubahan secret handling.

## 6. Testing

- `backend/tests/test_multitenant.py` (SQLite override existing):
  1. register user A + B, login keduanya.
  2. A buat project slug `x`; B buat project slug `x` → keduanya 201 (unik per owner).
  3. A PATCH project B → 404. B GET `/me/messages` tidak melihat inbox A.
  4. Unpublished user tidak muncul di gallery; setelah publish muncul.
  5. Admin takedown user B → halaman `/u/B` 404, gallery tanpa B.
- Full suite `pytest -q` harus hijau. Tidak ada frontend change di spec ini.

## 7. Non-Goals

- Tanpa subdomain per user, tanpa tim/organisasi, tanpa approval workflow, tanpa email verifikasi / reset password (tahap berikut bila perlu).

# Task 1 Report — Models + Migration 002

## Status
DONE (with 2 minor concerns, no blockers for Tasks 2–6)

## What changed per file
- `backend/app/models/user.py` — added `role` (String(10), default `"user"`, NOT NULL), `profile_slug` (String(60), unique, indexed, nullable), `is_published` (Boolean, default False, NOT NULL). Exact values per plan Step 1.
- `backend/app/models/project.py` — added `owner_id` FK `users.id` CASCADE NOT NULL + indexed; added `__table_args__ = (UniqueConstraint("owner_id", "slug", name="uq_project_owner_slug"),)`; **removed global `unique=True` on `slug`** (kept index) — required by spec §2 "unik per owner (bukan global)" and by Task 6 test `test_same_slug_different_owner_ok`; added optional `owner = relationship("User")` per plan (no back_populates, minimal diff).
- `backend/app/models/skill.py` — added `owner_id` FK CASCADE NOT NULL + indexed (plan Step 3 verbatim). `name` global unique left untouched (plan/spec silent).
- `backend/app/models/experience.py` — added `owner_id` FK CASCADE NOT NULL + indexed (plan Step 3 verbatim).
- `backend/app/models/message.py` — added `recipient_id` FK CASCADE NOT NULL + indexed (plan Step 3 verbatim).
- `backend/alembic/versions/002_multitenant.py` (new) — `revision="002_multitenant"`, `down_revision="001_initial_schema"`; upgrade/downgrade per plan Step 4 verbatim, plus two spec-driven deltas:
  1. Backfill non-first users: `UPDATE users SET profile_slug='user-' || id WHERE ... profile_slug IS NULL` (spec §2: "User lain tanpa slug → slug = `user-{id}` sementara").
  2. `ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_slug_key` on PostgreSQL only (spec §2: slug unique per owner, "bukan global" — drops the legacy global unique created by 001).

## Verification (from repo root / backend, venv `backend/.venv/Scripts/python`)
1. `cd backend && ./.venv/Scripts/python -c "import app.models; from app.core.database import Base; print(sorted(Base.metadata.tables.keys()))"`
   → PASS: `['experiences', 'messages', 'project_media', 'project_skills', 'projects', 'skills', 'users']`
2. Column/constraint introspection → PASS: `users` has role/profile_slug/is_published; `projects/skills/experiences` have owner_id; `messages` has recipient_id; only project UniqueConstraint is `(owner_id, slug)`; migration module imports with correct revision/down_revision.
3. `./.venv/Scripts/python -m pytest --collect-only -q` → PASS: 3 tests collected (existing suite intact; warnings are pre-existing Pydantic/httpx deprecations).

## Commits
- `9ac8a94 feat(backend): multitenant models + migration 002` (6 files; an initial commit accidentally included `__pycache__/*.pyc`, removed via `git rm --cached` + amend — final commit is clean)

## Concerns
1. **Migration not executed against a live DB** (per plan, Task 1 verifies via import/collection only; `alembic upgrade head` was not run — no PG available here). The `ALTER TABLE ... DROP CONSTRAINT IF EXISTS` branch is PG-only and safe (IF EXISTS = no-op if name differs); SQLite cannot run this migration as-is (`ALTER COLUMN` unsupported) — acceptable because tests use `Base.metadata.create_all` on SQLite and prod `DATABASE_URL` defaults to Postgres. Task 6 should still run full `pytest -q` (fresh `create_all` path).
2. **`Skill.name` remains globally unique** — plan and spec are silent on it, so it was kept verbatim, but two users cannot own same-named skills (e.g. both "Python"). If Task 3/6 needs per-owner skill names, a follow-up migration relaxing `skills.name` to unique-per-`(owner_id, name)` will be needed. Flagging, not changing.
3. Repo has no committed `.gitignore` (untracked in workspace) — `__pycache__`, `test.db`, `static/` show as untracked. Out of scope for this task but worth adding.

---

## Fix follow-up (review findings F1 + F2, 2026-10-16)

Source: `.superpowers/sdd/2026-10-16-multi-user-portfolio/task-1-review.md`. F3/F4 deferred per instruction (not fixed).

### F1 — FK constraints added to migration 002 (fixed)
`backend/alembic/versions/002_multitenant.py` only:
- `upgrade()`: after each NOT NULL + index step, added
  `op.create_foreign_key(f"fk_{tbl}_owner", tbl, "users", ["owner_id"], ["id"], ondelete="CASCADE")`
  for `projects`/`skills`/`experiences`, and
  `op.create_foreign_key("fk_messages_recipient", "messages", "users", ["recipient_id"], ["id"], ondelete="CASCADE")`.
- `downgrade()`: matching `op.drop_constraint(..., type_="foreignkey")` for all four, placed before the corresponding `drop_index`/`drop_column`.
- Everything else byte-identical (columns, backfill, indexes, `uq_project_owner_slug`, PG-only legacy-unique drop, revision chain).

### F2 — no-live-DB mitigation (recorded honestly, NOT a live run)
No Postgres available in this environment, so `upgrade()` was not executed live. What was run:
1. `python -m py_compile alembic/versions/002_multitenant.py` → exit success (`True`).
2. Module import via `importlib` → OK, `revision=002_multitenant`, `down_revision=001_initial_schema`; `upgrade` source contains 2 `create_foreign_key` call sites (loop covers 3 tables + messages), `downgrade` contains 2 `foreignkey` drop sites.
3. Best-effort offline render: `python -m alembic -c alembic.ini upgrade 001_initial_schema:002_multitenant --sql` → rendered valid PG DDL through the `ADD COLUMN` block under `PostgresqlImpl`, then **failed as expected** at `conn.execute(...).scalar()` with `AttributeError: 'NoneType' object has no attribute 'scalar'` — in `--sql` mode `op.get_bind().execute()` returns None, so data-migration steps (admin backfill SELECT) cannot render offline. This is inherent to online-data migrations, not a migration bug. Exact DDL rendered is in the tool output log.
4. Targeted FK render check (offline `MigrationContext` + PG dialect, same op calls as the migration): all 8 statements render valid Postgres, e.g. `ALTER TABLE projects ADD CONSTRAINT fk_projects_owner FOREIGN KEY(owner_id) REFERENCES users (id) ON DELETE CASCADE;` and matching `DROP CONSTRAINT` lines.
5. Covering verifications re-run: model-metadata import → PASS (7 tables); `python -m pytest -q` → **3 passed**.

### Residual
Live `alembic upgrade head` (+ downgrade/upgrade round-trip) against PG staging identical to prod is still required before any prod migration run (F2 remainder). F3 (downgrade does not restore legacy global slug unique) and F4 (`Skill.name` global unique) intentionally untouched.

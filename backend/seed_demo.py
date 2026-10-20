"""Seed demo content through the live API so screenshots show real UI.

Idempotent-ish: skips items that already exist (409/400). Placeholder cover
URLs point at picsum.photos, which CachedNetworkImage can fetch directly.

Kredensial admin WAJIB dari env (ADMIN_USERNAME/ADMIN_PASSWORD) — tidak ada
password bawaan (audit): script berhenti dengan pesan jelas bila kosong.
"""

import json
import os
import urllib.error
import urllib.parse
import urllib.request

BASE = "http://127.0.0.1:8000/api/v1"


def call(method, path, body=None, token=None, form=False):
  data = None
  headers = {}
  if body is not None:
    if form:
      data = urllib.parse.urlencode(body).encode()
      headers["Content-Type"] = "application/x-www-form-urlencoded"
    else:
      data = json.dumps(body).encode()
      headers["Content-Type"] = "application/json"
  if token:
    headers["Authorization"] = f"Bearer {token}"
  req = urllib.request.Request(BASE + path, data=data, headers=headers, method=method)
  try:
    with urllib.request.urlopen(req) as r:
      raw = r.read().decode()
      return r.status, (json.loads(raw) if raw else None)
  except urllib.error.HTTPError as e:
    return e.code, e.read().decode()[:200]


def login(username, password):
  code, res = call(
      "POST", "/auth/login", {"username": username, "password": password}, form=True
  )
  assert code == 200, (code, res)
  return res["access_token"]


def _demo_credentials() -> tuple[str, str]:
  """Ambil kredensial admin dari env; tolak jalan bila tidak lengkap."""
  username = os.getenv("ADMIN_USERNAME")
  password = os.getenv("ADMIN_PASSWORD")
  if not username or not password:
    raise SystemExit(
        "seed_demo butuh ADMIN_USERNAME dan ADMIN_PASSWORD di environment "
        "— tidak ada password bawaan demi keamanan."
    )
  return username, password


def main():
  username, password = _demo_credentials()
  token = login(username, password)

  call("PUT", "/me/profile", {
      "full_name": "Alex Rivera",
      "headline": "Full-Stack Developer",
      "bio": (
          "Membangun aplikasi web & mobile yang cepat, rapi, dan mudah "
          "dirawat. Fokus pada Flutter, FastAPI, dan Postgres."
      ),
      "profile_slug": "admin",
  }, token)

  for name, cat in [
      ("Dart", "Frontend"),
      ("Flutter", "Frontend"),
      ("API", "Backend"),
      ("Node.js", "Backend"),
      ("Postgres", "Database"),
      ("Docker", "Tools"),
      ("Git", "Tools"),
  ]:
    code, res = call("POST", "/me/skills", {"name": name, "category": cat}, token)
    print("skill", name, code)

  for role, company, start, desc in [
      ("Senior Flutter Engineer", "Nusantara Digital", "2023-02-26",
       "Memimpin migrasi aplikasi ke Flutter 3 dan Riverpod."),
      ("Frontend Developer", "Karya Studio", "2021-06-01",
       "Membangun design system berbasis komponen."),
      ("Backend Intern", "Data Prima", "2019-08-01",
       "Menulis REST API FastAPI dan menulis test integrasi."),
  ]:
    code, res = call("POST", "/me/experiences", {
        "role": role,
        "company": company,
        "start_date": start,
        "is_current": role.startswith("Senior"),
        "description": desc,
    }, token)
    print("exp", role, code)

  projects = [
      ("Visual Project", "visual-project", "Aplikasi analitik visual dengan chart interaktif dan mode gelap.",
       "https://picsum.photos/seed/visual/800/500"),
      ("Karea Hover", "karea-hover", "Showcase interaksi hover dan micro-animation di Flutter Web.",
       "https://picsum.photos/seed/karea/800/500"),
      ("Thart Banterion", "thart-banterion", "Platform kurasi karya kreator dengan pencarian instan.",
       "https://picsum.photos/seed/thart/800/500"),
      ("Contest Modian", "contest-modian", "Sistem pendaftaran lomba dengan panel admin lengkap.",
       "https://picsum.photos/seed/contest/800/500"),
  ]
  for i, (title, slug, summary, cover) in enumerate(projects):
    code, res = call("POST", "/me/projects", {
        "title": title,
        "slug": slug,
        "summary": summary,
        "cover_image_url": cover,
        "live_url": "https://example.com/live",
        "github_url": "https://github.com/example/repo",
        "display_order": i,
        "key_features": ["Mode gelap", "Responsif", "Animasi halus"],
    }, token)
    print("project", slug, code)
    if code in (200, 201):
      pid = res["id"]
      for s in ["a", "b", "c"]:
        q = urllib.parse.urlencode({
            "media_url": f"https://picsum.photos/seed/{slug}{s}/900/560",
            "media_type": "image",
        })
        call("POST", f"/me/projects/{pid}/media?{q}", None, token)

  call("POST", "/me/publish", None, token)
  print("published")


if __name__ == "__main__":
  main()

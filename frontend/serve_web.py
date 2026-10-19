"""Static server for the Flutter web build with SPA fallback.

`usePathUrlStrategy()` produces real paths (/gallery, /u/admin), so a plain
static server 404s on refresh. Any path without a file extension falls back
to index.html.
"""

import os
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")


class SpaHandler(SimpleHTTPRequestHandler):
  def __init__(self, *args, **kwargs):
    super().__init__(*args, directory=ROOT, **kwargs)

  def send_head(self):
    path = self.translate_path(self.path)
    if not os.path.exists(path) and not os.path.splitext(self.path)[1]:
      self.path = "/index.html"
    return super().send_head()

  def log_message(self, *args):
    pass


if __name__ == "__main__":
  port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
  if not os.path.isdir(ROOT):
    raise SystemExit(f"missing build: {ROOT} — run `flutter build web` first")
  print(f"serving {ROOT} on http://127.0.0.1:{port}")
  ThreadingHTTPServer(("127.0.0.1", port), SpaHandler).serve_forever()

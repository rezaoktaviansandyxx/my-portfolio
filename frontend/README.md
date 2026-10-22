# frontend — FolioSpace (Flutter Web)

Klien web dari backend FastAPI. Setelah proses redesign, struktur kode:

```
lib/
├── core/          # state & infrastruktur
│   ├── models/    # UserModel, ProjectModel, SkillModel, ExperienceModel (.g.dart json)
│   ├── network/   # api_config, api_service, auth_service, app_providers
│   ├── routes/    # go_router + _AuthGate (gate token, guard admin)
│   └── theme/     # app_colors, app_text, app_theme (dark glass)
├── features/
│   ├── admin/           # AdminDashboardPage
│   ├── auth/            # auth_providers (Riverpod), layar login/registrasi
│   ├── dashboard_me/    # dashboard user + shell + dialog CRUD
│   └── public_portfolio/# profile_page public + widgets glass navbar dll
└── shared/widgets/      # GlassCard, HoverScale, GlowButton, skeleton, dll
```

## Menjalankan

```bash
flutter pub get
flutter run -d chrome
```

`.env` (frontend) minimal berisi:

```
API_BASE_URL=http://127.0.0.1:8000/api/v1
```

File itu di-gitignore tetapi **wajib ada** karena terdaftar sebagai asset di
`pubspec.yaml` (flutter_dotenv membacanya lewat `rootBundle`). Tanpa file
tersebut `flutter analyze`/`flutter build` gagal dengan
`asset_does_not_exist`, jadi salin dari `.env.example` sebelum build. Di CI,
`.github/workflows/ci.yml` membuat file itu otomatis dari repository variable
`API_BASE_URL` (default: `http://127.0.0.1:8000/api/v1`).

Saat runtime, `Env.load()` di `lib/core/network/api_config.dart` memakai
`isOptional: true`; kalau file kosong/hilang aplikasi tetap start dengan
fallback URL di atas.

## Test

```bash
flutter test      # seluruh suite (unit + widget)
flutter analyze   # linter, harus "No issues found!"
```

Catatan: beberapa test mengganti `dotenv` via
`dotenv.loadFromString(envString: 'API_BASE_URL=...')`, sehingga tidak butuh
file `.env` fisik saat berjalan di CI.

## Konvensi penting

- Tema **dark only** (`AppTheme.dark`), warna di `core/theme/app_colors.dart`.
- Breakpoint desktop = 900 logical px (`kDesktopBreakpoint`).
- Semua gambar remote lewat `shared/widgets/app_network_image.dart` (bukan
  `Image.network`), dengan fallback inisial.
- Input tanggal memakai `shared/widgets/folio_date_field.dart` (date picker
  Syncfusion) — user memilih tanggal lewat kalender, tidak mengetik manual.
- Komponen interaktif memakai `HoverScale`/`GlowButton` — otomatis dapat
  kursor click, fokus keyboard (Tab/Enter), dan role tombol a11y.

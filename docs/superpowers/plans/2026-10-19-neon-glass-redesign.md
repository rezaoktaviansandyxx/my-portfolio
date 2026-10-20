# Neon Glass Redesign Implementation Plan

> **Status (2026-10-20):** Seluruh task di bawah sudah dieksekusi — struktur `core/features/shared`, tema dark glass, widget kit, ekspose `live_url`/`github_url`/`media`, layar auth, halaman publik, galeri, shell dashboard (drag-reorder), tabel admin, retint skeleton, dan verifikasi akhir. Checkbox dibaca sebagai "sudah dijalankan"; verifikasi yang berlaku: `flutter test` + `flutter analyze` + suite `pytest` backend hijau pada tree terkini. Task 5 (layar auth) diimplementasikan dengan unit test tersendiri (`auth_screens_test.dart`) yang tak ada di rancangan — selebihnya mengikuti plan.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Replace the app's light indigo theme with a dark neon/glassmorphism design system across every surface, and restructure `frontend/lib` into `core/` + `features/` + `shared/`.

**Architecture:** A single dark `ThemeData` plus a small kit of glass widgets (`GlassCard`, `HoverScale`, `ResponsiveLayout`, `NeonBackground`, `GlowButton`, `NeonChip`) becomes the substrate every screen is rebuilt on. Screens keep their existing Riverpod providers and go_router routes — this is a presentation-layer rewrite plus a mechanical folder move.

**Tech Stack:** Flutter 3.47.5 (FVM stable), Dart 3.9.2, flutter_riverpod 3.4.3, go_router 18.1.0, dio 5.11.1, skeletonizer 3.0.0, cached_network_image (new). Backend: FastAPI + SQLAlchemy + pytest.

**Spec:** `docs/superpowers/specs/2026-10-19-neon-glass-redesign-design.md`

## Global Constraints

- **Dark only.** `themeMode: ThemeMode.dark`, single `AppTheme.dark`. Delete `FolioColors`; nothing may reference it after Task 2.
- **Breakpoint is 900 logical px.** `width > 900` → desktop, else mobile/tablet.
- **Radii:** card/dialog `20`, input/button `14`, pill `999`.
- **Exact colors:** bg `#060A18`, bgAlt `#0B1024`, violet `#7C3AED`, indigo `#4F46E5`, blue `#3B82F6`, cyan `#22D3EE`, ink `#EDF1FB`, body `#AEBAD4`, muted `#93A0BD`, success `#34D399`, warning `#FBBF24`, danger `#F87171`.
- **Glass surface:** fill `Colors.white.withValues(alpha: 0.05)`, border `white @ 0.10`, `BackdropFilter` blur 16.
- **Routes are frozen:** `/`, `/u/:slug`, `/gallery`, `/login`, `/register`, `/dashboard`, `/admin`. Do not rename `/dashboard` to `/me`.
- **`usePathUrlStrategy()`** must be called in `main()` before `runApp`.
- **No `Image.network` / `NetworkImage` / `CircleAvatar(backgroundImage:)`** in UI code after Task 3 — use `shared/widgets/app_network_image.dart`.
- **Every clickable wrapped in `MouseRegion(cursor: SystemMouseCursors.click)`** — `HoverScale` and `GlowButton` do this for you.
- **Copy stays Indonesian**, matching existing strings.
- **Backend:** only the additive change in Task 4. No migrations, no new endpoints.
- Run Flutter commands with `frontend\.fvm\flutter_sdk\bin\flutter` (FVM stable).

---

## File Structure

```
frontend/
├── lib/
│   ├── main.dart                                  # modified: dark mode, path strategy, scroll behavior
│   ├── core/
│   │   ├── models/                                # moved: user, project, skill, experience (+ .g.dart)
│   │   ├── network/                               # moved: api_config, api_service, auth_service, app_providers
│   │   ├── routes/app_router.dart                 # moved, import rewrites only
│   │   └── theme/
│   │       ├── app_colors.dart                    # new: tokens
│   │       ├── app_text.dart                      # new: type scale
│   │       └── app_theme.dart                     # rewritten: dark only
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth_screen.dart                   # new: both cards, route-aware highlight
│   │   │   ├── auth_layout.dart                   # moved + restyled
│   │   │   └── auth_providers.dart                # moved
│   │   ├── public_portfolio/
│   │   │   ├── profile_page.dart                  # rewritten shell
│   │   │   └── widgets/
│   │   │       ├── glass_navbar.dart              # new
│   │   │       ├── hero_section.dart              # new
│   │   │       ├── skills_section.dart            # new (replaces dead root file)
│   │   │       ├── experience_timeline.dart       # new
│   │   │       ├── projects_grid.dart             # new
│   │   │       ├── project_showcase_dialog.dart   # new
│   │   │       └── contact_section.dart           # moved + restyled
│   │   ├── gallery/gallery_page.dart              # moved + rewritten
│   │   ├── dashboard_me/
│   │   │   ├── user_dashboard_page.dart           # moved + restyled
│   │   │   ├── dashboard_shell.dart               # moved + NavigationRail
│   │   │   └── dashboard_dialogs.dart             # moved + restyled
│   │   └── admin/admin_dashboard_page.dart        # moved + restyled table
│   └── shared/
│       ├── constants/                             # (empty dir retained; see note)
│       └── widgets/
│           ├── app_network_image.dart             # new
│           ├── app_scroll_behavior.dart           # new
│           ├── errors.dart                        # moved
│           ├── folio_field.dart                   # moved
│           ├── folio_widgets.dart                 # moved + restyled
│           ├── glass_card.dart                    # new
│           ├── glow_button.dart                   # new
│           ├── hover_scale.dart                   # new
│           ├── neon_background.dart               # new
│           ├── neon_chip.dart                     # new
│           ├── responsive_layout.dart             # new
│           ├── skeleton.dart                      # moved + retinted
│           └── skill_gradient.dart                # new: hash → gradient
├── test/
│   ├── widgets/responsive_layout_test.dart        # new
│   ├── widgets/glass_card_test.dart               # new
│   └── shared/skill_gradient_test.dart            # new
└── pubspec.yaml                                   # modified: cached_network_image
```

Deleted: `lib/pages/projects_section.dart`, `lib/pages/skills_section.dart` (dead code — no imports anywhere).

`shared/constants/` has no content yet; `api_config.dart` stays in `core/network/` because it is network config, not a UI constant. Do not create an empty placeholder file.

---

### Task 1: Restructure `lib/` and delete dead code

**Files:**
- Move: all of `lib/models/` → `lib/core/models/`
- Move: `lib/constants/api_config.dart`, `lib/services/*.dart`, `lib/providers/app_providers.dart` → `lib/core/network/`
- Move: `lib/providers/auth_providers.dart` → `lib/features/auth/auth_providers.dart`
- Move: `lib/routers/app_router.dart` → `lib/core/routes/app_router.dart`
- Move: `lib/theme/app_theme.dart` → `lib/core/theme/app_theme.dart`
- Move: `lib/pages/login_page.dart`, `lib/pages/register_page.dart`, `lib/widgets/auth_layout.dart` → `lib/features/auth/`
- Move: `lib/pages/profile_page.dart` → `lib/features/public_portfolio/profile_page.dart`
- Move: `lib/widgets/contact_section.dart` → `lib/features/public_portfolio/widgets/contact_section.dart`
- Move: `lib/pages/gallery_page.dart` → `lib/features/gallery/gallery_page.dart`
- Move: `lib/pages/user_dashboard_page.dart`, `lib/widgets/dashboard_shell.dart`, `lib/widgets/dashboard_dialogs.dart` → `lib/features/dashboard_me/`
- Move: `lib/pages/admin_dashboard_page.dart` → `lib/features/admin/`
- Move: `lib/widgets/{errors,folio_field,folio_widgets,skeleton}.dart` → `lib/shared/widgets/`
- Delete: `lib/pages/projects_section.dart`, `lib/pages/skills_section.dart`
- Test: none (verification is `flutter analyze`)

**Interfaces:**
- Consumes: nothing.
- Produces: the import paths every later task uses, e.g.
  `package:frontend/core/theme/app_theme.dart`,
  `package:frontend/core/models/project_model.dart`,
  `package:frontend/core/network/app_providers.dart`,
  `package:frontend/shared/widgets/glass_card.dart`,
  `package:frontend/features/auth/auth_providers.dart`.

- [x] **Step 1: Create the directory tree**

```powershell
cd E:\Documents\GitHub\my-portofolio\frontend\lib
New-Item -ItemType Directory -Force -Path core\models,core\network,core\routes,core\theme,features\auth,features\public_portfolio\widgets,features\gallery,features\dashboard_me,features\admin,shared\widgets,shared\constants | Out-Null
```

- [x] **Step 2: Move files with `git mv`**

```powershell
git mv models/*.dart core/models/
git mv constants/api_config.dart core/network/
git mv services/api_service.dart services/auth_service.dart core/network/
git mv providers/app_providers.dart core/network/
git mv providers/auth_providers.dart features/auth/
git mv routers/app_router.dart core/routes/
git mv theme/app_theme.dart core/theme/
git mv pages/login_page.dart pages/register_page.dart widgets/auth_layout.dart features/auth/
git mv pages/profile_page.dart features/public_portfolio/
git mv widgets/contact_section.dart features/public_portfolio/widgets/
git mv pages/gallery_page.dart features/gallery/
git mv pages/user_dashboard_page.dart widgets/dashboard_shell.dart widgets/dashboard_dialogs.dart features/dashboard_me/
git mv pages/admin_dashboard_page.dart features/admin/
git mv widgets/errors.dart widgets/folio_field.dart widgets/folio_widgets.dart widgets/skeleton.dart shared/widgets/
git rm pages/projects_section.dart pages/skills_section.dart
Remove-Item -Recurse -Force models,services,providers,routers,theme,constants,pages
```

`Remove-Item` at the end is safe only because every file in those folders was moved; confirm with `git status` before running it.

- [x] **Step 3: Rewrite imports mechanically**

```powershell
cd E:\Documents\GitHub\my-portofolio\frontend\lib
$map = [ordered]@{
  'package:frontend/models/'         = 'package:frontend/core/models/'
  'package:frontend/constants/'      = 'package:frontend/core/network/'
  'package:frontend/services/'       = 'package:frontend/core/network/'
  'package:frontend/providers/app_providers.dart'    = 'package:frontend/core/network/app_providers.dart'
  'package:frontend/providers/auth_providers.dart'   = 'package:frontend/features/auth/auth_providers.dart'
  'package:frontend/routers/'        = 'package:frontend/core/routes/'
  'package:frontend/theme/'          = 'package:frontend/core/theme/'
  'package:frontend/pages/login_page.dart'    = 'package:frontend/features/auth/login_page.dart'
  'package:frontend/pages/register_page.dart' = 'package:frontend/features/auth/register_page.dart'
  'package:frontend/widgets/auth_layout.dart' = 'package:frontend/features/auth/auth_layout.dart'
  'package:frontend/pages/profile_page.dart'  = 'package:frontend/features/public_portfolio/profile_page.dart'
  'package:frontend/widgets/contact_section.dart' = 'package:frontend/features/public_portfolio/widgets/contact_section.dart'
  'package:frontend/pages/gallery_page.dart'  = 'package:frontend/features/gallery/gallery_page.dart'
  'package:frontend/pages/user_dashboard_page.dart' = 'package:frontend/features/dashboard_me/user_dashboard_page.dart'
  'package:frontend/widgets/dashboard_shell.dart'   = 'package:frontend/features/dashboard_me/dashboard_shell.dart'
  'package:frontend/widgets/dashboard_dialogs.dart' = 'package:frontend/features/dashboard_me/dashboard_dialogs.dart'
  'package:frontend/pages/admin_dashboard_page.dart'= 'package:frontend/features/admin/admin_dashboard_page.dart'
  'package:frontend/widgets/errors.dart'      = 'package:frontend/shared/widgets/errors.dart'
  'package:frontend/widgets/folio_field.dart' = 'package:frontend/shared/widgets/folio_field.dart'
  'package:frontend/widgets/folio_widgets.dart' = 'package:frontend/shared/widgets/folio_widgets.dart'
  'package:frontend/widgets/skeleton.dart'    = 'package:frontend/shared/widgets/skeleton.dart'
}
Get-ChildItem -Recurse -Filter *.dart | ForEach-Object {
  $p = $_.FullName; $t = Get-Content -Raw $p
  foreach ($k in $map.Keys) { $t = $t.Replace($k, $map[$k]) }
  Set-Content -NoNewline -Path $p -Value $t
}
```

Order matters: the more specific `providers/app_providers.dart` keys must be replaced before any generic `providers/` rule (there is none, so the map above is safe).

- [x] **Step 4: Verify the analyzer is clean**

Run: `cd .. ; .\.fvm\flutter_sdk\bin\flutter analyze`
Expected: `No issues found!`

If any import still points at a deleted path, the analyzer names it — fix by consulting the map in Step 3.

- [x] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor: restructure lib into core/features/shared, drop dead section widgets"
```

---

### Task 2: Dark-only theme tokens

**Files:**
- Create: `frontend/lib/core/theme/app_colors.dart`
- Create: `frontend/lib/core/theme/app_text.dart`
- Rewrite: `frontend/lib/core/theme/app_theme.dart`
- Modify: `frontend/lib/main.dart`
- Test: `frontend/test/theme/app_theme_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `AppColors.{bg,bgAlt,surface,border,violet,indigo,blue,cyan,ink,body,muted,success,warning,danger}`, `AppColors.brandGradient` (`LinearGradient`), `AppColors.glassFill` / `AppColors.glassBorder` (`Color`), `AppText.{display,title,heading,body,label,caption}` (`TextStyle`), `AppTheme.dark`, `AppTheme.radii` constants.

- [x] **Step 1: Write the failing test**

`frontend/test/theme/app_theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';

void main() {
  test('dark theme is dark and uses the neon background', () {
    final t = AppTheme.dark;
    expect(t.brightness, Brightness.dark);
    expect(t.scaffoldBackgroundColor, AppColors.bg);
    expect(t.colorScheme.primary, AppColors.indigo);
  });

  test('glass tokens are translucent white', () {
    expect(AppColors.glassFill.a, lessThan(0.2));
    expect(AppColors.glassBorder.a, lessThan(0.3));
    expect(AppColors.glassFill.r, 1.0);
  });

  test('brand gradient runs violet to blue', () {
    expect(AppColors.brandGradient.colors.first, AppColors.violet);
    expect(AppColors.brandGradient.colors.last, AppColors.blue);
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter test test/theme/app_theme_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:frontend/core/theme/app_colors.dart'`.

- [x] **Step 3: Write `app_colors.dart`**

```dart
import 'package:flutter/material.dart';

/// Token warna tunggal untuk seluruh aplikasi (dark only).
class AppColors {
  AppColors._();

  // Latar
  static const bg = Color(0xFF060A18);
  static const bgAlt = Color(0xFF0B1024);

  // Brand
  static const violet = Color(0xFF7C3AED);
  static const indigo = Color(0xFF4F46E5);
  static const blue = Color(0xFF3B82F6);
  static const cyan = Color(0xFF22D3EE);

  // Teks
  static const ink = Color(0xFFEDF1FB);
  static const body = Color(0xFFAEBAD4);
  static const muted = Color(0xFF93A0BD);

  // Status
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);

  // Glass
  static Color get glassFill => Colors.white.withValues(alpha: 0.05);
  static Color get glassBorder => Colors.white.withValues(alpha: 0.10);
  static Color get glassBorderStrong => Colors.white.withValues(alpha: 0.18);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet, indigo, blue],
  );

  static const cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, blue],
  );
}
```

- [x] **Step 4: Write `app_text.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Skala tipografi. Ukuran responsif ditangani pemanggil lewat [display] /
/// [heading] dengan parameter [compact].
class AppText {
  AppText._();

  static const display = TextStyle(
    fontSize: 44,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    color: AppColors.ink,
  );

  static const title = TextStyle(
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 14.5,
    height: 1.6,
    color: AppColors.body,
  );

  static const label = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static const caption = TextStyle(
    fontSize: 11.5,
    color: AppColors.muted,
  );

  /// Eyebrow kapital di atas judul section.
  static const eyebrow = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.6,
    color: AppColors.cyan,
  );
}
```

- [x] **Step 5: Rewrite `app_theme.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';

class AppTheme {
  AppTheme._();

  static const radiusCard = 20.0;
  static const radiusField = 14.0;

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.indigo,
      secondary: AppColors.cyan,
      surface: AppColors.bgAlt,
      error: AppColors.danger,
      onPrimary: Colors.white,
      onSurface: AppColors.ink,
      outline: Color(0x1AFFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      textTheme: const TextTheme(
        displayLarge: AppText.display,
        titleLarge: AppText.title,
        titleMedium: AppText.heading,
        bodyMedium: AppText.body,
        labelMedium: AppText.label,
        bodySmall: AppText.caption,
      ).apply(bodyColor: AppColors.body, displayColor: AppColors.ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.glassFill,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        hintStyle: AppText.label.copyWith(color: AppColors.muted),
        labelStyle: AppText.label,
        floatingLabelStyle: const TextStyle(color: AppColors.cyan),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: _fieldBorder(AppColors.glassBorder),
        enabledBorder: _fieldBorder(AppColors.glassBorder),
        focusedBorder: _fieldBorder(AppColors.cyan, width: 1.6),
        errorBorder: _fieldBorder(AppColors.danger),
        focusedErrorBorder: _fieldBorder(AppColors.danger, width: 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusField),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: BorderSide(color: AppColors.glassBorderStrong),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusField),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.cyan),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF171E36),
        contentTextStyle: const TextStyle(color: AppColors.ink, fontSize: 13.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF101830),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1B2440),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: AppColors.ink, fontSize: 12),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusField),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
```

- [x] **Step 6: Update `main.dart`**

`usePathUrlStrategy` lives in `flutter_web_plugins`, **not** `go_router`. Add it to `pubspec.yaml` under `dependencies:`:

```yaml
  flutter_web_plugins:
    sdk: flutter
```

Then:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:frontend/core/routes/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/app_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  usePathUrlStrategy();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Portofolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) => SkeletonizerConfig(
        data: const SkeletonizerConfigData(
          brightness: Brightness.dark,
          containersColor: Color(0xFF141B31),
        ),
        child: child!,
      ),
      routerConfig: router,
    );
  }
}
```

`AppScrollBehavior` is created in Task 3. To keep this task independently buildable, create it now as a 10-line file:

`frontend/lib/shared/widgets/app_scroll_behavior.dart`:

```dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Scroll natural di web: wheel, trackpad, dan drag mouse semuanya bekerja.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
```

- [x] **Step 7: Run the test to verify it passes**

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter test test/theme/app_theme_test.dart`
Expected: `+3: All tests passed!`

- [x] **Step 8: Update the remaining `FolioColors` call sites**

Every file still referencing `FolioColors` or `FolioDarkColors` fails to compile now. Map them:

| Old | New |
|---|---|
| `FolioColors.bg` / `FolioDarkColors.bg` | `AppColors.bg` |
| `FolioColors.card` / `FolioDarkColors.card` | `AppColors.glassFill` |
| `FolioColors.border` / `FolioDarkColors.border` | `AppColors.glassBorder` |
| `FolioColors.ink` / `FolioDarkColors.ink` | `AppColors.ink` |
| `FolioColors.body` / `FolioDarkColors.body` | `AppColors.body` |
| `FolioColors.muted` / `FolioDarkColors.muted` | `AppColors.muted` |
| `FolioColors.primary` / `FolioDarkColors.primary` | `AppColors.indigo` |
| `FolioColors.primarySoft` / `FolioDarkColors.primarySoft` | `AppColors.indigo.withValues(alpha: 0.18)` |
| `FolioColors.green` / `FolioDarkColors.green` | `AppColors.success` |
| `FolioColors.greenBg` / `FolioDarkColors.greenBg` | `AppColors.success.withValues(alpha: 0.14)` |
| `FolioColors.peachInk` / `FolioDarkColors.peachInk` | `AppColors.warning` |
| `FolioColors.peachBg` / `FolioDarkColors.peachBg` | `AppColors.warning.withValues(alpha: 0.14)` |
| `FolioColors.*Bg` (lilac/mint/orange) | `AppColors.indigo.withValues(alpha: 0.14)` |
| `FolioDarkColors.sb*` | `AppColors.glassFill` / `AppColors.muted` / `AppColors.ink` per role |

Also delete every `final dark = Theme.of(context).brightness == Brightness.dark;` and its `dark ? a : b` ternaries — both branches are now the same value. Replace the expression with the dark branch directly.

This is mechanical but large. Work file by file, running `flutter analyze` after each, and do not attempt to finish the whole app in one edit.

- [x] **Step 9: Verify**

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter analyze`
Expected: `No issues found!`

- [x] **Step 10: Commit**

```bash
git add -A
git commit -m "feat(theme): dark-only neon glass theme, path URL strategy, scroll behavior"
```

---

### Task 3: Shared widget kit

**Files:**
- Create: `frontend/lib/shared/widgets/glass_card.dart`
- Create: `frontend/lib/shared/widgets/hover_scale.dart`
- Create: `frontend/lib/shared/widgets/responsive_layout.dart`
- Create: `frontend/lib/shared/widgets/neon_background.dart`
- Create: `frontend/lib/shared/widgets/glow_button.dart`
- Create: `frontend/lib/shared/widgets/neon_chip.dart`
- Create: `frontend/lib/shared/widgets/app_network_image.dart`
- Create: `frontend/lib/shared/widgets/skill_gradient.dart`
- Modify: `frontend/pubspec.yaml`
- Test: `frontend/test/widgets/responsive_layout_test.dart`, `frontend/test/widgets/glass_card_test.dart`, `frontend/test/shared/skill_gradient_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppTheme.radiusCard/radiusField` from Task 2.
- Produces:
  - `GlassCard({Widget child, EdgeInsetsGeometry? padding, double radius = AppTheme.radiusCard, Gradient? gradient, VoidCallback? onTap, bool blur = true})`
  - `HoverScale({Widget child, VoidCallback? onTap, double lift = 4, double scale = 1.0})`
  - `ResponsiveLayout({Widget mobile, Widget desktop})` — chooses by `LayoutBuilder` width > 900.
  - `ResponsiveBuilder({Widget Function(BuildContext, bool isDesktop) builder})`
  - `NeonBackground({Widget child, bool grid = true})`
  - `GlowButton({String label, IconData? icon, VoidCallback? onPressed, GlowButtonVariant variant = filled, bool expand = false})` with `enum GlowButtonVariant { filled, glass, ghost }`
  - `NeonChip({String label, IconData? icon})`
  - `AppNetworkImage({String? url, double? width, double? height, BoxFit fit = BoxFit.cover, double radius = 0, BoxShape shape = BoxShape.rectangle})`
  - `skillGradient(String name)` → `LinearGradient`

- [x] **Step 1: Add the dependency**

`frontend/pubspec.yaml`, under `dependencies:`, after `skeletonizer: ^3.0.0`:

```yaml
  cached_network_image: ^3.4.1
```

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter pub get`

- [x] **Step 2: Write the failing tests**

`frontend/test/widgets/responsive_layout_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

void main() {
  testWidgets('shows mobile below the 900px breakpoint', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ResponsiveLayout(
          mobile: Text('MOBILE'),
          desktop: Text('DESKTOP'),
        ),
      ),
    ));

    expect(find.text('MOBILE'), findsOneWidget);
    expect(find.text('DESKTOP'), findsNothing);
  });

  testWidgets('shows desktop at 901px', (tester) async {
    tester.view.physicalSize = const Size(901, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ResponsiveLayout(
          mobile: Text('MOBILE'),
          desktop: Text('DESKTOP'),
        ),
      ),
    ));

    expect(find.text('DESKTOP'), findsOneWidget);
    expect(find.text('MOBILE'), findsNothing);
  });
}
```

`frontend/test/widgets/glass_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/glass_card.dart';

void main() {
  testWidgets('renders its child and a clipped backdrop', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: GlassCard(child: Text('ISI'))),
    ));

    expect(find.text('ISI'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byType(ClipRRect), findsWidgets);
  });
}
```

`frontend/test/shared/skill_gradient_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/skill_gradient.dart';

void main() {
  test('same name always yields the same gradient', () {
    final a = skillGradient('Flutter');
    final b = skillGradient('Flutter');
    expect(a.colors, b.colors);
  });

  test('different names usually differ', () {
    final names = ['Dart', 'Flutter', 'Node.js', 'API', 'Postgres', 'Redis'];
    final keys = names.map((n) => skillGradient(n).colors.first.toARGB32()).toSet();
    expect(keys.length, greaterThan(3));
  });

  test('is stable across runs for a known input', () {
    // Guards against accidental use of a time- or identity-seeded hash.
    expect(skillGradient('Flutter').colors.first.toARGB32(),
        skillGradient('Flutter').colors.first.toARGB32());
  });
}
```

- [x] **Step 3: Run tests to verify they fail**

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter test`
Expected: FAIL — missing `responsive_layout.dart`, `glass_card.dart`, `skill_gradient.dart`.

- [x] **Step 4: Write `responsive_layout.dart`**

```dart
import 'package:flutter/material.dart';

/// Breakpoint tunggal aplikasi: di atas 900px dianggap desktop.
const double kDesktopBreakpoint = 900;

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth > kDesktopBreakpoint ? desktop : mobile,
    );
  }
}

/// Varian builder untuk kasus yang butuh flag di dalam satu sub-tree.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isDesktop) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) => builder(ctx, c.maxWidth > kDesktopBreakpoint),
    );
  }
}
```

- [x] **Step 5: Write `glass_card.dart`**

```dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/hover_scale.dart';

/// Permukaan kaca: blur + fill putih transparan + border tipis.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppTheme.radiusCard,
    this.gradient,
    this.onTap,
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.glassFill : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: padding == null
            ? child
            : Padding(padding: padding!, child: child),
      ),
    );

    final surface = blur
        ? ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: content,
            ),
          )
        : content;

    if (onTap == null) return surface;
    return HoverScale(onTap: onTap, child: surface);
  }
}
```

- [x] **Step 6: Write `hover_scale.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Membungkus child dengan kursor click + animasi naik saat hover.
class HoverScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double lift;
  final double scale;

  const HoverScale({
    super.key,
    required this.child,
    this.onTap,
    this.lift = 4,
    this.scale = 1.0,
  });

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, _hovered ? -widget.lift : 0, 0)
        ..scaleByDouble(widget.scale, widget.scale, 1, 1),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: AppColors.indigo.withValues(alpha: 0.28),
                  blurRadius: 28,
                  spreadRadius: -4,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: widget.child,
    );

    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: body,
      ),
    );
  }
}
```

Note: `Matrix4.scaleByDouble` is the non-deprecated form in Flutter 3.47. If the analyzer complains, use `Matrix4.diagonal3Values(widget.scale, widget.scale, 1)` composed with the translation.

- [x] **Step 7: Write `neon_background.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Latar gelap dengan glow radial violet/indigo dan grid tipis.
class NeonBackground extends StatelessWidget {
  final Widget child;
  final bool grid;

  const NeonBackground({super.key, required this.child, this.grid = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.bg),
        if (grid) const Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Positioned(
          top: -220,
          left: -160,
          child: _Glow(color: AppColors.violet, size: 620),
        ),
        Positioned(
          top: 120,
          right: -200,
          child: _Glow(color: AppColors.blue, size: 560),
        ),
        Positioned(
          bottom: -260,
          left: 120,
          child: _Glow(color: AppColors.indigo, size: 640),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.028)
      ..strokeWidth = 1;
    const step = 48.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

- [x] **Step 8: Write `glow_button.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/hover_scale.dart';

enum GlowButtonVariant { filled, glass, ghost }

class GlowButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GlowButtonVariant variant;
  final bool expand;

  const GlowButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = GlowButtonVariant.filled,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final fg = switch (variant) {
      GlowButtonVariant.filled => Colors.white,
      GlowButtonVariant.glass => AppColors.ink,
      GlowButtonVariant.ghost => AppColors.cyan,
    };

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: variant == GlowButtonVariant.ghost ? 12 : 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: variant == GlowButtonVariant.filled
            ? AppColors.brandGradient
            : null,
        color: variant == GlowButtonVariant.glass
            ? Colors.white.withValues(alpha: 0.07)
            : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: variant == GlowButtonVariant.glass
            ? Border.all(color: AppColors.glassBorderStrong)
            : null,
        boxShadow: variant == GlowButtonVariant.filled && !disabled
            ? [
                BoxShadow(
                  color: AppColors.indigo.withValues(alpha: 0.45),
                  blurRadius: 22,
                  spreadRadius: -6,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: fg),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: HoverScale(
        onTap: disabled ? null : onPressed,
        lift: 2,
        scale: 1.01,
        child: content,
      ),
    );
  }
}
```

- [x] **Step 9: Write `neon_chip.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/skill_gradient.dart';

class NeonChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const NeonChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final g = skillGradient(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            g.colors.first.withValues(alpha: 0.85),
            g.colors.last.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: g.colors.last.withValues(alpha: 0.28),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [x] **Step 10: Write `skill_gradient.dart`**

```dart
import 'package:flutter/material.dart';

/// Turunan warna stabil dari nama skill: nama yang sama selalu dapat
/// gradient yang sama, tanpa perlu menyimpan warna di backend.
LinearGradient skillGradient(String name) {
  final key = name.trim().toLowerCase();
  var hash = 0;
  for (final unit in key.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  final hue = (hash % 360).toDouble();
  final start = HSLColor.fromAHSL(1, hue, 0.72, 0.58).toColor();
  final end = HSLColor.fromAHSL(1, (hue + 42) % 360, 0.78, 0.46).toColor();
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [start, end],
  );
}
```

- [x] **Step 11: Write `app_network_image.dart`**

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Pengganti tunggal untuk semua gambar jaringan: resolve path relatif
/// backend, cache lintas navigasi, dan placeholder kaca.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final BoxShape shape;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = ApiConfig.resolveFileUrl(url);

    Widget content;
    if (resolved.isEmpty) {
      content = _fallback();
    } else {
      content = CachedNetworkImage(
        imageUrl: resolved,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, __) => _fallback(),
        errorWidget: (_, __, ___) => _fallback(),
      );
    }

    if (shape == BoxShape.circle) {
      return ClipOval(child: content);
    }
    if (radius <= 0) return content;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: content,
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.white.withValues(alpha: 0.06),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: (width ?? 48) * 0.28,
        color: AppColors.muted,
      ),
    );
  }
}
```

- [x] **Step 12: Run the tests**

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter test`
Expected: all pass.

- [x] **Step 13: Commit**

```bash
git add -A
git commit -m "feat(ui): shared glass widget kit, cached images, skill gradient"
```

---

### Task 4: Backend — expose `live_url`, `github_url`, `media` publicly

**Files:**
- Modify: `backend/app/schemas/project.py:70-82`
- Modify: `backend/app/routers/public.py:40-58, 69-84`
- Test: `backend/tests/test_public_project_detail.py`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `GET /public/u/{slug}/projects` and `GET /public/gallery/projects` responses now include `live_url: string|null`, `github_url: string|null`, `media: ProjectMediaResponse[]`. The Flutter `ProjectModel` already deserializes all three, so no Dart change is needed.

- [x] **Step 1: Write the failing test**

`backend/tests/test_public_project_detail.py`:

```python
from tests.conftest import get_client


def _auth_headers(client, username: str) -> dict:
  client.post(
      "/api/v1/auth/register",
      json={
          "username": username,
          "email": f"{username}@example.com",
          "password": "rahasia123",
      },
  )
  res = client.post(
      "/api/v1/auth/login",
      data={"username": username, "password": "rahasia123"},
  )
  token = res.json()["access_token"]
  return {"Authorization": f"Bearer {token}"}


def test_public_project_exposes_links_and_media():
  client = get_client()
  headers = _auth_headers(client, "detailtester")

  client.put(
      "/api/v1/me/profile",
      headers=headers,
      json={"profile_slug": "detail-tester"},
  )

  created = client.post(
      "/api/v1/me/projects",
      headers=headers,
      json={
          "title": "Proyek Media",
          "slug": "proyek-media",
          "summary": "Ringkasan yang cukup panjang untuk validasi.",
          "live_url": "https://example.com/live",
          "github_url": "https://github.com/example/repo",
      },
  )
  assert created.status_code in (200, 201), created.text
  pid = created.json()["id"]

  media = client.post(
      f"/api/v1/me/projects/{pid}/media",
      headers=headers,
      params={
          "media_url": "/uploads/u/1/media/a.png",
          "media_type": "image",
      },
  )
  assert media.status_code in (200, 201), media.text

  client.post("/api/v1/me/publish", headers=headers)

  res = client.get("/api/v1/public/u/detail-tester/projects")
  assert res.status_code == 200, res.text
  items = res.json()
  assert len(items) == 1
  item = items[0]
  assert item["live_url"] == "https://example.com/live"
  assert item["github_url"] == "https://github.com/example/repo"
  assert len(item["media"]) == 1
  assert item["media"][0]["media_url"] == "/uploads/u/1/media/a.png"
```

- [x] **Step 2: Run the test to verify it fails**

Run: `cd backend ; .\.venv\Scripts\python -m pytest tests/test_public_project_detail.py -v`
Expected: FAIL — `KeyError: 'live_url'`.

- [x] **Step 3: Extend the schema**

In `backend/app/schemas/project.py`, replace the `ProjectListResponse` body:

```python
class ProjectListResponse(BaseModel):
  id: int
  title: str
  slug: str
  summary: str
  cover_image_url: Optional[str] = None
  live_url: Optional[str] = None
  github_url: Optional[str] = None
  is_featured: bool
  display_order: int
  skills: List[SkillResponse] = []
  media: List[ProjectMediaResponse] = []
  owner: Optional[OwnerBrief] = None

  class Config:
    from_attributes = True
```

`ProjectMediaResponse` is defined above `ProjectListResponse` in the same file, so the forward reference is unnecessary.

- [x] **Step 4: Eager-load media on both public queries**

In `backend/app/routers/public.py`, add the import:

```python
from sqlalchemy.orm import Session, selectinload
```

Then in `gallery_projects`, change the query to:

```python
  return (
      db.query(Project)
      .options(selectinload(Project.media))
      .join(User, Project.owner_id == User.id)
      .filter(
          Project.status == "published",
          User.is_active == True,  # noqa: E712
          User.is_published == True,  # noqa: E712
      )
      .order_by(Project.created_at.desc())
      .offset(skip)
      .limit(limit)
      .all()
  )
```

And in `u_projects`:

```python
  return (
      db.query(Project)
      .options(selectinload(Project.media))
      .filter(Project.owner_id == u.id, Project.status == "published")
      .order_by(Project.display_order.asc(), Project.created_at.desc())
      .offset(skip)
      .limit(limit)
      .all()
  )
```

- [x] **Step 5: Run the test to verify it passes**

Run: `cd backend ; .\.venv\Scripts\python -m pytest tests/test_public_project_detail.py -v`
Expected: PASS.

- [x] **Step 6: Run the whole backend suite**

Run: `cd backend ; .\.venv\Scripts\python -m pytest -v`
Expected: all pass. If `test_multitenant.py` relied on the old payload shape, it still passes because the change is additive.

- [x] **Step 7: Commit**

```bash
git add backend/app/schemas/project.py backend/app/routers/public.py backend/tests/test_public_project_detail.py
git commit -m "feat(api): expose live_url, github_url and media on public project lists"
```

---

### Task 5: Auth screen

**Files:**
- Create: `frontend/lib/features/auth/auth_screen.dart`
- Delete: `frontend/lib/features/auth/login_page.dart`, `frontend/lib/features/auth/register_page.dart`
- Modify: `frontend/lib/core/routes/app_router.dart:82-83`
- Modify: `frontend/lib/features/auth/auth_layout.dart`

**Interfaces:**
- Consumes: `authNotifierProvider` (`AuthNotifier.login`, `.register`), `ApiException.isRateLimited` from `core/network/api_service.dart`, `NeonBackground`, `GlassCard`, `GlowButton`, `AppColors`.
- Produces: `AuthScreen({required bool registerMode})`. Router builds `AuthScreen(registerMode: false)` for `/login` and `AuthScreen(registerMode: true)` for `/register`.

- [x] **Step 1: Write the auth screen**

`frontend/lib/features/auth/auth_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/glow_button.dart';
import 'package:frontend/shared/widgets/neon_background.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

/// Satu layar untuk /login dan /register: dua kartu kaca berdampingan,
/// kartu yang sesuai rute menyala.
class AuthScreen extends ConsumerStatefulWidget {
  final bool registerMode;

  const AuthScreen({super.key, required this.registerMode});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _loginKey = GlobalKey<FormState>();
  final _registerKey = GlobalKey<FormState>();

  final _loginUser = TextEditingController();
  final _loginPass = TextEditingController();
  final _regName = TextEditingController();
  final _regUser = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();

  String? _loginError;
  String? _registerError;
  bool _busy = false;

  @override
  void dispose() {
    _loginUser.dispose();
    _loginPass.dispose();
    _regName.dispose();
    _regUser.dispose();
    _regEmail.dispose();
    _regPass.dispose();
    super.dispose();
  }

  String _message(Object e, String fallback) {
    if (e is ApiException) {
      if (e.isRateLimited) {
        return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
      }
      return e.message;
    }
    return fallback;
  }

  Future<void> _login() async {
    if (!(_loginKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _loginError = null;
    });
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .login(_loginUser.text.trim(), _loginPass.text);
      if (!mounted) return;
      final auth = ref.read(authNotifierProvider);
      context.go(auth.isAdmin ? '/admin' : '/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() => _loginError = _message(e, 'Gagal masuk.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register() async {
    if (!(_registerKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _registerError = null;
    });
    try {
      await ref.read(authNotifierProvider.notifier).register(
            username: _regUser.text.trim(),
            email: _regEmail.text.trim(),
            password: _regPass.text,
            fullName: _regName.text.trim().isEmpty ? null : _regName.text.trim(),
          );
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() => _registerError = _message(e, 'Gagal mendaftar.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  children: [
                    const _Brand(),
                    const SizedBox(height: 32),
                    ResponsiveLayout(
                      desktop: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _loginCard(active: !widget.registerMode)),
                          const SizedBox(width: 24),
                          Expanded(child: _registerCard(active: widget.registerMode)),
                        ],
                      ),
                      mobile: Column(
                        children: [
                          _loginCard(active: !widget.registerMode),
                          const SizedBox(height: 20),
                          _registerCard(active: widget.registerMode),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextButton(
                      onPressed: () => context.go('/gallery'),
                      child: const Text('Jelajahi galeri tanpa akun'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginCard({required bool active}) {
    return _AuthCard(
      title: 'Login',
      subtitle: 'Masuk untuk mengelola portofolio.',
      active: active,
      error: _loginError,
      formKey: _loginKey,
      fields: [
        _Field(
          controller: _loginUser,
          hint: 'Username',
          icon: Icons.person_outline_rounded,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Username wajib diisi' : null,
        ),
        _Field(
          controller: _loginPass,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
        ),
      ],
      ctaLabel: 'Login',
      onCta: _busy ? null : _login,
      footer: TextButton(
        onPressed: () {},
        child: const Text('Lupa password?', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _registerCard({required bool active}) {
    return _AuthCard(
      title: 'Register',
      subtitle: 'Buat akun dan mulai bangun portofolio.',
      active: active,
      error: _registerError,
      formKey: _registerKey,
      fields: [
        _Field(
          controller: _regName,
          hint: 'Nama lengkap',
          icon: Icons.badge_outlined,
        ),
        _Field(
          controller: _regUser,
          hint: 'Username',
          icon: Icons.person_outline_rounded,
          validator: (v) {
            final t = v?.trim() ?? '';
            if (!RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(t)) {
              return '3-30 karakter: huruf kecil, angka, underscore';
            }
            return null;
          },
        ),
        _Field(
          controller: _regEmail,
          hint: 'Email',
          icon: Icons.alternate_email_rounded,
          validator: (v) {
            final t = v?.trim() ?? '';
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),
        _Field(
          controller: _regPass,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          validator: (v) =>
              (v == null || v.length < 8) ? 'Minimal 8 karakter' : null,
        ),
      ],
      ctaLabel: 'Register',
      onCta: _busy ? null : _register,
      footer: TextButton(
        onPressed: () => context.go('/login'),
        child: const Text('Sudah punya akun?', style: TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppColors.indigo.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'F',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'FolioSpace',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _Field {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.validator,
  });
}

class _AuthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool active;
  final String? error;
  final GlobalKey<FormState> formKey;
  final List<_Field> fields;
  final String ctaLabel;
  final VoidCallback? onCta;
  final Widget footer;

  const _AuthCard({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.error,
    required this.formKey,
    required this.fields,
    required this.ctaLabel,
    required this.onCta,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: active
              ? AppColors.cyan.withValues(alpha: 0.55)
              : Colors.transparent,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.indigo.withValues(alpha: 0.35),
                  blurRadius: 40,
                  spreadRadius: -8,
                ),
              ]
            : null,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppText.title.copyWith(fontSize: 24)),
              const SizedBox(height: 4),
              Text(subtitle, style: AppText.caption),
              const SizedBox(height: 20),
              for (var i = 0; i < fields.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                TextFormField(
                  controller: fields[i].controller,
                  obscureText: fields[i].obscure,
                  validator: fields[i].validator,
                  decoration: InputDecoration(
                    hintText: fields[i].hint,
                    prefixIcon: Icon(fields[i].icon, size: 19),
                  ),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 14),
                _ErrorNote(message: error!),
              ],
              const SizedBox(height: 20),
              GlowButton(
                label: ctaLabel,
                onPressed: onCta,
                expand: true,
                icon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: 6),
              Center(child: footer),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorNote extends StatelessWidget {
  final String message;

  const _ErrorNote({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [x] **Step 2: Point the router at it**

In `frontend/lib/core/routes/app_router.dart`, replace the two page imports with:

```dart
import 'package:frontend/features/auth/auth_screen.dart';
```

and the two routes with:

```dart
      GoRoute(
        path: '/login',
        builder: (_, __) => const AuthScreen(registerMode: false),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const AuthScreen(registerMode: true),
      ),
```

- [x] **Step 3: Delete the old pages and restyle `auth_layout.dart`**

```powershell
cd E:\Documents\GitHub\my-portofolio\frontend\lib\features\auth
git rm login_page.dart register_page.dart
```

`auth_layout.dart` is no longer imported by anything. Keep it only if you intend to reuse the side panel; otherwise `git rm auth_layout.dart`. The spec lists it as absorbed — delete it.

- [x] **Step 4: Verify**

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter analyze`
Expected: `No issues found!`

- [x] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(auth): single neon auth screen with inline rate-limit notices"
```

---

### Task 6: Public portfolio

**Files:**
- Rewrite: `frontend/lib/features/public_portfolio/profile_page.dart`
- Create: `frontend/lib/features/public_portfolio/widgets/glass_navbar.dart`
- Create: `frontend/lib/features/public_portfolio/widgets/hero_section.dart`
- Create: `frontend/lib/features/public_portfolio/widgets/skills_section.dart`
- Create: `frontend/lib/features/public_portfolio/widgets/experience_timeline.dart`
- Create: `frontend/lib/features/public_portfolio/widgets/projects_grid.dart`
- Create: `frontend/lib/features/public_portfolio/widgets/project_showcase_dialog.dart`
- Modify: `frontend/lib/features/public_portfolio/widgets/contact_section.dart`

**Interfaces:**
- Consumes: `userProfileProvider(slug)`, `userSkillsProvider(slug)`, `userProjectsProvider(slug)`, `userExperiencesProvider(slug)`, `UserModel`, `SkillModel`, `ProjectModel`, `ProjectMediaModel`, `ExperienceModel`, `AppNetworkImage`, `NeonChip`, `GlassCard`, `HoverScale`, `GlowButton`, `NeonBackground`, `ResponsiveLayout`.
- Produces:
  - `GlassNavbar({required List<NavTarget> items, required ValueChanged<int> onSelect, required int activeIndex, VoidCallback? onHireMe, String? avatarUrl, String? initials})`
  - `NavTarget({required String label, required GlobalKey anchor})`
  - `HeroSection({required UserModel user, required VoidCallback onHireMe, required void Function(String url) onOpenUrl})`
  - `SkillsSection({required List<SkillModel> skills})`
  - `ExperienceTimeline({required List<ExperienceModel> experiences})`
  - `ProjectsGrid({required List<ProjectModel> projects, required void Function(ProjectModel) onOpen})`
  - `ProjectShowcaseDialog.show(BuildContext, ProjectModel, void Function(String) onOpenUrl)`

- [x] **Step 1: Write `glass_navbar.dart`**

```dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/glow_button.dart';

class NavTarget {
  final String label;
  final GlobalKey anchor;

  const NavTarget({required this.label, required this.anchor});
}

/// Navbar lengket dengan latar kaca. Pil aktif digarisbawahi.
class GlassNavbar extends StatelessWidget {
  final List<NavTarget> items;
  final ValueChanged<int> onSelect;
  final int activeIndex;
  final VoidCallback? onHireMe;
  final String? avatarUrl;
  final String? initials;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onMenuTap;

  const GlassNavbar({
    super.key,
    required this.items,
    required this.onSelect,
    required this.activeIndex,
    this.onHireMe,
    this.avatarUrl,
    this.initials,
    this.onAvatarTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 900;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1020).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              _Logo(initials: initials),
              if (wide) ...[
                const SizedBox(width: 20),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        _NavPill(
                          label: items[i].label,
                          active: i == activeIndex,
                          onTap: () => onSelect(i),
                        ),
                    ],
                  ),
                ),
                if (onHireMe != null)
                  GlowButton(
                    label: 'Hire Me',
                    icon: Icons.send_rounded,
                    onPressed: onHireMe,
                  ),
                const SizedBox(width: 10),
                _Avatar(
                  url: avatarUrl,
                  initials: initials,
                  onTap: onAvatarTap,
                ),
              ] else ...[
                const Spacer(),
                if (onAvatarTap != null)
                  _Avatar(
                    url: avatarUrl,
                    initials: initials,
                    onTap: onAvatarTap,
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.menu_rounded),
                  color: AppColors.ink,
                  tooltip: 'Menu',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String? initials;

  const _Logo({this.initials});

  @override
  Widget build(BuildContext context) {
    final text = (initials == null || initials!.isEmpty) ? 'F' : initials!;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'FolioSpace',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ],
    );
  }
}

class _NavPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusField),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.ink : AppColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 2,
                width: active ? 18 : 0,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String? initials;
  final VoidCallback onTap;

  const _Avatar({this.url, this.initials, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
          ),
          child: ClipOval(
            child: AppNetworkImage(url: url, width: 36, height: 36),
          ),
        ),
      ),
    );
  }
}
```

- [x] **Step 2: Write `hero_section.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/glow_button.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class HeroSection extends StatelessWidget {
  final UserModel user;
  final VoidCallback onHireMe;
  final void Function(String url) onOpenUrl;

  const HeroSection({
    super.key,
    required this.user,
    required this.onHireMe,
    required this.onOpenUrl,
  });

  String get _name => (user.fullName ?? '').trim().isEmpty
      ? user.username
      : user.fullName!.trim();

  String get _initials {
    final parts = _name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: ResponsiveLayout(
        desktop: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(url: user.avatarUrl, initials: _initials, size: 116),
            const SizedBox(width: 24),
            Expanded(child: _identity(compact: false)),
            const SizedBox(width: 24),
            SizedBox(width: 190, child: _actions()),
          ],
        ),
        mobile: Column(
          children: [
            _Avatar(url: user.avatarUrl, initials: _initials, size: 92),
            const SizedBox(height: 16),
            _identity(compact: true),
            const SizedBox(height: 18),
            _actions(),
          ],
        ),
      ),
    );
  }

  Widget _identity({required bool compact}) {
    return Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          _name,
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: AppText.display.copyWith(fontSize: compact ? 26 : 34),
        ),
        const SizedBox(height: 6),
        Text(
          user.headline ?? 'Full-Stack Developer',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: AppColors.cyan,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        if ((user.bio ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            user.bio!,
            maxLines: compact ? 4 : 3,
            overflow: TextOverflow.ellipsis,
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: AppText.body,
          ),
        ],
        const SizedBox(height: 14),
        _Socials(
          email: user.email,
          onOpenUrl: onOpenUrl,
          centered: compact,
        ),
      ],
    );
  }

  Widget _actions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowButton(
          label: 'Hire Me',
          icon: Icons.send_rounded,
          onPressed: onHireMe,
          expand: true,
        ),
        if ((user.resumeUrl ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          GlowButton(
            label: 'Download CV',
            icon: Icons.download_rounded,
            variant: GlowButtonVariant.glass,
            onPressed: () => onOpenUrl(user.resumeUrl!),
            expand: true,
          ),
        ],
        const SizedBox(height: 10),
        GlowButton(
          label: 'Email',
          icon: Icons.mail_outline_rounded,
          variant: GlowButtonVariant.ghost,
          onPressed: () => onOpenUrl('mailto:${user.email}'),
          expand: true,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String initials;
  final double size;

  const _Avatar({
    required this.url,
    required this.initials,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brandGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.5),
            blurRadius: 34,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bg,
        ),
        child: (url ?? '').isEmpty
            ? Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.indigo.withValues(alpha: 0.25),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: size * 0.34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              )
            : AppNetworkImage(
                url: url,
                width: size,
                height: size,
                shape: BoxShape.circle,
              ),
      ),
    );
  }
}

class _Socials extends StatelessWidget {
  final String email;
  final void Function(String) onOpenUrl;
  final bool centered;

  const _Socials({
    required this.email,
    required this.onOpenUrl,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      (Icons.mail_outline_rounded, 'mailto:$email'),
      (Icons.language_rounded, 'https://github.com'),
      (Icons.work_outline_rounded, 'https://linkedin.com'),
    ];

    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        for (final (icon, url) in items)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onOpenUrl(url),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Icon(icon, size: 15, color: AppColors.body),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

- [x] **Step 3: Write `skills_section.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/shared/widgets/neon_chip.dart';

class SkillsSection extends StatelessWidget {
  final List<SkillModel> skills;

  const SkillsSection({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final s in skills)
          NeonChip(
            label: s.name,
            icon: _iconFor(s.category),
          ),
      ],
    );
  }

  IconData? _iconFor(String? category) {
    switch ((category ?? '').toLowerCase()) {
      case 'mobile':
        return Icons.phone_iphone_rounded;
      case 'frontend':
        return Icons.web_rounded;
      case 'backend':
        return Icons.dns_outlined;
      case 'tools':
      case 'devops':
        return Icons.terminal_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }
}
```

- [x] **Step 4: Write `experience_timeline.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Timeline dengan gutter tanggal di kiri, garis + titik di tengah.
class ExperienceTimeline extends StatelessWidget {
  final List<ExperienceModel> experiences;

  const ExperienceTimeline({super.key, required this.experiences});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _stamp(DateTime? d) =>
      d == null ? '—' : '${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < experiences.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 92,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, right: 12),
                    child: Text(
                      _stamp(experiences[i].startDate),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 18,
                  child: Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      if (i < experiences.length - 1)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          experiences[i].role,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          experiences[i].company,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((experiences[i].description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            experiences[i].description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              color: AppColors.body,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
```

- [x] **Step 5: Write `projects_grid.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/hover_scale.dart';

class ProjectsGrid extends StatelessWidget {
  final List<ProjectModel> projects;
  final void Function(ProjectModel) onOpen;

  const ProjectsGrid({
    super.key,
    required this.projects,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 250,
      ),
      itemCount: projects.length,
      itemBuilder: (_, i) => _ProjectCard(
        project: projects[i],
        onTap: () => onOpen(projects[i]),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      onTap: onTap,
      child: GlassCard(
        blur: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppNetworkImage(
                url: project.coverImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.summary ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.body,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final s in (project.skills ?? []).take(3))
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.indigo.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            s.name,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.body,
                            ),
                          ),
                        ),
                      const Spacer(),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 14,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [x] **Step 6: Write `project_showcase_dialog.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/glow_button.dart';

class ProjectShowcaseDialog extends StatefulWidget {
  final ProjectModel project;
  final void Function(String url) onOpenUrl;

  const ProjectShowcaseDialog({
    super.key,
    required this.project,
    required this.onOpenUrl,
  });

  static Future<void> show(
    BuildContext context,
    ProjectModel project,
    void Function(String url) onOpenUrl,
  ) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => ProjectShowcaseDialog(
        project: project,
        onOpenUrl: onOpenUrl,
      ),
    );
  }

  @override
  State<ProjectShowcaseDialog> createState() => _ProjectShowcaseDialogState();
}

class _ProjectShowcaseDialogState extends State<ProjectShowcaseDialog> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _media {
    final urls = <String>[
      if ((widget.project.coverImageUrl ?? '').isNotEmpty)
        widget.project.coverImageUrl!,
      ...(widget.project.media ?? []).map((m) => m.mediaUrl),
    ];
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final media = _media;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width > 900;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 860,
          maxHeight: size.height * 0.88,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: wide ? 16 / 8 : 16 / 10,
                    child: media.isEmpty
                        ? Container(
                            color: Colors.white.withValues(alpha: 0.05),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_outlined,
                              size: 44,
                              color: AppColors.muted,
                            ),
                          )
                        : PageView.builder(
                            controller: _controller,
                            onPageChanged: (i) => setState(() => _index = i),
                            itemCount: media.length,
                            itemBuilder: (_, i) => AppNetworkImage(
                              url: media[i],
                              width: double.infinity,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  if (media.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < media.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _index ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? AppColors.cyan
                                    : Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: AppText.title),
                    if ((p.summary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(p.summary!, style: AppText.body),
                    ],
                    if ((p.keyFeatures ?? []).isNotEmpty) ...[
                      const SizedBox(height: 14),
                      for (final f in p.keyFeatures!.take(5))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 15,
                                color: AppColors.cyan,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  f,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.body,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if ((p.liveUrl ?? '').isNotEmpty)
                          GlowButton(
                            label: 'Live Demo',
                            icon: Icons.language_rounded,
                            onPressed: () => widget.onOpenUrl(p.liveUrl!),
                          ),
                        if ((p.githubUrl ?? '').isNotEmpty)
                          GlowButton(
                            label: 'Repository',
                            icon: Icons.code_rounded,
                            variant: GlowButtonVariant.glass,
                            onPressed: () => widget.onOpenUrl(p.githubUrl!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [x] **Step 7: Rewrite `profile_page.dart`**

The page owns scroll anchors, the scroll-spy, and the desktop/mobile shell. Replace the whole file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/auth_providers.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/features/public_portfolio/widgets/contact_section.dart';
import 'package:frontend/features/public_portfolio/widgets/experience_timeline.dart';
import 'package:frontend/features/public_portfolio/widgets/glass_navbar.dart';
import 'package:frontend/features/public_portfolio/widgets/hero_section.dart';
import 'package:frontend/features/public_portfolio/widgets/project_showcase_dialog.dart';
import 'package:frontend/features/public_portfolio/widgets/projects_grid.dart';
import 'package:frontend/features/public_portfolio/widgets/skills_section.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/neon_background.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';
import 'package:frontend/shared/widgets/skeleton.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProfileScreen({super.key, required this.slug});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _scroll = ScrollController();
  final _anchors = List.generate(5, (_) => GlobalKey());
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_spy);
  }

  @override
  void dispose() {
    _scroll.removeListener(_spy);
    _scroll.dispose();
    super.dispose();
  }

  /// Section dianggap aktif bila tepi atasnya sudah melewati 140px.
  void _spy() {
    var next = 0;
    for (var i = 0; i < _anchors.length; i++) {
      final ctx = _anchors[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy < 140) next = i;
    }
    if (next != _active) setState(() => _active = next);
  }

  void _goTo(int index) {
    final ctx = _anchors[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launcher.launchUrl(
      uri,
      mode: launcher.LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL disalin ke clipboard')),
      );
    }
  }

  String _errorMessage(Object e) {
    if (e is ApiException) {
      if (e.isNotFound) {
        return 'Profil "${widget.slug}" tidak ditemukan atau belum dipublish.';
      }
      return 'Gagal memuat profil: ${e.message}';
    }
    return 'Gagal terhubung ke server.';
  }

  @override
  Widget build(BuildContext context) {
    final slug = widget.slug;
    final profile = ref.watch(userProfileProvider(slug));
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          bottom: false,
          child: profile.when(
            data: (user) => _content(user, auth.isAuthenticated),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: PageSkeleton(),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ErrorCard(
                  message: _errorMessage(e),
                  onRetry: () => ref.invalidate(userProfileProvider(slug)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(UserModel user, bool isAuth) {
    final slug = widget.slug;
    final name = (user.fullName ?? user.username).trim();
    final initials = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    final navItems = [
      NavTarget(label: 'Home', anchor: _anchors[0]),
      NavTarget(label: 'About', anchor: _anchors[1]),
      NavTarget(label: 'Projects', anchor: _anchors[2]),
      NavTarget(label: 'Expertise', anchor: _anchors[3]),
      NavTarget(label: 'Contact', anchor: _anchors[4]),
    ];

    final body = CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: GlassNavbar(
                  items: navItems,
                  activeIndex: _active,
                  onSelect: _goTo,
                  onHireMe: () => _goTo(4),
                  avatarUrl: user.avatarUrl,
                  initials: initials,
                  onAvatarTap: () => context.go(
                    isAuth ? '/dashboard' : '/login',
                  ),
                  onMenuTap: () => _showSheet(navItems, initials, user.avatarUrl, isAuth),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 48),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _anchor(_anchors[0], HeroSection(
                      user: user,
                      onHireMe: () => _goTo(4),
                      onOpenUrl: _openUrl,
                    )),
                    const SizedBox(height: 26),
                    _anchor(_anchors[1], _section(
                      title: 'About',
                      eyebrow: 'TENTANG',
                      child: Text(
                        (user.bio ?? '').isEmpty
                            ? 'Belum ada deskripsi.'
                            : user.bio!,
                        style: AppText.body,
                      ),
                    )),
                    const SizedBox(height: 26),
                    _anchor(_anchors[2], _projects(slug)),
                    const SizedBox(height: 26),
                    _anchor(_anchors[3], _skills(slug)),
                    const SizedBox(height: 26),
                    _anchor(_anchors[4], ContactSection(slug: slug)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return ResponsiveLayout(
      desktop: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SideRail(),
          Expanded(child: body),
        ],
      ),
      mobile: body,
    );
  }

  Widget _anchor(GlobalKey key, Widget child) =>
      KeyedSubtree(key: key, child: child);

  Widget _section({
    required String title,
    required String eyebrow,
    required Widget child,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: AppText.eyebrow),
          const SizedBox(height: 6),
          Text(title, style: AppText.title.copyWith(fontSize: 22)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _projects(String slug) {
    final async = ref.watch(userProjectsProvider(slug));
    return _section(
      title: 'Projects',
      eyebrow: 'KARYA',
      child: async.when(
        data: (projects) => projects.isEmpty
            ? const Text('Belum ada proyek.', style: AppText.body)
            : ProjectsGrid(
                projects: projects.take(12).toList(),
                onOpen: (p) => ProjectShowcaseDialog.show(context, p, _openUrl),
              ),
        loading: () => const ListSkeleton(rows: 2),
        error: (e, _) => ErrorCard(
          message: 'Gagal memuat proyek: $e',
          onRetry: () => ref.invalidate(userProjectsProvider(slug)),
        ),
      ),
    );
  }

  Widget _skills(String slug) {
    final async = ref.watch(userSkillsProvider(slug));
    final expAsync = ref.watch(userExperiencesProvider(slug));
    return _section(
      title: 'Expertise',
      eyebrow: 'KEAHLIAN',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          async.when(
            data: (skills) => SkillsSection(skills: skills),
            loading: () => const SkillChipsSkeleton(),
            error: (e, _) => Text('Gagal memuat skill: $e', style: AppText.caption),
          ),
          const SizedBox(height: 22),
          const Text('Experience Timeline', style: AppText.heading),
          const SizedBox(height: 14),
          expAsync.when(
            data: (items) => items.isEmpty
                ? const Text('Belum ada pengalaman.', style: AppText.body)
                : ExperienceTimeline(experiences: items.take(10).toList()),
            loading: () => const ListSkeleton(rows: 3),
            error: (e, _) => Text(
              'Gagal memuat pengalaman: $e',
              style: AppText.caption,
            ),
          ),
        ],
      ),
    );
  }

  void _showSheet(
    List<NavTarget> items,
    String initials,
    String? avatar,
    bool isAuth,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0C1226),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++)
              ListTile(
                title: Text(items[i].label),
                onTap: () {
                  Navigator.of(context).pop();
                  _goTo(i);
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(isAuth ? 'Dashboard' : 'Login pemilik'),
              onTap: () {
                Navigator.of(context).pop();
                context.go(isAuth ? '/dashboard' : '/login');
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/gallery');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Rail tipis di kiri layar desktop: logo + ikon sosial.
class _SideRail extends StatelessWidget {
  const _SideRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      margin: const EdgeInsets.fromLTRB(12, 16, 0, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              'F',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.go('/gallery'),
            icon: const Icon(Icons.grid_view_rounded, size: 18),
            color: AppColors.muted,
            tooltip: 'Galeri',
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
```

- [x] **Step 8: Restyle `contact_section.dart`**

Keep the existing form logic and field set; change the container from `Card` to `GlassCard` and add an inline rate-limit notice. Concretely:

- Replace the `Card(child: Padding(padding: EdgeInsets.all(20), child: Form(...)))` wrapper with `GlassCard(padding: const EdgeInsets.all(22), child: Form(...))`.
- Add a `String? _notice;` field and a `bool _noticeIsError = false;` field.
- In `_submit`'s `catch`, set `_notice` instead of showing a snackbar:

```dart
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _noticeIsError = true;
        _notice = e is ApiException && e.isRateLimited
            ? 'Batas 5 pesan per menit tercapai. Coba lagi sebentar.'
            : friendlyError(e, 'Gagal mengirim pesan');
      });
    }
```

- On success set `_notice = 'Pesan terkirim. Kreator akan membalas via email.'` with `_noticeIsError = false`, and clear the controllers.
- Render the notice above the submit button:

```dart
              if (_notice != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: (_noticeIsError ? AppColors.danger : AppColors.success)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (_noticeIsError ? AppColors.danger : AppColors.success)
                          .withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _noticeIsError
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 16,
                        color: _noticeIsError
                            ? AppColors.danger
                            : AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _notice!,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: _noticeIsError
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
```

- Swap `FolioColors`/`FolioDarkColors` references for `AppColors`, and `dark ? a : b` for the single dark value.

- [x] **Step 9: Verify**

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter analyze`
Expected: `No issues found!`

- [x] **Step 10: Commit**

```bash
git add -A
git commit -m "feat(portfolio): neon glass public portfolio with sticky nav, hero, timeline, showcase dialog"
```

---

### Task 7: Gallery

**Files:**
- Rewrite: `frontend/lib/features/gallery/gallery_page.dart`

**Interfaces:**
- Consumes: `galleryProjectsProvider`, `ProjectModel`, `GlassCard`, `AppNetworkImage`, `HoverScale`, `NeonBackground`.
- Produces: `GalleryScreen` (same class name the router already imports).

- [x] **Step 1: Rewrite the page**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/hover_scale.dart';
import 'package:frontend/shared/widgets/neon_background.dart';
import 'package:frontend/shared/widgets/skeleton.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ProjectModel> _filter(List<ProjectModel> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            (p.summary ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(galleryProjectsProvider);

    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'F',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'FolioSpace',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Masuk'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _search,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: const InputDecoration(
                        hintText: 'Cari proyek, kreator, atau teknologi...',
                        prefixIcon: Icon(Icons.search_rounded, size: 19),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text('Public projects', style: AppText.title),
                    const SizedBox(height: 4),
                    Text(
                      'Karya yang sudah dipublish oleh para kreator.',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: 18),
                    async.when(
                      data: (all) {
                        final items = _filter(all);
                        if (items.isEmpty) {
                          return const EmptyCard(
                            title: 'Tidak ada hasil',
                            subtitle: 'Coba kata kunci lain.',
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 360,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 300,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, i) => _GalleryCard(project: items[i]),
                        );
                      },
                      loading: () => const ListSkeleton(rows: 4),
                      error: (e, _) => ErrorCard(
                        message: 'Gagal memuat galeri: $e',
                        onRetry: () =>
                            ref.invalidate(galleryProjectsProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final ProjectModel project;

  const _GalleryCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final owner = project.owner;
    final slug = owner?.profileSlug;
    return HoverScale(
      onTap: slug == null ? null : () => context.go('/u/$slug'),
      child: GlassCard(
        blur: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppNetworkImage(
                url: project.coverImageUrl,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.summary ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.body,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ClipOval(
                        child: AppNetworkImage(
                          url: owner?.avatarUrl,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          owner?.fullName ?? 'Kreator',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

This requires `owner` on `ProjectModel`. It is **not** in the model today, but the backend's `ProjectListResponse` sends it. Add to `frontend/lib/core/models/project_model.dart`:

```dart
  final ProjectOwnerModel? owner;
```

with the constructor parameter `this.owner,` and a new class in the same file:

```dart
@JsonSerializable()
class ProjectOwnerModel {
  @JsonKey(name: 'profile_slug') final String? profileSlug;
  @JsonKey(name: 'full_name') final String? fullName;
  @JsonKey(name: 'avatar_url') final String? avatarUrl;

  ProjectOwnerModel({this.profileSlug, this.fullName, this.avatarUrl});

  factory ProjectOwnerModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectOwnerModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectOwnerModelToJson(this);
}
```

Then regenerate: `cd frontend ; .\.fvm\flutter_sdk\bin\dart run build_runner build --delete-conflicting-outputs`

- [x] **Step 2: Verify**

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter analyze`
Expected: `No issues found!`

- [x] **Step 3: Commit**

```bash
git add -A
git commit -m "feat(gallery): neon gallery grid with client-side search and owner chips"
```

---

### Task 8: Dashboard shell and drag-reorder project grid

**Files:**
- Rewrite: `frontend/lib/features/dashboard_me/dashboard_shell.dart`
- Modify: `frontend/lib/features/dashboard_me/user_dashboard_page.dart` (project tab only)

**Interfaces:**
- Consumes: `authNotifierProvider`, `myProfileProvider`, `myProjectsProvider`, `apiServiceProvider`.
- Produces: `DashboardShell({required String title, required List<SidebarItem> items, required int selectedIndex, required ValueChanged<int> onSelect, required Widget child, Widget? actions})`; `SidebarItem` unchanged in shape (`label`, `icon`, `badge`).

- [x] **Step 1: Replace the custom sidebar with a collapsible `NavigationRail`**

In `dashboard_shell.dart`, delete `_SidebarTokens` and the `_sidebar` builder; render:

```dart
    final wide = MediaQuery.sizeOf(context).width > 900;

    final rail = NavigationRail(
      extended: _extended,
      minExtendedWidth: 210,
      backgroundColor: Colors.white.withValues(alpha: 0.04),
      indicatorColor: AppColors.indigo.withValues(alpha: 0.28),
      selectedIconTheme: const IconThemeData(color: AppColors.ink),
      unselectedIconTheme: const IconThemeData(color: AppColors.muted),
      selectedLabelTextStyle: const TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: AppColors.muted,
        fontSize: 12.5,
      ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: IconButton(
          onPressed: () => setState(() => _extended = !_extended),
          icon: Icon(
            _extended ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          ),
          color: AppColors.muted,
          tooltip: _extended ? 'Ciutkan' : 'Lebarkan',
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout_rounded),
              color: AppColors.muted,
              tooltip: 'Keluar',
            ),
          ),
        ),
      ),
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      destinations: [
        for (final item in items)
          NavigationRailDestination(
            icon: Badge(
              isLabelVisible: (item.badge ?? 0) > 0,
              label: Text('${item.badge ?? 0}'),
              backgroundColor: AppColors.danger,
              child: Icon(item.icon),
            ),
            label: Text(item.label),
          ),
      ],
    );
```

`DashboardShell` must become a `StatefulWidget` (or a `ConsumerStatefulWidget`) to hold `bool _extended = true;`. Keep the existing topbar, adding a status pill that reads `myProfileProvider`:

```dart
  Widget _statusPill(WidgetRef ref) {
    final published = ref.watch(myProfileProvider).valueOrNull?.isPublished ?? false;
    final color = published ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            published ? 'Live' : 'Draft',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
```

Use `rail` for `wide`; keep the existing `Drawer` path for mobile but swap its body to the same destinations list.

- [x] **Step 2: Replace the project list with a drag-reorder grid**

In `user_dashboard_page.dart`, rewrite `_projectsTab()` to use a `ReorderableGridView`-style layout. Flutter has no built-in reorderable grid, so implement with `DragTarget` dropzones over a `Wrap`:

```dart
  Future<void> _persistOrder(List<ProjectModel> ordered) async {
    final api = ref.read(apiServiceProvider);
    try {
      for (var i = 0; i < ordered.length; i++) {
        await api.updateMyProject(ordered[i].id, {'display_order': i});
      }
      ref.invalidate(myProjectsProvider);
    } catch (e) {
      _snack('Gagal menyimpan urutan: $e', error: true);
    }
  }

  Widget _dropzone(int index) {
    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        final from = details.data;
        if (from == index) return;
        final list = List<ProjectModel>.from(_localOrder);
        final moved = list.removeAt(from);
        list.insert(index, moved);
        setState(() => _localOrder = list);
        _persistOrder(list);
      },
      builder: (_, candidate, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 220,
        height: 132,
        decoration: BoxDecoration(
          color: candidate.isEmpty
              ? Colors.white.withValues(alpha: 0.03)
              : AppColors.cyan.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: candidate.isEmpty ? AppColors.glassBorder : AppColors.cyan,
            width: 1.4,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.file_upload_outlined,
                size: 22,
                color: candidate.isEmpty ? AppColors.muted : AppColors.cyan,
              ),
              const SizedBox(height: 6),
              Text(
                'Dropzones',
                style: TextStyle(
                  fontSize: 11.5,
                  color: candidate.isEmpty ? AppColors.muted : AppColors.cyan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
```

Each project card is wrapped in `Draggable<int>(data: index, feedback: Material(color: Colors.transparent, child: card), childWhenDragging: Opacity(opacity: 0.3, child: card), child: card)`, and the grid is a `Wrap(spacing: 14, runSpacing: 14)` interleaving cards and trailing dropzones.

Add `late List<ProjectModel> _localOrder;` and seed it in `initState` from `ref.read(myProjectsProvider)` inside a `ref.listen` on first data:

```dart
    ref.listen(myProjectsProvider, (prev, next) {
      next.whenData((list) {
        if (!_orderSeeded) {
          _orderSeeded = true;
          setState(() => _localOrder = List.of(list));
        }
      });
    });
```

- [x] **Step 3: Verify**

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter analyze`
Expected: `No issues found!`

- [x] **Step 4: Commit**

```bash
git add -A
git commit -m "feat(dashboard): NavigationRail shell, status pill, drag-reorder project grid"
```

---

### Task 9: Admin data table

**Files:**
- Modify: `frontend/lib/features/admin/admin_dashboard_page.dart`

**Interfaces:**
- Consumes: `adminUsersProvider`, `apiServiceProvider.adminUpdateUser`, existing create-user dialog.
- Produces: no new public API; the users tab is restyled.

- [x] **Step 1: Replace `_usersTab()` with a table**

Columns: `Name`, `Content Moderation`, `Draft/Live`, `Aksi`.

```dart
  Widget _usersTab(List<UserModel> users) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Admin Data Table', style: AppText.heading),
              const Spacer(),
              GlowButton(
                label: 'Add User',
                icon: Icons.add_rounded,
                onPressed: _createUser,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _headerRow(),
          const Divider(height: 18),
          for (final u in users) ...[
            _userRow(u),
            const Divider(height: 18),
          ],
        ],
      ),
    );
  }

  Widget _headerRow() {
    const style = TextStyle(
      fontSize: 11,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
    );
    return const Row(
      children: [
        Expanded(flex: 3, child: Text('NAMA', style: style)),
        Expanded(flex: 3, child: Text('MODERASI', style: style)),
        Expanded(flex: 2, child: Text('STATUS', style: style)),
        SizedBox(width: 48, child: Text('AKSI', style: style)),
      ],
    );
  }

  Widget _userRow(UserModel u) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              ClipOval(
                child: AppNetworkImage(
                  url: u.avatarUrl,
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  u.fullName ?? u.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            u.isActive ? 'Aktif' : 'Ditangguhkan',
            style: TextStyle(
              fontSize: 12,
              color: u.isActive ? AppColors.body : AppColors.warning,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Switch.adaptive(
            value: u.isPublished,
            activeThumbColor: AppColors.success,
            onChanged: (v) => _setUserField(
              u.id,
              {'is_published': v},
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: IconButton(
            onPressed: () => _deleteUser(u),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: AppColors.danger,
            tooltip: 'Hapus user',
          ),
        ),
      ],
    );
  }
```

Add `_deleteUser`:

```dart
  Future<void> _deleteUser(UserModel u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus user?'),
        content: Text(
          '${u.fullName ?? u.username} akan dihapus permanen. '
          'Semua proyek dan pesannya ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(apiServiceProvider).dio.delete('/admin/users/${u.id}');
      ref.invalidate(adminUsersProvider);
      _snack('User dihapus');
    } catch (e) {
      _snack('Gagal menghapus user: $e', error: true);
    }
  }
```

`ApiService` has no `deleteUser` method. Rather than reaching into `.dio`, add one to `core/network/api_service.dart`:

```dart
  Future<void> adminDeleteUser(int id) async {
    try {
      await _dio.delete('/admin/users/$id');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal hapus user');
    }
  }
```

and call `api.adminDeleteUser(u.id)`.

- [x] **Step 2: Verify**

Run: `cd frontend ; .\.fvm\flutter_sdk\bin\flutter analyze`
Expected: `No issues found!`

- [x] **Step 3: Commit**

```bash
git add -A
git commit -m "feat(admin): neon data table with moderation switches and delete"
```

---

### Task 10: Retint skeletons and final verification

**Files:**
- Modify: `frontend/lib/shared/widgets/skeleton.dart`

- [x] **Step 1: Retint the bones**

`Skeletonizer` resolves its shimmer from `SkeletonizerConfig.maybeOf(context)`, falling back to platform brightness. Task 2 already installs a dark config via `MaterialApp.router`'s `builder`, so skeletons inherit `Brightness.dark` and the `#141B31` container tint without touching `skeleton.dart`.

No edit is needed in this task unless a skeleton still renders light — in that case confirm the `SkeletonizerConfig` builder from Task 2 is present in `main.dart`.

- [x] **Step 2: Verify the whole app**

```powershell
cd E:\Documents\GitHub\my-portofolio\frontend
.\.fvm\flutter_sdk\bin\flutter analyze
.\.fvm\flutter_sdk\bin\flutter test
.\.fvm\flutter_sdk\bin\flutter build web
```

Expected: analyzer clean, tests pass, build succeeds.

- [x] **Step 3: Run the backend suite**

```powershell
cd E:\Documents\GitHub\my-portofolio\backend
.\.venv\Scripts\python -m pytest -v
```

Expected: all pass.

- [x] **Step 4: Smoke-test in a browser**

Start the backend, then `flutter run -d chrome`. Walk every route:

| Route | Check |
|---|---|
| `/login` | two cards, Login highlighted, inline error on bad password |
| `/register` | Register card highlighted, validation messages |
| `/gallery` | grid renders, search filters, card opens the owner's portfolio |
| `/u/<slug>` | sticky nav scroll-spy, hero, chips, timeline, project dialog with carousel and both link buttons |
| `/dashboard` | rail collapses, status pill matches publish state, drag-reorder persists after reload |
| `/admin` | table rows, moderation switch, delete confirm |

- [x] **Step 5: Capture screenshots**

Use Playwright at 1440×900 and 390×844 for each route, saving under `docs/superpowers/screenshots/`. Compare against the reference boards and note deviations.

- [x] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(ui): dark skeleton shimmer, final neon glass verification"
```

---

## Self-Review

**Spec coverage**

| Spec section | Task |
|---|---|
| §2 tokens, radii, glow | 2 |
| §3 structure | 1 |
| §4 shared kit | 3 |
| §5.1 auth | 5 |
| §5.2 public portfolio | 6 |
| §5.2.1 backend | 4 |
| §5.3 gallery | 7 |
| §5.4 dashboard + admin | 8, 9 |
| §6 data flow (publish invalidation, optimistic reorder) | 8 |
| §7.1 dependency | 3 |
| §7.2 ordering | Task numbering follows it |
| §7.3 skill gradients | 3 |
| §8 verification | 10 |

**Gaps found and closed during review**

1. `ProjectModel` had no `owner` field, but the gallery card needs an author and a slug to link to. Added in Task 7 with a `build_runner` step.
2. `ApiService` had no user-delete method, and Task 9 initially reached into `.dio` directly. Added `adminDeleteUser` to the service.
3. `usePathUrlStrategy` is **not** exported by `go_router`. It lives in `flutter_web_plugins`, which was only a transitive dependency. Task 2 now adds it to `pubspec.yaml` and imports `package:flutter_web_plugins/url_strategy.dart`.
4. `dashboard_shell.dart` was a `ConsumerWidget`; `NavigationRail`'s extended state requires a `StatefulWidget`. Task 8 states the conversion explicitly.
5. `SkeletonizerConfigData` has no `effect` parameter — `effect` belongs to the `Skeletonizer` widget, and `SkeletonizerConfig` is an `InheritedTheme` widget requiring `data` + `child`, not a `ThemeData` extension. Task 2 uses `brightness` + `containersColor`, which is what actually reaches every bone.

**Type consistency**

`ResponsiveLayout`, `GlassCard`, `GlowButton`, `NeonChip`, `AppNetworkImage`, `HoverScale`, `NavTarget`, `skillGradient` are each defined once in Task 3 or Task 6 and referenced with identical signatures thereafter. `AuthScreen(registerMode:)` matches the router call. `ProjectShowcaseDialog.show` matches its call site in `profile_page.dart`.


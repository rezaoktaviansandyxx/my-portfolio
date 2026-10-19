# Neon Glass Redesign — Design Spec

**Date:** 2026-10-19
**Status:** Approved (rev. 2 — self-review added §5.2.1)
**Scope:** Frontend (`frontend/`), plus one additive backend schema change
(§5.2.1) that the approved design depends on.

---

## 1. Goal

Replace the current light-dominant indigo theme with a dark neon / glassmorphism
design system across every surface, and restructure `lib/` into
`core/` + `features/` + `shared/`.

Reference: two design boards supplied by the user, covering (1) auth pages,
(2) public portfolio `/u/:slug`, (3) gallery `/gallery`, and (4) dashboard &
admin panel.

---

## 2. Design tokens

The theme becomes **dark only**. The light palette (`FolioColors`) is deleted;
`themeMode: ThemeMode.dark` is forced. This halves the styling surface and
matches the reference exactly.

### 2.1 Color

| Token | Value | Use |
|---|---|---|
| `bg` | `#060A18` | Page base |
| `bgAlt` | `#0B1024` | Radial glow layer |
| `surface` | `white @ 5%` | Glass card fill |
| `border` | `white @ 10%` | Glass card border |
| `violet` | `#7C3AED` | Gradient start |
| `indigo` | `#4F46E5` | Gradient mid |
| `blue` | `#3B82F6` | Gradient end |
| `cyan` | `#22D3EE` | Hover, links, focus ring |
| `ink` | `#EDF1FB` | Primary text |
| `body` | `#AEBAD4` | Body text |
| `muted` | `#93A0BD` | Labels, hints |
| `success` | `#34D399` | Live pill, health OK |
| `warning` | `#FBBF24` | Draft pill |
| `danger` | `#F87171` | Delete, errors, rate-limit notice |

Primary brand gradient: `LinearGradient([violet, indigo, blue])`.

### 2.2 Radii

| Element | Radius |
|---|---|
| Card / dialog | 20 |
| Input, button | 14 |
| Pill / chip | 999 |

### 2.3 Elevation

Glow is `BoxShadow` with the accent color at low alpha, used on primary
buttons, the avatar ring, and the active nav pill. Glass surfaces carry no
`elevation`; depth comes from the blur + border.

---

## 3. Target package structure

```
lib/
├── main.dart
├── core/
│   ├── models/         user_model, project_model, skill_model,
│   │                   experience_model (+ .g.dart moved alongside)
│   ├── network/        api_config, api_service, auth_service,
│   │                   app_providers
│   ├── routes/         app_router
│   └── theme/          app_theme, app_colors, app_text
├── features/
│   ├── auth/                auth_screen (login + register cards),
│   │                       auth_layout, auth_providers
│   ├── public_portfolio/    profile_page
│   │   └── widgets/         glass_navbar, hero_section, skills_section,
│   │                       experience_timeline, projects_grid,
│   │                       project_showcase_dialog, contact_section
│   ├── gallery/             gallery_page
│   ├── dashboard_me/        user_dashboard_page, dashboard_shell,
│   │                       dashboard_dialogs
│   └── admin/               admin_dashboard_page
└── shared/
    ├── widgets/         glass_card, hover_scale, responsive_layout,
    │                    neon_background, glow_button, neon_chip,
    │                    section_header, network_image, folio_field,
    │                    folio_widgets, skeleton, errors
    └── constants/
```

`.g.dart` files move together with their model; the `part` directives stay
valid, so no `build_runner` re-run is required for the move itself.

### 3.1 Routes (unchanged)

`/u/:slug`, `/gallery`, `/login`, `/register`, `/dashboard`, `/admin`, `/`.

The reference board labels the dashboard `/me`, but renaming the existing
`/dashboard` route buys no visual gain and risks breaking bookmarks. Routes
are kept. Auth gate and redirect logic in `app_router.dart` are untouched.

---

## 4. Shared widget kit

All new widgets are added under `shared/widgets/` and used by every feature.

| Widget | Contract |
|---|---|
| `NeonBackground` | Radial violet/indigo glows + faint grid lines. Wraps public and auth page bodies. |
| `GlassCard` | `BackdropFilter` blur 16, fill `white @ 5%`, border `white @ 10%`, radius 20. |
| `HoverScale` | `MouseRegion` with `SystemMouseCursors.click`; on hover animates `translateY(-4)` + border brightens to `cyan @ 35%`. |
| `ResponsiveLayout` | `LayoutBuilder`; `> 900` → desktop, `<= 900` → mobile/tablet. |
| `GlowButton` | Gradient fill, cyan glow shadow; variants `filled`, `glass`, `ghost`. |
| `NeonChip` | Gradient pill for skills; gradient derived from the skill name (see §7.3). |
| `NetworkImage` | `cached_network_image` with glass placeholder + error fallback. Replaces every `Image.network` and `CircleAvatar(backgroundImage:)`. |
| `CustomScrollBehavior` | `dragDevices` includes `touch`, `mouse`, `trackpad`. |

`main()` additionally calls `usePathUrlStrategy()` so web URLs have no `#`.

Existing skeletons in `shared/widgets/skeleton.dart` are retinted to the dark
palette; new bone shapes are added for the hero, timeline, and project grid.

---

## 5. Surface specifications

### 5.1 Auth — `/login`, `/register`

A single `AuthScreen` renders **two glass cards side by side** over a split
violet/blue gradient backdrop, per the reference board.

- Route determines which card is lit: `/register` glows the Register card.
- Each card: title, inputs, gradient submit button, "L forgot your password?"
  link below.
- Below 900px the cards stack vertically.
- `POST /auth/login` and `POST /auth/register` stay wired to the existing
  `AuthService`. The backend rate-limits them (`@limiter.limit("10/minute")`
  on login, `("3/hour")` on register), so a `429` renders as an **inline red
  notice inside the card** instead of a floating snackbar — the board
  annotates rate-limiting directly under each call.
- `auth_layout.dart` is absorbed into `features/auth/` and restyled; the
  standalone `login_page.dart` / `register_page.dart` collapse into a single
  `auth_screen.dart` that renders both cards.

### 5.2 Public portfolio — `/u/:slug`

**Sticky glass navbar.** Logo left. Centered pills `Home · About · Projects ·
Expertise · Fullstack`. The active pill is underlined, driven by a scroll
listener over section keys. Right side: gallery icon → `/gallery`, plus avatar
or a login button when unauthenticated.

**Hero.** One wide glass card laid out horizontally:
`avatar in a glowing gradient ring` → `name + headline + bio + social icons`
→ three stacked CTAs at the far right: **Hire Me** (scrolls to contact),
**Download CV** (opens `resume_url`, hidden when absent), **Email**
(`mailto:` the owner's address).

`GET /public/u/{slug}/profile` returns `UserResponse`, which includes `email`,
so the address is always available — the Email button needs no fallback.

Below 900px this collapses to the mobile variant.

**Skills.** Gradient chips in a `Wrap`.

**Experience timeline.** The board's layout, not an indented card list:
year gutter on the far left (`26 Feb`, `9 Des 2011`), a dot on a vertical
line, and content to the right. Mobile keeps the gutter but narrows it.

**Projects.** `GridView` with `SliverGridDelegateWithMaxCrossAxisExtent`
(`maxCrossAxisExtent: 380`) so column count is derived from width rather than
hardcoded. Each card lifts on hover. Tapping opens a glass `showDialog` with a
media carousel plus **Live Demo** and **Repository** buttons.

### 5.2.1 Required backend change

The approved design needs project media and outbound links on the public
portfolio, and the public API does not currently serve either.

`ProjectListResponse` (`backend/app/schemas/project.py`) exposes only `id`,
`title`, `slug`, `summary`, `cover_image_url`, `is_featured`, `display_order`,
`skills`, and `owner`. It omits `live_url`, `github_url`, and `media`.

Two consequences:

1. **Existing bug:** the Live Demo / Repository buttons on the public grid have
   always rendered nothing, because `ProjectModel.liveUrl` and `githubUrl`
   deserialize to `null` from `GET /public/u/{slug}/projects`.
2. **Blocker:** the media carousel has no data source.

The fix is additive and backward compatible — add three optional fields to
`ProjectListResponse`:

```python
class ProjectListResponse(BaseModel):
  # ... existing fields unchanged ...
  live_url: Optional[str] = None
  github_url: Optional[str] = None
  media: List[ProjectMediaResponse] = []
```

`Project.media` is a default lazy relationship, so adding it to a list response
introduces an N+1 query. Both public list endpoints must add
`selectinload(Project.media)` to their query to keep it to one extra round trip.

No new endpoint, no migration, no change to `/me` or `/admin` responses.

**Mobile.** Not a hamburger drawer: a **bottom navigation bar**
(`Home · Skills · Projects · Experience`), with the top navbar reduced to
logo + gallery icon + menu.

> Note: the board labels the bottom bar `Home · Projects · Expertise ·
> Education`. We have skills and experiences but no education data, so the
> items map to our actual sections.

**Contact.** Glass form (name, email, subject, message). A `429` shows an
inline rate-limit notice in the form rather than a snackbar.

### 5.3 Gallery — `/gallery`

Search field across the top, `Public projects` heading, responsive grid of
glass cards (3-up desktop): gradient cover, title, 2-line description, author
chip.

The search filters the already-fetched set client-side —
`GET /public/gallery/projects` exposes no query parameter, so no API change is
in scope.

### 5.4 Dashboard & admin

**Shell.** `NavigationRail` sidebar — `Dashboard · Edit Profile · Projects ·
Settings` — collapsible on desktop, `Drawer` on mobile. Topbar carries the
page title, a mail icon, a bell with unread count, and the avatar.

**Edit Profile card.** Inline-editable name and site fields with a save
button. **Draft** and **Live** toggles call `POST /me/unpublish` and
`POST /me/publish`; the resulting state is mirrored into the topbar status
pill (green **Live** / amber **Draft**).

**Project list.** A **drag-and-drop reorder grid** of dashed dropzones, per
the board, replacing the current list. Reordering persists via
`PATCH /me/projects/{id}` writing `display_order` — the field already exists
on `ProjectModel`.

**Admin data table.** Columns `Name · Content Moderation · Draft/Live ·`
(delete). Row switches call `PATCH /admin/users/{id}`, the trash icon calls
`DELETE /admin/users/{id}`, and `+ Add User` opens the existing create dialog.

---

## 6. Data flow

Unchanged. All screens keep reading through the existing Riverpod providers
(`userProfileProvider`, `userProjectsProvider`, `galleryProjectsProvider`,
`myProjectsProvider`, …). The redesign touches presentation only.

Two behavioral notes:

- Publish/unpublish toggles must invalidate `myProfileProvider` after success
  so the topbar pill and the profile card agree.
- Drag-reorder is optimistic — update local list order immediately, PATCH each
  moved project, and surface a snackbar if any PATCH fails.

---

## 7. Implementation notes

### 7.1 Dependencies

Add `cached_network_image`. Everything else already exists (`go_router`,
`flutter_riverpod`, `dio`, `skeletonizer`).

### 7.2 Ordering

1. Theme tokens + `shared/widgets` kit + `usePathUrlStrategy`
2. `lib/` restructure (pure file moves + import rewrites)
3. Backend schema change (§5.2.1) + `selectinload`
4. Auth screen
5. Public portfolio
6. Gallery
7. Dashboard shell + project drag-reorder
8. Admin table
9. Dark retint of all remaining skeletons

Theme lands first because every later step depends on it; the restructure
lands second so subsequent work happens in final locations. The backend change
lands before the public portfolio, whose carousel depends on it.

### 7.3 Skill chip gradients

No per-skill color is stored in the backend. Derive a stable hue by hashing
the skill name, so the same skill always renders the same color across
sessions.

---

## 8. Verification

- `flutter analyze` reports no errors or warnings.
- `flutter build web` completes.
- `pytest` in `backend/` still passes, covering the §5.2.1 schema change.
- With the backend running, every route renders: `/login`, `/register`,
  `/gallery`, `/u/<slug>`, `/dashboard`, `/admin`.
- A public project with media now returns `live_url`, `github_url`, and a
  non-empty `media` array from `GET /public/u/{slug}/projects`.
- Playwright screenshots at 1440px and 390px width for comparison against the
  reference boards.

---

## 9. Out of scope

- Backend changes beyond the single additive schema change in §5.2.1.
  In particular: no new endpoint, no database migration, no gallery search
  parameter.
- An education/academic section.
- A light theme.
- SEO meta-tag management.
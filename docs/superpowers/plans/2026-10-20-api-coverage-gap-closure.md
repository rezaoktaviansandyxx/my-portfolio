# API Coverage Gap Closure — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tutup 13 endpoint backend yang sudah ada di lapisan API Flutter tapi belum terpakai oleh UI, plus perbaiki 3 bug nyata yang ditemukan saat audit (`resume_url` relatif, invalidate media admin, admin hanya bisa bikin konten miliknya sendiri).

**Architecture:** Tidak ada perubahan struktur folder. Phase 1–2 murni frontend (widget upload reusable + wiring ke dialog/form yang sudah ada). Phase 3 adalah perubahan **aditif** backend (2 endpoint GET + `owner_id` opsional) lalu tab admin baru di frontend. Phase 4 menambah 2 endpoint upload milik user.

**Tech Stack:** Flutter Web 3.9.2 / FVM, flutter_riverpod 3.4.3, dio 5.11.1, `file_picker` (baru), FastAPI + SQLAlchemy + pytest.

**Baseline audit:** lihat daftar 55 endpoint di deskripsi task. Status sebelum plan: 42 dipakai UI, 13 belum.

## Global Constraints

- **Base URL** Dio = `ApiConfig.baseUrl`, yang sudah memuat prefix `/api/v1` (dari `.env` → `API_BASE_URL`). Jangan pernah menulis `/api/v1` di path service.
- **Backend melarang `multipart` tanpa `Content-Type` yang benar.** Allowlist di `backend/app/services/storage.py:8-13`: image `image/jpeg|image/png|image/webp`, dokumen `application/pdf`. Ekstensi `jpg|jpeg|png|webp` dan `pdf`. Batas `5 MB`. `MultipartFile` **wajib** diberi `contentType` eksplisit; default `application/octet-stream` akan ditolak 400.
- **`media_url` menerima `^(https?://|/static/)`** (`backend/app/routers/me.py:275`, `admin.py:160`). Simpan path `/static/...` apa adanya — jangan di-resolve saat disimpan.
- **Resolve URL hanya untuk ditampilkan.** `ApiConfig.resolveFileUrl` dipakai saat render image / membuka link.
- **Provider cache Dio sama.** `apiServiceProvider` memakai `dioProvider` yang sama dengan `AuthService`, jadi header `Authorization` sudah ikut. Jangan membuat `Dio()` baru di fitur.
- **Bahasa copy Indonesia**, mengikuti string yang sudah ada.
- **`flutter analyze` wajib 0 issue** dan `flutter test` hijau di setiap task.
- Jalankan Flutter lewat FVM: `frontend\.fvm\flutter_sdk\bin\flutter`.
- Backend test: `cd backend; python -m pytest`.

---

## File Structure

```
backend/app/routers/admin.py                     # +GET /skills, +GET /experiences, +owner_id opsional, +resume_url di AdminUserCreate
backend/app/routers/me.py                        # +POST /upload/resume
backend/app/schemas/auth.py                      # +avatar_url di AdminUserUpdate
backend/app/schemas/{project,skill,experience}.py # +owner_id di *Create
backend/tests/test_admin_content_listing.py      # NEW
backend/tests/test_admin_user_resume.py          # NEW
backend/tests/test_upload_my_resume.py           # NEW

frontend/pubspec.yaml                            # +file_picker
frontend/lib/shared/widgets/upload_field.dart    # NEW — tombol upload + field URL
frontend/lib/features/public_portfolio/widgets/hero_section.dart   # fix resume URL
frontend/lib/features/dashboard_me/dashboard_dialogs.dart          # +upload di dialog
frontend/lib/features/dashboard_me/user_dashboard_page.dart        # +avatar/resume upload
frontend/lib/features/admin/admin_dashboard_page.dart              # +invalidate, +tab konten
frontend/lib/features/dashboard_me/project_media_utils.dart        # NEW — saver bersama
frontend/lib/core/network/api_service.dart       # +uploadMyResume, +adminListSkills/Experiences
frontend/lib/core/network/app_providers.dart     # +adminSkills/Experiences providers
frontend/test/features/dashboard_me/upload_test.dart               # NEW
frontend/test/features/admin/admin_content_tab_test.dart           # NEW
```

---

# Phase 1 — Bug fix cepat (tanpa dependency baru)

Tidak butuh `file_picker`. Bisa dikerjakan dan dirilis lebih dulu.

### Task 1: `resolveFileUrl` untuk link CV publik

**Files:**
- Modify: `frontend/lib/features/public_portfolio/widgets/hero_section.dart:117`
- Test: `frontend/test/shared/resolve_file_url_test.dart` (NEW)

**Interfaces:**
- Consumes: `ApiConfig.resolveFileUrl(String? url) -> String` (sudah ada, `api_config.dart:10`).

**Kenapa:** backend mengirim `resume_url` relatif (`/static/uploads/resumes/x.pdf`, lihat `storage_service.save_file`). `profile_page.dart:100` memanggil `launcher.launchUrl(Uri.tryParse(url))` — `Uri.tryParse('/static/...')` menghasilkan URI tanpa scheme/host, sehingga `launchUrl` gagal dan user hanya dapat snackbar "URL disalin ke clipboard" dengan path relatif yang tidak bisa dibuka.

- [ ] **Step 1: Tulis test yang gagal**

Create `frontend/test/shared/resolve_file_url_test.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_config.dart';

void main() {
  setUpAll(
    () => dotenv.loadFromString(
      envString: 'API_BASE_URL=https://api.example.com/api/v1',
    ),
  );

  test('path /static/ dijadikan absolut terhadap origin, bukan base path', () {
    expect(
      ApiConfig.resolveFileUrl('/static/uploads/resumes/cv.pdf'),
      'https://api.example.com/static/uploads/resumes/cv.pdf',
    );
  });

  test('URL absolut dilewatkan apa adanya', () {
    expect(
      ApiConfig.resolveFileUrl('https://cdn.example.com/a.png'),
      'https://cdn.example.com/a.png',
    );
  });

  test('null / kosong menghasilkan string kosong', () {
    expect(ApiConfig.resolveFileUrl(null), '');
    expect(ApiConfig.resolveFileUrl('  '), '');
  });
}
```

- [ ] **Step 2: Jalankan test pengunci perilaku**

Run: `frontend\.fvm\flutter_sdk\bin\flutter test test/shared/resolve_file_url_test.dart` (workdir `frontend`)
Expected: PASS untuk ketiga test — `resolveFileUrl` memang sudah benar (`base.authority` = `api.example.com`, tanpa `/api/v1`). Test ini mengunci perilaku sebelum dipakai di hero. Kalau ada yang FAIL, **jangan** lanjut; perbaiki `api_config.dart` dulu.

- [ ] **Step 3: Pakai di hero section**

Di `frontend/lib/features/public_portfolio/widgets/hero_section.dart`, tambah import:

```dart
import 'package:frontend/core/network/api_config.dart';
```

Lalu ubah baris 117:

```dart
// sebelum
onPressed: () => onOpenUrl(user.resumeUrl!),
// sesudah
onPressed: () =>
    onOpenUrl(ApiConfig.resolveFileUrl(user.resumeUrl)),
```

- [ ] **Step 4: Jalankan analyze + test**

Run: `frontend\.fvm\flutter_sdk\bin\flutter analyze; frontend\.fvm\flutter_sdk\bin\flutter test`
Expected: `No issues found!` dan semua test hijau.

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/features/public_portfolio/widgets/hero_section.dart frontend/test/shared/resolve_file_url_test.dart
git commit -m "fix(portfolio): resolve relative resume_path before opening URL"
```

---

### Task 2: Invalidate daftar proyek admin setelah tambah media

**Files:**
- Modify: `frontend/lib/features/admin/admin_dashboard_page.dart:793-812`

**Kenapa:** `_addProjectMedia` (admin) tidak me-refresh provider setelah sukses, sedangkan versi user (`user_dashboard_page.dart:816`) memanggil `ref.invalidate(myProjectsProvider)`. Akibatnya user harus reload manual untuk melihat media baru.

- [ ] **Step 1: Tambah invalidate**

Di `frontend/lib/features/admin/admin_dashboard_page.dart`, dalam method `_addProjectMedia`, setelah `await ref.read(apiServiceProvider).adminAddProjectMedia(...)` selesai (yaitu tepat sebelum `_snack('Media ditambahkan');`), sisipkan:

```dart
      ref.invalidate(adminProjectsProvider);
      ref.invalidate(adminProjectsFilteredProvider);
```

Blok `try` lengkapnya menjadi:

```dart
    try {
      await ref
          .read(apiServiceProvider)
          .adminAddProjectMedia(
            p.id,
            mediaUrl: data['media_url']!,
            mediaType: data['media_type'] ?? 'image',
            caption: (data['caption']?.isEmpty ?? true)
                ? null
                : data['caption'],
          );
      ref.invalidate(adminProjectsProvider);
      ref.invalidate(adminProjectsFilteredProvider);
      _snack('Media ditambahkan');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal tambah media'), error: true);
    }
```

- [ ] **Step 2: Verifikasi tidak ada call site admin lain yang lupa invalidate**

Run: `Select-String -Path frontend\lib\features\admin\admin_dashboard_page.dart -Pattern "admin(AddProjectMedia|CreateProject|UpdateProject|DeleteProject|MarkMessageRead|DeleteMessage|CreateUser|UpdateUser)" -Context 0,6`
Expected: setiap pemanggilan mutasi diikuti `ref.invalidate(...)`. `_markRead`/`_deleteMessage` sudah invalidate `adminMessagesProvider` (baris 918-940) — biarkan.

- [ ] **Step 3: Analyze + test + commit**

```bash
frontend\.fvm\flutter_sdk\bin\flutter analyze
frontend\.fvm\flutter_sdk\bin\flutter test
git add frontend/lib/features/admin/admin_dashboard_page.dart
git commit -m "fix(admin): refresh project list after adding media"
```

---

# Phase 2 — Hidupkan 7 endpoint upload (6 di antaranya baru)

### Task 3: Tambah dependency `file_picker` + helper upload reusable

**Files:**
- Modify: `frontend/pubspec.yaml` (dependencies)
- Create: `frontend/lib/shared/widgets/upload_field.dart`
- Test: `frontend/test/features/dashboard_me/upload_test.dart` (NEW)

**Interfaces:**
- Produces:
  - `typedef UploadFn = Future<String> Function(MultipartFile file);`
  - `Future<MultipartFile?> pickFileAsMultipart({bool document = false})` — `null` bila user batal.
  - `class UploadField extends StatefulWidget` dengan `UploadField({required TextEditingController controller, required UploadFn upload, required String label, String? hint, bool document = false, IconData? icon})`.
- Dipakai oleh Task 4, 5, 6, 7, 8.

- [ ] **Step 1: Tambah dependency**

Di `frontend/pubspec.yaml`, tambahkan setelah `flutter_dotenv: ^6.0.1`:

```yaml
  file_picker: ^8.1.2
```

Lalu jalankan:

```bash
cd frontend; .\.fvm\flutter_sdk\bin\flutter pub get
```

Expected: `file_picker` ter-resolve.

- [ ] **Step 2: Tulis test helper yang gagal**

Create `frontend/test/features/dashboard_me/upload_test.dart`:

```dart
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/upload_field.dart';

void main() {
  test('contentType diturunkan dari ekstensi (bukan octet-stream)', () {
    expect(mimeForExtension('png'), 'image/png');
    expect(mimeForExtension('webp'), 'image/webp');
    expect(mimeForExtension('jpg'), 'image/jpeg');
    expect(mimeForExtension('JPG'), 'image/jpeg');
    expect(mimeForExtension('pdf'), 'application/pdf');
    expect(mimeForExtension('exe'), isNull);
  });

  test('multipart dibangun dengan nama file & contentType benar', () {
    final f = multipartFromBytes(
      Uint8List.fromList([1, 2, 3]),
      'cv.pdf',
      'application/pdf',
    );
    expect(f.filename, 'cv.pdf');
    expect(f.contentType.toString(), 'application/pdf');
  });

  testWidgets('tombol upload memanggil UploadFn dan mengisi controller', (
    tester,
  ) async {
    final controller = TextEditingController();
    MultipartFile? received;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadField(
            controller: controller,
            label: 'Avatar URL',
            hint: 'https://...',
            upload: (file) async {
              received = file;
              return '/static/uploads/u/1/avatars/a.png';
            },
            picker: () async => Uint8List.fromList([1, 2, 3]),
            fileName: () async => 'a.png',
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.upload_file_outlined));
    await tester.pumpAndSettle();

    expect(received?.filename, 'a.png');
    expect(controller.text, '/static/uploads/u/1/avatars/a.png');
  });

  testWidgets('upload gagal menampilkan pesan, controller tidak berubah', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'https://lama/x.png');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadField(
            controller: controller,
            label: 'Avatar URL',
            upload: (file) async => throw Exception('gagal'),
            picker: () async => Uint8List.fromList([1]),
            fileName: () async => 'x.png',
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.upload_file_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Gagal upload file'), findsOneWidget);
    expect(controller.text, 'https://lama/x.png');
  });
}
```

- [ ] **Step 3: Jalankan, pastikan gagal (file belum ada)**

Run: `frontend\.fvm\flutter_sdk\bin\flutter test test/features/dashboard_me/upload_test.dart`
Expected: FAIL — `Error: Couldn't resolve the package 'frontend/shared/widgets/upload_field.dart'`.

- [ ] **Step 4: Implementasi `upload_field.dart`**

Create `frontend/lib/shared/widgets/upload_field.dart`:

```dart
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/folio_field.dart';

/// Fungsi upload yang disuntikkan dari pemanggil, mis.
/// `ref.read(apiServiceProvider).uploadMyAvatar`.
typedef UploadFn = Future<String> Function(MultipartFile file);

/// Turunkan content-type dari ekstensi. Backend menolak apa pun di luar
/// allowlist (`backend/app/services/storage.py:8-13`), dan Dio default ke
/// `application/octet-stream` yang PASTI ditolak — jadi wajib eksplisit.
const _mimeByExt = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
  'pdf': 'application/pdf',
};

String? mimeForExtension(String? ext) =>
    ext == null ? null : _mimeByExt[ext.toLowerCase()];

MultipartFile multipartFromBytes(
  Uint8List bytes,
  String filename,
  String mime,
) => MultipartFile.fromBytes(
  bytes,
  filename: filename,
  contentType: DioMediaType.parse(mime),
);

/// Picker nyata. Dipisah agar widget bisa diuji tanpa plugin platform.
Future<({Uint8List bytes, String name})?> _pickDefault({
  required bool document,
}) async {
  final res = await FilePicker.platform.pickFiles(
    withData: true, // wajib di web: path tidak tersedia
    type: FileType.custom,
    allowedExtensions: document
        ? const ['pdf']
        : const ['jpg', 'jpeg', 'png', 'webp'],
  );
  final files = res?.files ?? const <PlatformFile>[];
  if (files.isEmpty) return null;
  final f = files.first;
  final bytes = f.bytes;
  if (bytes == null) return null;
  return (bytes: bytes, name: f.name);
}

/// Field URL dengan tombol upload di sisi kanan.
///
/// Nilai yang dihasilkan backend (`/static/uploads/...`) ditulis apa adanya ke
/// controller, karena `POST /*/media` dan `PUT /me/profile` hanya menerima
/// `^(https?://|/static/)`. Resolve ke URL absolut dilakukan saat render
/// (`AppNetworkImage`) atau saat membuka link (`ApiConfig.resolveFileUrl`).
class UploadField extends StatefulWidget {
  final TextEditingController controller;
  final UploadFn upload;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool document;

  /// Override untuk test; produksi memakai `FilePicker.platform`.
  final Future<Uint8List?> Function()? picker;
  final Future<String> Function()? fileName;

  const UploadField({
    super.key,
    required this.controller,
    required this.upload,
    required this.label,
    this.hint,
    this.icon,
    this.document = false,
    this.picker,
    this.fileName,
  });

  @override
  State<UploadField> createState() => _UploadFieldState();
}

class _UploadFieldState extends State<UploadField> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final Uint8List? bytes;
      final String name;
      if (widget.picker != null) {
        bytes = await widget.picker!();
        name = (await widget.fileName?.call()) ?? 'upload';
      } else {
        final picked = await _pickDefault(document: widget.document);
        bytes = picked?.bytes;
        name = picked?.name ?? '';
      }
      if (bytes == null) return;

      final ext = name.contains('.') ? name.split('.').last : null;
      final mime = mimeForExtension(
        ext,
      ) ?? (widget.document ? 'application/pdf' : 'image/jpeg');
      final url = await widget.upload(
        multipartFromBytes(bytes, name, mime),
      );
      if (!mounted) return;
      setState(() => widget.controller.text = url);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal upload file')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: folioField(
            widget.controller,
            widget.label,
            hint: widget.hint,
            keyboard: TextInputType.url,
            icon: widget.icon,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: IconButton(
            tooltip: widget.document ? 'Upload dokumen' : 'Upload gambar',
            onPressed: _busy ? null : _run,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_outlined),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 5: Jalankan test helper**

Run: `frontend\.fvm\flutter_sdk\bin\flutter test test/features/dashboard_me/upload_test.dart`
Expected: PASS (4 test).

- [ ] **Step 6: Analyze + commit**

```bash
frontend\.fvm\flutter_sdk\bin\flutter analyze
git add frontend/pubspec.yaml frontend/pubspec.lock frontend/lib/shared/widgets/upload_field.dart frontend/test/features/dashboard_me/upload_test.dart
git commit -m "feat(upload): add file_picker and reusable UploadField"
```

---

### Task 4: Upload avatar di form profil user

**Files:**
- Modify: `frontend/lib/features/dashboard_me/user_dashboard_page.dart:1373-1379`
- Endpoint: `POST /me/upload/avatar` → `uploadMyAvatar`

- [ ] **Step 1: Ganti field avatar teks dengan `UploadField`**

Tambah import di `user_dashboard_page.dart` (setelah baris 20):

```dart
import 'package:frontend/shared/widgets/upload_field.dart';
```

Ganti blok baris 1373-1379:

```dart
          // sebelum
          folioField(
            _avatar,
            'Avatar URL',
            hint: 'https://... (hasil upload avatar)',
            keyboard: TextInputType.url,
            icon: Icons.image_outlined,
          ),
```

dengan:

```dart
          UploadField(
            controller: _avatar,
            label: 'Avatar URL',
            hint: 'https://... atau klik ikon upload',
            icon: Icons.image_outlined,
            upload: ref.read(apiServiceProvider).uploadMyAvatar,
          ),
```

- [ ] **Step 2: Analyze**

Run: `frontend\.fvm\flutter_sdk\bin\flutter analyze`
Expected: `No issues found!`. `ref` tersedia karena `_ProfileForm` adalah `ConsumerStatefulWidget`.

- [ ] **Step 3: Verifikasi manual jalur upload**

Jalankan backend + `flutter run -d chrome`, login sebagai user, buka Dashboard → Profil Saya → klik ikon upload di Avatar URL, pilih PNG < 5 MB.
Expected: field terisi `/static/uploads/u/<id>/avatars/<uuid>.png`, avatar sidebar berganti setelah "Simpan profil".

- [ ] **Step 4: Commit**

```bash
git add frontend/lib/features/dashboard_me/user_dashboard_page.dart
git commit -m "feat(me): upload avatar from profile form"
```

---

### Task 5: Upload cover & media proyek di dialog user

**Files:**
- Modify: `frontend/lib/features/dashboard_me/dashboard_dialogs.dart` (signature `showProjectDialog`, `_ProjectDialog`, `showProjectMediaDialog`)
- Modify: `frontend/lib/features/dashboard_me/user_dashboard_page.dart:775`, `:805`
- Endpoints: `POST /me/upload/cover`, `POST /me/upload/media`

**Interfaces:**
- Produces: `showProjectDialog(BuildContext, {ProjectModel? project, List<SkillModel> allSkills, UploadFn? uploadCover})`
- Produces: `showProjectMediaDialog(BuildContext, {UploadFn? uploadMedia})`
- `UploadFn` berasal dari `shared/widgets/upload_field.dart`. `null` = tombol upload disembunyikan (dipakai test lama yang tidak menyuntikkan service).

- [ ] **Step 1: Tambah parameter ke `_ProjectDialog`**

Di `dashboard_dialogs.dart`, tambah import:

```dart
import 'package:frontend/shared/widgets/upload_field.dart';
```

Ubah `showProjectDialog`:

```dart
Future<Map<String, dynamic>?> showProjectDialog(
  BuildContext context, {
  ProjectModel? project,
  List<SkillModel> allSkills = const [],
  UploadFn? uploadCover,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => _ProjectDialog(
      project: project,
      allSkills: allSkills,
      uploadCover: uploadCover,
    ),
  );
}
```

Ubah `_ProjectDialog`:

```dart
class _ProjectDialog extends StatefulWidget {
  final ProjectModel? project;
  final List<SkillModel> allSkills;
  final UploadFn? uploadCover;

  const _ProjectDialog({
    required this.project,
    required this.allSkills,
    this.uploadCover,
  });
```

- [ ] **Step 2: Pakai `UploadField` di field cover**

Ganti `folioField(_coverUrl, 'Cover image URL', ...)` (baris 176-181) dengan:

```dart
              if (widget.uploadCover != null)
                UploadField(
                  controller: _coverUrl,
                  label: 'Cover image URL',
                  hint: 'https://... atau klik ikon upload',
                  icon: Icons.image_outlined,
                  upload: widget.uploadCover!,
                )
              else
                folioField(
                  _coverUrl,
                  'Cover image URL',
                  hint: 'https://.../cover.png (hasil upload cover)',
                  keyboard: TextInputType.url,
                ),
```

- [ ] **Step 3: Tambah parameter ke dialog media**

```dart
Future<Map<String, String>?> showProjectMediaDialog(
  BuildContext context, {
  UploadFn? uploadMedia,
}) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (_) => _ProjectMediaDialog(uploadMedia: uploadMedia),
  );
}

class _ProjectMediaDialog extends StatefulWidget {
  final UploadFn? uploadMedia;
  const _ProjectMediaDialog({this.uploadMedia});

  @override
  State<_ProjectMediaDialog> createState() => _ProjectMediaDialogState();
}
```

Dan ganti `folioField(_url, 'Media URL*', ...)` (baris 497-502) dengan:

```dart
            if (widget.uploadMedia != null)
              UploadField(
                controller: _url,
                label: 'Media URL*',
                hint: 'https://... atau klik ikon upload',
                icon: Icons.add_photo_alternate_outlined,
                upload: widget.uploadMedia!,
              )
            else
              folioField(
                _url,
                'Media URL*',
                hint: 'https://... (hasil upload media)',
                keyboard: TextInputType.url,
              ),
```

- [ ] **Step 4: Suntikkan dari dashboard user**

Di `user_dashboard_page.dart`, pada `_saveProject` (sekitar baris 773-776):

```dart
    final payload = await showProjectDialog(
      context,
      project: existing,
      uploadCover: ref.read(apiServiceProvider).uploadMyCover,
    );
```

pada `_addProjectMedia` (sekitar baris 805):

```dart
    final data = await showProjectMediaDialog(
      context,
      uploadMedia: ref.read(apiServiceProvider).uploadMyMedia,
    );
```

- [ ] **Step 5: Analyze + test + commit**

```bash
frontend\.fvm\flutter_sdk\bin\flutter analyze
frontend\.fvm\flutter_sdk\bin\flutter test
git add frontend/lib/features/dashboard_me/dashboard_dialogs.dart frontend/lib/features/dashboard_me/user_dashboard_page.dart
git commit -m "feat(me): upload project cover and media from dialogs"
```

Ketiga endpoint `/me/upload/*` kini terpakai. Cek cepat:
Run: `Select-String -Path frontend\lib\features -Recurse -Pattern "uploadMyCover|uploadMyMedia|uploadMyAvatar"`
Expected: masing-masing minimal 1 hit di luar `api_service.dart`.

---

### Task 6: Upload di dialog admin

**Files:**
- Modify: `backend/app/routers/admin.py` (`AdminUserCreate`, `admin_create_user`)
- Test: `backend/tests/test_admin_user_resume.py` (NEW)
- Modify: `frontend/lib/features/dashboard_me/dashboard_dialogs.dart` (`showAdminUserDialog`, `_AdminUserDialog`)
- Modify: `frontend/lib/features/admin/admin_dashboard_page.dart:755-809`
- Endpoints: `POST /admin/upload/project-cover`, `/project-media`, `/resume`

- [ ] **Step 1: Backend — terima `resume_url` saat admin membuat user**

`AdminUserCreate` (`backend/app/routers/admin.py:32-37`) saat ini tidak punya `resume_url`, dan `admin_create_user` (`:360-369`) membangun `User(...)` field-per-field sehingga field ekstra akan dibuang diam-diam. Tambahkan:

```python
class AdminUserCreate(BaseModel):
  username: str = Field(pattern=r"^[a-z0-9_]{3,30}$")
  email: EmailStr
  password: str = Field(min_length=8, max_length=72)  # batas bcrypt
  full_name: str = Field(min_length=2, max_length=100)
  role: Literal["admin", "user"] = "user"
  # Diisi dari POST /admin/upload/resume bila admin mengunggah CV.
  resume_url: Optional[str] = None
```

dan di `admin_create_user`, tambahkan satu baris sebelum `is_active=True,`:

```python
      resume_url=payload.resume_url,
```

Test — buat file baru `backend/tests/test_admin_user_resume.py`:

```python
"""Admin membuat user sekaligus menyimpan hasil upload CV."""

from sqlalchemy import text

from app.core.security import get_password_hash
from app.models.user import User
from tests.conftest import TestingSession, get_client


def _reset_db():
  db = TestingSession()
  db.execute(text("DELETE FROM project_skills"))
  for tbl in ("project_media", "messages", "projects", "skills", "experiences"):
    db.execute(text(f"DELETE FROM {tbl}"))
  db.query(User).delete()
  db.add(
      User(
          username="admin",
          email="admin@x.com",
          hashed_password=get_password_hash("admin123"),
          full_name="Admin",
          role="admin",
          profile_slug="admin",
          is_published=True,
          is_active=True,
      )
  )
  db.commit()
  db.close()


def _admin_auth():
  c = get_client()
  r = c.post("/api/v1/auth/login", data={"username": "admin", "password": "admin123"})
  assert r.status_code == 200, r.text
  return {"Authorization": f"Bearer {r.json()['access_token']}"}


def test_admin_create_user_with_resume_url():
  _reset_db()
  r = get_client().post(
      "/api/v1/admin/users",
      json={
          "username": "carol",
          "email": "carol@x.com",
          "password": "password123",
          "full_name": "Carol",
          "resume_url": "/static/uploads/resumes/cv.pdf",
      },
      headers=_admin_auth(),
  )
  assert r.status_code == 201, r.text
  assert r.json()["resume_url"] == "/static/uploads/resumes/cv.pdf"
```

Run: `cd backend; python -m pytest tests/test_admin_user_resume.py -q`
Expected: FAIL sebelum perubahan (`resume_url` bernilai `null`), PASS sesudahnya.

- [ ] **Step 2: Tambah `uploadResume` ke dialog user admin**

```dart
/// Dialog buat user (admin) -> payload `adminCreateUser`.
/// `uploadResume` opsional: bila diisi, field resume punya tombol upload
/// yang menulis ke `POST /admin/upload/resume`.
Future<Map<String, dynamic>?> showAdminUserDialog(
  BuildContext context, {
  UploadFn? uploadResume,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => _AdminUserDialog(uploadResume: uploadResume),
  );
}

class _AdminUserDialog extends StatefulWidget {
  final UploadFn? uploadResume;
  const _AdminUserDialog({this.uploadResume});

  @override
  State<_AdminUserDialog> createState() => _AdminUserDialogState();
}
```

Di `_AdminUserDialogState` tambahkan controller:

```dart
  final _resume = TextEditingController();
```

dispose:

```dart
    _resume.dispose();
```

Kirim di payload `_submit` (setelah `'role': _role,`):

```dart
      if (_resume.text.trim().isNotEmpty) 'resume_url': _resume.text.trim(),
```

tambahkan field di `Column` (setelah field `Nama lengkap*`, dan ingat `_AdminUserDialog` adalah `StatefulWidget` biasa — pakai `widget.uploadResume`):

```dart
              if (widget.uploadResume != null)
                UploadField(
                  controller: _resume,
                  label: 'Resume URL',
                  hint: 'https://... atau klik ikon upload',
                  icon: Icons.description_outlined,
                  document: true,
                  upload: widget.uploadResume!,
                )
              else
                folioField(
                  _resume,
                  'Resume URL',
                  hint: 'opsional',
                  keyboard: TextInputType.url,
                ),
```

- [ ] **Step 3: Suntikkan di admin dashboard**

`_createProject` (baris 755-766):

```dart
    final payload = await showProjectDialog(
      context,
      uploadCover: ref.read(apiServiceProvider).adminUploadProjectCover,
    );
```

`_editProject` (baris 768-779):

```dart
    final payload = await showProjectDialog(
      context,
      project: p,
      uploadCover: ref.read(apiServiceProvider).adminUploadProjectCover,
    );
```

`_addProjectMedia` (baris 793-796):

```dart
    final data = await showProjectMediaDialog(
      context,
      uploadMedia: ref.read(apiServiceProvider).adminUploadProjectMedia,
    );
```

`_createUser` (baris 536-539):

```dart
    final payload = await showAdminUserDialog(
      context,
      uploadResume: ref.read(apiServiceProvider).adminUploadResume,
    );
```

`adminUploadAvatar`: tidak punya tempat alami karena `AdminUserUpdate` (`backend/app/schemas/auth.py:64-67`) **tidak** menerima `avatar_url` — hanya `is_active`, `is_published`, `role`. **Jangan** tambahkan `avatar_url` ke `AdminUserUpdate` di task ini; itu dikerjakan di Task 12.

- [ ] **Step 4: Analyze + test + commit**

```bash
frontend\.fvm\flutter_sdk\bin\flutter analyze
frontend\.fvm\flutter_sdk\bin\flutter test
cd backend; python -m pytest -q
git add backend/app/routers/admin.py backend/tests/test_admin_user_resume.py frontend/lib/features/dashboard_me/dashboard_dialogs.dart frontend/lib/features/admin/admin_dashboard_page.dart
git commit -m "feat(admin): upload project cover/media and resume from dialogs"
```

Hasil phase 2: `adminUploadProjectCover`, `adminUploadProjectMedia`, `adminUploadResume` terpakai. `adminUploadAvatar` ditunda ke Task 12 karena butuh perubahan backend.

---

### Task 7: SATU helper simpan media bersama (anti-duplikasi)

**Files:**
- Create: `frontend/lib/features/dashboard_me/project_media_utils.dart`
- Modify: `frontend/lib/features/dashboard_me/user_dashboard_page.dart:804-821`
- Modify: `frontend/lib/features/admin/admin_dashboard_page.dart:793-815`

**Kenapa:** setelah Task 5 & 6, dua dashboard punya blok identik "buka dialog → panggil addMedia → invalidate → snack". Dieduplikasi sekali agar penambahan `PUT/DELETE media` nanti (out of scope) hanya diubah di satu tempat.

**Interfaces:**
- Produces: `Future<bool> addProjectMediaFlow(WidgetRef ref, {required BuildContext context, required ProjectModel project, required Future<ProjectMediaModel> Function(String mediaUrl, String mediaType, String? caption) add, required void Function() onChanged, required void Function(String msg, {bool error}) notify, required UploadFn? uploadMedia})`

- [ ] **Step 1: Buat file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/features/dashboard_me/dashboard_dialogs.dart';
import 'package:frontend/shared/widgets/errors.dart';
import 'package:frontend/shared/widgets/upload_field.dart';

/// Alur "tambah media proyek" yang dipakai dashboard user maupun admin.
/// Mengembalikan true bila media berhasil ditambahkan.
Future<bool> addProjectMediaFlow(
  WidgetRef ref, {
  required BuildContext context,
  required ProjectModel project,
  required Future<ProjectMediaModel> Function(
    String mediaUrl,
    String mediaType,
    String? caption,
  )
  add,
  required void Function() onChanged,
  required void Function(String msg, {bool error}) notify,
  UploadFn? uploadMedia,
}) async {
  final data = await showProjectMediaDialog(
    context,
    uploadMedia: uploadMedia,
  );
  if (data == null) return false;
  final caption = (data['caption'] ?? '').trim();
  try {
    await add(data['media_url']!, data['media_type'] ?? 'image',
        caption.isEmpty ? null : caption);
    onChanged();
    notify('Media ditambahkan ke "${project.title}"');
    return true;
  } catch (e) {
    notify(friendlyError(e, 'Gagal tambah media'), error: true);
    return false;
  }
}
```

- [ ] **Step 2: Pakai di user dashboard**

Ganti seluruh body `_addProjectMedia` di `user_dashboard_page.dart` (baris 804-821) dengan:

```dart
  Future<void> _addProjectMedia(ProjectModel p) async {
    final api = ref.read(apiServiceProvider);
    await addProjectMediaFlow(
      ref,
      context: context,
      project: p,
      add: (url, type, caption) => api.addMyProjectMedia(
        p.id,
        mediaUrl: url,
        mediaType: type,
        caption: caption,
      ),
      onChanged: () => ref.invalidate(myProjectsProvider),
      notify: _snack,
      uploadMedia: api.uploadMyMedia,
    );
  }
```

Tambah import `import 'package:frontend/features/dashboard_me/project_media_utils.dart';`.

- [ ] **Step 3: Pakai di admin dashboard**

Ganti `_addProjectMedia` di `admin_dashboard_page.dart` (baris 793-812) dengan:

```dart
  Future<void> _addProjectMedia(ProjectModel p) async {
    final api = ref.read(apiServiceProvider);
    await addProjectMediaFlow(
      ref,
      context: context,
      project: p,
      add: (url, type, caption) => api.adminAddProjectMedia(
        p.id,
        mediaUrl: url,
        mediaType: type,
        caption: caption,
      ),
      onChanged: () {
        ref.invalidate(adminProjectsProvider);
        ref.invalidate(adminProjectsFilteredProvider);
      },
      notify: _snack,
      uploadMedia: api.adminUploadProjectMedia,
    );
  }
```

Tambah import yang sama.

- [ ] **Step 4: Analyze + test + commit**

```bash
frontend\.fvm\flutter_sdk\bin\flutter analyze
frontend\.fvm\flutter_sdk\bin\flutter test
git add frontend/lib/features/dashboard_me/project_media_utils.dart frontend/lib/features/dashboard_me/user_dashboard_page.dart frontend/lib/features/admin/admin_dashboard_page.dart
git commit -m "refactor(dashboard): share add-media flow between user and admin"
```

---

# Phase 3 — Admin skill & experience (butuh perubahan backend)

### Task 8: Backend `GET /admin/skills` + `GET /admin/experiences`

**Files:**
- Modify: `backend/app/routers/admin.py` (tambah 2 handler setelah `admin_list_projects`, sekitar baris 414)
- Test: `backend/tests/test_admin_content_listing.py` (NEW)

**Kenapa:** tanpa endpoint GET, 6 endpoint admin skill/experience (POST/PATCH/DELETE) tidak mungkin dipakai UI — tidak ada cara memuat daftar yang mau diedit.

- [ ] **Step 1: Tulis test yang gagal**

Create `backend/tests/test_admin_content_listing.py`:

```python
"""Admin harus bisa MEMBACA skill & experience lintas user sebelum mengeditnya."""

from sqlalchemy import text

from app.core.security import get_password_hash
from app.models.user import User
from tests.conftest import TestingSession, get_client


def _reset_db():
  db = TestingSession()
  db.execute(text("DELETE FROM project_skills"))
  for tbl in ("project_media", "messages", "projects", "skills", "experiences"):
    db.execute(text(f"DELETE FROM {tbl}"))
  db.query(User).delete()
  db.add(
      User(
          username="admin",
          email="admin@x.com",
          hashed_password=get_password_hash("admin123"),
          full_name="Admin",
          role="admin",
          profile_slug="admin",
          is_published=True,
          is_active=True,
      )
  )
  db.commit()
  db.close()


def _login(username, password="password123"):
  c = get_client()
  r = c.post("/api/v1/auth/login", data={"username": username, "password": password})
  assert r.status_code == 200, r.text
  return {"Authorization": f"Bearer {r.json()['access_token']}"}


def _register(username, email):
  c = get_client()
  r = c.post(
      "/api/v1/auth/register",
      json={
          "username": username,
          "email": email,
          "password": "password123",
          "full_name": username,
      },
  )
  assert r.status_code == 201, r.text


def test_admin_lists_skills_across_owners():
  _reset_db()
  _register("alice", "alice@x.com")
  alice = _login("alice")
  c = get_client()
  assert (
      c.post(
          "/api/v1/me/skills",
          json={"name": "Flutter", "category": "Frontend"},
          headers=alice,
      ).status_code
      == 201
  )

  admin = _login("admin", "admin123")
  r = c.get("/api/v1/admin/skills", headers=admin)
  assert r.status_code == 200, r.text
  assert [s["name"] for s in r.json()] == ["Flutter"]


def test_admin_lists_experiences_filtered_by_owner():
  _reset_db()
  _register("alice", "alice@x.com")
  _register("bob", "bob@x.com")
  c = get_client()
  alice = _login("alice")
  bob = _login("bob")
  body = {
      "role": "Engineer",
      "company": "Acme",
      "start_date": "2023-01-01",
  }
  c.post("/api/v1/me/experiences", json=body, headers=alice)
  c.post("/api/v1/me/experiences", json=body, headers=bob)

  admin = _login("admin", "admin123")
  users = c.get("/api/v1/admin/users", headers=admin).json()
  alice_id = next(u["id"] for u in users if u["username"] == "alice")

  r = c.get(
      f"/api/v1/admin/experiences?owner_id={alice_id}", headers=admin
  )
  assert r.status_code == 200, r.text
  assert len(r.json()) == 1
  assert r.json()[0]["company"] == "Acme"


def test_non_admin_cannot_list_admin_skills():
  _reset_db()
  _register("alice", "alice@x.com")
  alice = _login("alice")
  r = get_client().get("/api/v1/admin/skills", headers=alice)
  assert r.status_code == 403
```

- [ ] **Step 2: Jalankan, pastikan gagal**

Run: `cd backend; python -m pytest tests/test_admin_content_listing.py -q`
Expected: FAIL — 404 pada ketiga test GET.

- [ ] **Step 3: Implementasikan handler**

Di `backend/app/routers/admin.py`, setelah `admin_list_projects` (baris 414), tambahkan:

```python
# --- Moderasi skills & experiences lintas user ---
@router.get("/skills", response_model=List[SkillResponse])
def admin_list_skills(
    owner_id: Optional[int] = Query(default=None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=200),
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  q = db.query(Skill).order_by(Skill.id)
  if owner_id is not None:
    q = q.filter(Skill.owner_id == owner_id)
  return q.offset(skip).limit(limit).all()


@router.get("/experiences", response_model=List[ExperienceResponse])
def admin_list_experiences(
    owner_id: Optional[int] = Query(default=None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=200),
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
):
  q = db.query(Experience).order_by(Experience.start_date.desc())
  if owner_id is not None:
    q = q.filter(Experience.owner_id == owner_id)
  return q.offset(skip).limit(limit).all()
```

`List`, `Optional`, `Query`, `SkillResponse`, `ExperienceResponse` sudah diimpor di file ini.

- [ ] **Step 4: Jalankan test**

Run: `cd backend; python -m pytest tests/test_admin_content_listing.py -q`
Expected: 3 passed.

- [ ] **Step 5: Regresi penuh backend**

Run: `cd backend; python -m pytest -q`
Expected: seluruh suite hijau.

- [ ] **Step 6: Commit**

```bash
git add backend/app/routers/admin.py backend/tests/test_admin_content_listing.py
git commit -m "feat(admin): add GET /admin/skills and /admin/experiences"
```

---

### Task 9: Backend `owner_id` opsional saat admin membuat skill/experience/project

**Files:**
- Modify: `backend/app/routers/admin.py:40-81` (`create_project`), `:186-202` (`create_skill`), `:240-255` (`create_experience`)
- Modify: `backend/app/schemas/skill.py`, `backend/app/schemas/experience.py`, `backend/app/schemas/project.py`
- Test: `backend/tests/test_admin_content_listing.py` (tambah kasus)

**Kenapa:** ketiga handler memaksa `owner_id=current.id` (admin). Admin jadi tidak bisa membuat konten atas nama kreator, padahal tab "Semua Proyek" menunjukkan konten semua orang. Ini bug, bukan sekadar fitur baru.

**Interfaces:**
- Produces: field opsional `owner_id: Optional[int] = None` pada `ProjectCreate`, `SkillCreate`, `ExperienceCreate`. Default `None` → milik admin (perilaku lama terjaga).

- [ ] **Step 1: Tulis test yang gagal**

Tambahkan di `backend/tests/test_admin_content_listing.py`:

```python
def test_admin_can_create_skill_for_another_owner():
  _reset_db()
  _register("alice", "alice@x.com")
  c = get_client()
  admin = _login("admin", "admin123")
  alice_id = next(
      u["id"]
      for u in c.get("/api/v1/admin/users", headers=admin).json()
      if u["username"] == "alice"
  )

  r = c.post(
      "/api/v1/admin/skills",
      json={"name": "Go", "category": "Backend", "owner_id": alice_id},
      headers=admin,
  )
  assert r.status_code == 201, r.text

  alice = _login("alice")
  mine = c.get("/api/v1/me/skills", headers=alice).json()
  assert [s["name"] for s in mine] == ["Go"]


def test_admin_create_skill_defaults_to_self():
  _reset_db()
  c = get_client()
  admin = _login("admin", "admin123")
  r = c.post(
      "/api/v1/admin/skills",
      json={"name": "Rust", "category": "Backend"},
      headers=admin,
  )
  assert r.status_code == 201, r.text
  assert [s["name"] for s in c.get("/api/v1/me/skills", headers=admin).json()] == [
      "Rust"
  ]


def test_admin_create_for_unknown_owner_is_404():
  _reset_db()
  c = get_client()
  admin = _login("admin", "admin123")
  r = c.post(
      "/api/v1/admin/skills",
      json={"name": "Zig", "category": "Backend", "owner_id": 999999},
      headers=admin,
  )
  assert r.status_code == 404, r.text
```

- [ ] **Step 2: Jalankan, pastikan gagal**

Run: `cd backend; python -m pytest tests/test_admin_content_listing.py -q`
Expected: `test_admin_can_create_skill_for_another_owner` FAIL (201 tapi tidak ada di `/me/skills` milik alice); `test_admin_create_for_unknown_owner_is_404` FAIL (201).

- [ ] **Step 3: Tambah field owner_id ke schema**

`backend/app/schemas/skill.py`:

```python
class SkillCreate(SkillBase):
  # Khusus admin: buat skill atas nama kreator lain. None = milik pemanggil.
  owner_id: Optional[int] = None
```

`backend/app/schemas/experience.py`:

```python
class ExperienceCreate(ExperienceBase):
  # Khusus admin: buat pengalaman atas nama kreator lain.
  owner_id: Optional[int] = None
```

`backend/app/schemas/project.py` — ubah:

```python
class ProjectCreate(ProjectBase):
  skill_ids: List[int] = []
  # Khusus admin: buat proyek atas nama kreator lain.
  owner_id: Optional[int] = None
```

Pastikan `Optional` sudah diimpor di ketiga file (`project.py` dan `skill.py` sudah memakainya; `experience.py` sudah `from typing import List, Optional`).

- [ ] **Step 4: Pakai di handler admin**

Tambahkan helper di `backend/app/routers/admin.py` tepat setelah `class AdminUserCreate`:

```python
def _resolve_owner(db: Session, current: User, owner_id: Optional[int]) -> int:
  """owner_id eksplisit hanya boleh menunjuk user yang ada.

  None = konten milik admin sendiri (perilaku lama dipertahankan).
  """
  if owner_id is None:
    return current.id
  if db.query(User).filter(User.id == owner_id).first() is None:
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Pemilik tidak ditemukan"
    )
  return owner_id
```

`create_project` — ganti seluruh blok baris 50-68 (mulai dari `existing = (` sampai `project = Project(...)`) dengan:

```python
  owner_id = _resolve_owner(db, current, payload.owner_id)
  existing = (
      db.query(Project)
      .filter(Project.owner_id == owner_id, Project.slug == payload.slug)
      .first()
  )
  if existing:
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="Slug sudah digunakan oleh proyek lain",
    )

  skills = []
  if payload.skill_ids:
    skills = (
        db.query(Skill)
        .filter(Skill.id.in_(payload.skill_ids), Skill.owner_id == owner_id)
        .all()
    )

  project_data = payload.model_dump(exclude={"skill_ids", "owner_id"})
  project = Project(**project_data, owner_id=owner_id, skills=skills)
```

`create_skill` — ganti baris 194-202:

```python
  owner_id = _resolve_owner(db, current, payload.owner_id)
  if (
      db.query(Skill)
      .filter(Skill.owner_id == owner_id, Skill.name == payload.name)
      .first()
  ):
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="Skill sudah ada"
    )
  s = Skill(**payload.model_dump(exclude={"owner_id"}), owner_id=owner_id)
```

`create_experience` — ganti baris 251:

```python
  owner_id = _resolve_owner(db, current, payload.owner_id)
  e = Experience(
      **payload.model_dump(exclude={"owner_id"}), owner_id=owner_id
  )
```

- [ ] **Step 5: Jalankan test**

Run: `cd backend; python -m pytest tests/test_admin_content_listing.py -q`
Expected: 6 passed.

- [ ] **Step 6: Regresi penuh (perhatikan test multitenant & 409)**

Run: `cd backend; python -m pytest -q`
Expected: seluruh suite hijau. `tests/test_integrity_409.py` dan `tests/test_multitenant.py` menguji jalur slug duplikat — pastikan masih 400/409 seperti semula.

- [ ] **Step 7: Commit**

```bash
git add backend/app/routers/admin.py backend/app/schemas/skill.py backend/app/schemas/experience.py backend/app/schemas/project.py backend/tests/test_admin_content_listing.py
git commit -m "feat(admin): allow creating content on behalf of another owner"
```

---

### Task 10: Frontend — service & provider untuk daftar konten admin

**Files:**
- Modify: `frontend/lib/core/network/api_service.dart` (setelah `adminListProjectsFiltered`)
- Modify: `frontend/lib/core/network/app_providers.dart`

**Interfaces:**
- Produces:
  - `Future<List<SkillModel>> adminListSkills({int? ownerId})`
  - `Future<List<ExperienceModel>> adminListExperiences({int? ownerId})`
  - `adminSkillsProvider` = `FutureProvider.family<List<SkillModel>, int?>`
  - `adminExperiencesProvider` = `FutureProvider.family<List<ExperienceModel>, int?>`

- [ ] **Step 1: Tambah method service**

Di `api_service.dart`, setelah `adminListProjectsFiltered`:

```dart
  /// GET /admin/skills?owner_id — daftar skill lintas user (admin only).
  Future<List<SkillModel>> adminListSkills({int? ownerId}) async {
    try {
      final res = await _dio.get(
        '/admin/skills',
        queryParameters: {if (ownerId != null) 'owner_id': ownerId},
      );
      return (res.data as List)
          .map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat skill (admin only)');
    }
  }

  /// GET /admin/experiences?owner_id — daftar pengalaman lintas user.
  Future<List<ExperienceModel>> adminListExperiences({int? ownerId}) async {
    try {
      final res = await _dio.get(
        '/admin/experiences',
        queryParameters: {if (ownerId != null) 'owner_id': ownerId},
      );
      return (res.data as List)
          .map((e) => ExperienceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat pengalaman (admin only)');
    }
  }
```

- [ ] **Step 2: Tambah provider**

Di `app_providers.dart`, setelah `adminProjectsFilteredProvider`:

```dart
/// GET /admin/skills?owner_id
final adminSkillsProvider =
    FutureProvider.family<List<SkillModel>, int?>((ref, ownerId) async {
      return ref.read(apiServiceProvider).adminListSkills(ownerId: ownerId);
    });

/// GET /admin/experiences?owner_id
final adminExperiencesProvider =
    FutureProvider.family<List<ExperienceModel>, int?>((ref, ownerId) async {
      return ref.read(apiServiceProvider).adminListExperiences(ownerId: ownerId);
    });
```

- [ ] **Step 3: Analyze**

Run: `frontend\.fvm\flutter_sdk\bin\flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add frontend/lib/core/network/api_service.dart frontend/lib/core/network/app_providers.dart
git commit -m "feat(api): admin skills/experiences listing"
```

---

### Task 11: Frontend — tab "Skill & Pengalaman" di admin

**Files:**
- Modify: `frontend/lib/features/admin/admin_dashboard_page.dart` (menu sidebar, `_body`, tab baru, 6 method mutasi)
- Modify: `frontend/lib/features/dashboard_me/dashboard_dialogs.dart` (`showSkillDialog`, `showExperienceDialog` menerima `ownerId`)
- Test: `frontend/test/features/admin/admin_content_tab_test.dart` (NEW)

**Interfaces:**
- Produces: `showSkillDialog(context, {SkillModel? skill, int? ownerId})`, `showExperienceDialog(context, {ExperienceModel? experience, int? ownerId})`. `ownerId != null` menambahkan `'owner_id'` ke payload.

- [ ] **Step 1: Tulis test yang gagal**

Create `frontend/test/features/admin/admin_content_tab_test.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/features/admin/admin_dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(
    () => dotenv.loadFromString(
      envString: 'API_BASE_URL=https://api.example.com/api/v1',
    ),
  );
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tab Skill & Pengalaman menampilkan skill dari provider', (
    tester,
  ) async {
    // Sidebar DashboardShell hanya tampil pada layout lebar; surface default
    // 800x600 menyembunyikannya di balik drawer.
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminUsersProvider.overrideWith((ref) async => <UserModel>[]),
          adminMessagesProvider.overrideWith(
            (ref) async => <Map<String, dynamic>>[],
          ),
          adminProjectsProvider.overrideWith((ref) async => <ProjectModel>[]),
          adminProjectsFilteredProvider.overrideWith(
            (ref, ownerId) async => <ProjectModel>[],
          ),
          adminSkillsProvider.overrideWith(
            (ref, ownerId) async =>
                [SkillModel(id: 1, name: 'Flutter', category: 'Frontend')],
          ),
          adminExperiencesProvider.overrideWith(
            (ref, ownerId) async => <ExperienceModel>[],
          ),
        ],
        child: const MaterialApp(home: AdminDashboard()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skill & Pengalaman').first);
    await tester.pumpAndSettle();

    expect(find.text('Flutter'), findsWidgets);
  });
}
```

- [ ] **Step 2: Jalankan, pastikan gagal**

Run: `frontend\.fvm\flutter_sdk\bin\flutter test test/features/admin/admin_content_tab_test.dart`
Expected: FAIL — `adminSkillsProvider` tidak terdefinisi / menu item tidak ditemukan.

- [ ] **Step 3: Tambah `ownerId` ke dialog dialog bersama**

Di `dashboard_dialogs.dart`:

```dart
Future<Map<String, dynamic>?> showSkillDialog(
  BuildContext context, {
  SkillModel? skill,
  int? ownerId,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => _SkillDialog(skill: skill, ownerId: ownerId),
  );
}
```

`_SkillDialog` menerima `final int? ownerId;` dan di `_submit` menambahkan:

```dart
    if (widget.ownerId != null) 'owner_id': widget.ownerId,
```

Hal yang sama untuk `showExperienceDialog` / `_ExperienceDialog`. `ownerId == null` → payload tidak berubah (dipakai dashboard user, jadi tidak ada regresi).

- [ ] **Step 4: Tambah tab ke admin dashboard**

Di `admin_dashboard_page.dart`:

a) Tambah import model yang belum ada (file ini baru mengimpor `project_model` dan `user_model`):

```dart
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/models/skill_model.dart';
```

b) Menu sidebar (setelah item "Semua Proyek", baris 130):

```dart
        const SidebarItem(
          icon: Icons.school_outlined,
          label: 'Skill & Pengalaman',
        ),
```

b) `_body` — nomor tab bergeser karena item disisipkan sebelum "Pesan Masuk". Overview tetap jadi fallback (`return Column(...)` di bawahnya, biarkan apa adanya). Ubah tiga baris dispatch di `_body` (baris 165-167) menjadi:

```dart
    if (tab == 1) return _usersTab();
    if (tab == 2) return _projectsTab();
    if (tab == 3) return _contentTab();
    if (tab == 4) return _messagesTab();
```

Jangan mengekstrak blok overview — biarkan inline sebagai `return Column(...)`.

c) Method tab baru (taruh sebelum `_messagesTab`):

```dart
  // ---------- Tab: Skill & Pengalaman ----------

  Future<void> _saveSkill({SkillModel? existing}) async {
    final payload = await showSkillDialog(
      context,
      skill: existing,
      // owner_id hanya relevan saat CREATE; PATCH tidak menerima field ini.
      ownerId: existing == null ? _ownerFilter : null,
    );
    if (payload == null) return;
    try {
      final api = ref.read(apiServiceProvider);
      if (existing == null) {
        await api.adminCreateSkill(payload);
        _snack('Skill dibuat');
      } else {
        await api.adminUpdateSkill(existing.id, payload);
        _snack('Skill diperbarui');
      }
      ref.invalidate(adminSkillsProvider);
    } catch (e) {
      _snack(friendlyError(e, 'Gagal simpan skill'), error: true);
    }
  }

  Future<void> _deleteSkill(SkillModel s) async {
    if (!await confirmDelete(context, 'Skill "${s.name}"')) return;
    try {
      await ref.read(apiServiceProvider).adminDeleteSkill(s.id);
      ref.invalidate(adminSkillsProvider);
      _snack('Skill dihapus');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal hapus skill'), error: true);
    }
  }

  Future<void> _saveExperience({ExperienceModel? existing}) async {
    final payload = await showExperienceDialog(
      context,
      experience: existing,
      ownerId: existing == null ? _ownerFilter : null,
    );
    if (payload == null) return;
    try {
      final api = ref.read(apiServiceProvider);
      if (existing == null) {
        await api.adminCreateExperience(payload);
        _snack('Pengalaman dibuat');
      } else {
        await api.adminUpdateExperience(existing.id, payload);
        _snack('Pengalaman diperbarui');
      }
      ref.invalidate(adminExperiencesProvider);
    } catch (e) {
      _snack(friendlyError(e, 'Gagal simpan pengalaman'), error: true);
    }
  }

  Future<void> _deleteExperience(ExperienceModel e) async {
    if (!await confirmDelete(context, '"${e.role} @ ${e.company}"')) return;
    try {
      await ref.read(apiServiceProvider).adminDeleteExperience(e.id);
      ref.invalidate(adminExperiencesProvider);
      _snack('Pengalaman dihapus');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal hapus pengalaman'), error: true);
    }
  }

  Widget _contentTab() {
    final users = ref.watch(adminUsersProvider).asData?.value ?? [];
    final skills = ref.watch(adminSkillsProvider(_ownerFilter));
    final exps = ref.watch(adminExperiencesProvider(_ownerFilter));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Admin Console',
          title: 'Skill & Pengalaman',
          subtitle: 'Kelola keahlian dan riwayat kerja kreator.',
          actionLabel: 'Tambah skill',
          onAction: () => _saveSkill(),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Filter kreator',
          subtitle: 'Pilih kreator agar skill/pengalaman baru tercatat atas namanya.',
          child: DropdownButtonFormField<int?>(
            initialValue: _ownerFilter,
            decoration: const InputDecoration(
              labelText: 'Pemilik konten',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Semua kreator (konten baru milik saya)'),
              ),
              ...users.map(
                (u) => DropdownMenuItem<int?>(
                  value: u.id,
                  child: Text(u.fullName ?? u.username),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _ownerFilter = v),
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          title: 'Skill',
          subtitle: 'Keahlian lintas kreator.',
          trailing: TextButton.icon(
            onPressed: () => _saveSkill(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambah'),
          ),
          child: skills.when(
            data: (list) {
              if (list.isEmpty) {
                return const EmptyCard(
                  title: 'Belum ada skill',
                  subtitle: 'Skill kreator akan tampil di sini.',
                );
              }
              return Column(
                children: list
                    .map(
                      (s) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(s.name),
                        subtitle: Text(s.category ?? 'Other'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _saveSkill(existing: s),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => _deleteSkill(s),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const ListSkeleton(rows: 3),
            error: (e, _) => ErrorCard(
              message: friendlyError(e, 'Gagal memuat skill'),
              onRetry: () => ref.invalidate(adminSkillsProvider),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          title: 'Pengalaman',
          subtitle: 'Riwayat kerja lintas kreator.',
          trailing: TextButton.icon(
            onPressed: () => _saveExperience(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambah'),
          ),
          child: exps.when(
            data: (list) {
              if (list.isEmpty) {
                return const EmptyCard(
                  title: 'Belum ada pengalaman',
                  subtitle: 'Riwayat kerja kreator akan tampil di sini.',
                );
              }
              return Column(
                children: list
                    .map(
                      (e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text('${e.role} @ ${e.company}'),
                        subtitle: Text(e.location ?? '-'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _saveExperience(existing: e),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => _deleteExperience(e),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const ListSkeleton(rows: 3),
            error: (e, _) => ErrorCard(
              message: friendlyError(e, 'Gagal memuat pengalaman'),
              onRetry: () => ref.invalidate(adminExperiencesProvider),
            ),
          ),
        ),
      ],
    );
  }
```

d) Tambah invalidasi di `_refreshAll` (baris ~98-101):

```dart
    ref.invalidate(adminSkillsProvider);
    ref.invalidate(adminExperiencesProvider);
```

- [ ] **Step 5: Jalankan test**

Run: `frontend\.fvm\flutter_sdk\bin\flutter test test/features/admin/admin_content_tab_test.dart`
Expected: PASS.

- [ ] **Step 6: Full analyze + test**

```bash
frontend\.fvm\flutter_sdk\bin\flutter analyze
frontend\.fvm\flutter_sdk\bin\flutter test
```
Expected: 0 issue, semua hijau (termasuk `dashboard_refresh_test.dart` yang tidak tersentuh).

- [ ] **Step 7: Commit**

```bash
git add frontend/lib/features/admin/admin_dashboard_page.dart frontend/lib/features/dashboard_me/dashboard_dialogs.dart frontend/test/features/admin/admin_content_tab_test.dart
git commit -m "feat(admin): skill & experience management tab"
```

---

### Task 12: UI admin untuk `adminUploadAvatar`

**Files:**
- Modify: `backend/app/schemas/auth.py:64-67` (`AdminUserUpdate` + `avatar_url`)
- Modify: `backend/app/routers/admin.py:383-400` (`admin_update_user` — pastikan `model_dump(exclude_unset=True)` sudah dipakai)
- Modify: `backend/app/routers/me.py` (`ProfileUpdate` pola sama sudah menerima `avatar_url`)
- Modify: `frontend/lib/features/admin/admin_dashboard_page.dart` (edit user dialog) + `dashboard_dialogs.dart`
- Test: `backend/tests/test_admin_content_listing.py` (tambah kasus avatar)

**Kenapa:** `adminUploadAvatar` tidak punya jalur penyimpanan karena `AdminUserUpdate` hanya menerima 3 field. Tanpa memperluas schema, endpoint upload avatar admin akan tetap menganggur.

- [ ] **Step 1: Tulis test backend yang gagal**

```python
def test_admin_can_set_avatar_url_for_user():
  _reset_db()
  _register("alice", "alice@x.com")
  c = get_client()
  admin = _login("admin", "admin123")
  alice_id = next(
      u["id"]
      for u in c.get("/api/v1/admin/users", headers=admin).json()
      if u["username"] == "alice"
  )
  r = c.patch(
      f"/api/v1/admin/users/{alice_id}",
      json={"avatar_url": "/static/uploads/avatars/x.png"},
      headers=admin,
  )
  assert r.status_code == 200, r.text
  assert r.json()["avatar_url"] == "/static/uploads/avatars/x.png"
```

- [ ] **Step 2: Jalankan, pastikan gagal**

Run: `cd backend; python -m pytest tests/test_admin_content_listing.py -k avatar -q`
Expected: FAIL — nilai `avatar_url` diabaikan atau 422.

- [ ] **Step 3: Perluas `AdminUserUpdate`**

`backend/app/schemas/auth.py`:

```python
class AdminUserUpdate(BaseModel):
  is_active: Optional[bool] = None
  is_published: Optional[bool] = None
  role: Optional[Literal["admin", "user"]] = None
  avatar_url: Optional[str] = None
```

- [ ] **Step 4: Jalankan test backend**

Run: `cd backend; python -m pytest tests/test_admin_content_listing.py -q; python -m pytest -q`
Expected: semua hijau.

- [ ] **Step 5: Tambah dialog edit user di admin (frontend)**

Di `dashboard_dialogs.dart`, tambah dialog baru setelah `_AdminUserDialog`:

```dart
/// Dialog edit user (admin) -> payload `adminUpdateUser`.
/// `uploadAvatar` opsional: menulis ke `POST /admin/upload/avatar`.
Future<Map<String, dynamic>?> showAdminUserEditDialog(
  BuildContext context, {
  required UserModel user,
  UploadFn? uploadAvatar,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => _AdminUserEditDialog(user: user, uploadAvatar: uploadAvatar),
  );
}

class _AdminUserEditDialog extends StatefulWidget {
  final UserModel user;
  final UploadFn? uploadAvatar;
  const _AdminUserEditDialog({required this.user, this.uploadAvatar});

  @override
  State<_AdminUserEditDialog> createState() => _AdminUserEditDialogState();
}

class _AdminUserEditDialogState extends State<_AdminUserEditDialog> {
  late final _avatar = TextEditingController(
    text: widget.user.avatarUrl ?? '',
  );

  @override
  void dispose() {
    _avatar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.user.fullName ?? widget.user.username}'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.uploadAvatar != null)
              UploadField(
                controller: _avatar,
                label: 'Avatar URL',
                hint: 'https://... atau klik ikon upload',
                icon: Icons.image_outlined,
                upload: widget.uploadAvatar!,
              )
            else
              folioField(
                _avatar,
                'Avatar URL',
                hint: 'https://...',
                keyboard: TextInputType.url,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'avatar_url': _avatar.text.trim().isEmpty
                ? null
                : _avatar.text.trim(),
          }),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
```

Tambah import `UserModel` di `dashboard_dialogs.dart`:

```dart
import 'package:frontend/core/models/user_model.dart';
```

- [ ] **Step 6: Wire di tabel user admin**

Di `admin_dashboard_page.dart`, pada `_userRow` `PopupMenuButton` (baris 676-701), tambahkan item menu `edit` dan cabangnya:

```dart
            onSelected: (v) {
              if (v == 'edit') {
                _editUser(u);
              }
              if (v == 'active') {
                _setUserField(u.id, {'is_active': !u.isActive});
              }
              if (v == 'role') {
                _setUserField(u.id, {'role': u.isAdmin ? 'user' : 'admin'});
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit avatar'),
              ),
              PopupMenuItem(
                value: 'active',
                child: Text(
                  u.isActive ? 'Nonaktifkan akun' : 'Aktifkan akun',
                ),
              ),
              PopupMenuItem(
                value: 'role',
                child: Text(u.isAdmin ? 'Jadikan user' : 'Jadikan admin'),
              ),
            ],
```

lalu tambahkan method berikut di dekat `_createUser`:

```dart
  Future<void> _editUser(UserModel u) async {
    final payload = await showAdminUserEditDialog(
      context,
      user: u,
      uploadAvatar: ref.read(apiServiceProvider).adminUploadAvatar,
    );
    if (payload == null) return;
    await _setUserField(u.id, payload);
    _snack('Avatar diperbarui');
  }
```

- [ ] **Step 7: Analyze + test + commit**

```bash
frontend\.fvm\flutter_sdk\bin\flutter analyze
frontend\.fvm\flutter_sdk\bin\flutter test
cd backend; python -m pytest -q
git add backend/app/schemas/auth.py backend/tests/test_admin_content_listing.py frontend/lib/features/dashboard_me/dashboard_dialogs.dart frontend/lib/features/admin/admin_dashboard_page.dart
git commit -m "feat(admin): set user avatar via admin upload endpoint"
```

Hasil phase 3: seluruh 6 endpoint admin skill/experience + `adminUploadAvatar` terpakai. Total tersisa 0 endpoint menganggur kecuali `POST /me/upload/resume` (Task 13).

---

# Phase 4 — Tutup gap backend terakhir

### Task 13: `POST /me/upload/resume` + upload CV di form profil user

**Files:**
- Modify: `backend/app/routers/me.py` (setelah `me_upload_avatar`, baris 532)
- Test: `backend/tests/test_upload_my_resume.py` (NEW)
- Modify: `frontend/lib/core/network/api_service.dart` (setelah `uploadMyAvatar`)
- Modify: `frontend/lib/features/dashboard_me/user_dashboard_page.dart:1380-1386`

**Kenapa:** user biasa tidak bisa mengunggah CV sendiri; satu-satunya endpoint resume adalah `/admin/upload/resume`. Saat ini form profil menyuruh user mengisi URL manual — tidak realistis untuk pengguna non-teknis.

- [ ] **Step 1: Tulis test backend yang gagal**

Create `backend/tests/test_upload_my_resume.py`:

```python
"""User harus bisa mengunggah CV sendiri (sebelumnya hanya admin)."""

import io

from sqlalchemy import text

from app.models.user import User
from tests.conftest import TestingSession, get_client

# PNG 1x1 valid (magic header + IHDR + IDAT + IEND).
_PNG_1PX = bytes.fromhex(
    "89504e470d0a1a0a0000000d4948445200000001000000010806000000"
    "1f15c4890000000a49444154789c6300010000050001"
    "0d0a2db40000000049454e44ae426082"
)


def _reset_db():
  db = TestingSession()
  db.execute(text("DELETE FROM project_skills"))
  for tbl in ("project_media", "messages", "projects", "skills", "experiences"):
    db.execute(text(f"DELETE FROM {tbl}"))
  db.query(User).delete()
  db.commit()
  db.close()


def _register_login(username, email):
  c = get_client()
  r = c.post(
      "/api/v1/auth/register",
      json={
          "username": username,
          "email": email,
          "password": "password123",
          "full_name": username,
      },
  )
  assert r.status_code == 201, r.text
  r = c.post(
      "/api/v1/auth/login",
      data={"username": username, "password": "password123"},
  )
  assert r.status_code == 200, r.text
  return {"Authorization": f"Bearer {r.json()['access_token']}"}


def test_user_uploads_own_resume():
  _reset_db()
  auth = _register_login("alice", "alice@x.com")
  pdf = b"%PDF-1.4\n%fake\n"
  r = get_client().post(
      "/api/v1/me/upload/resume",
      files={"file": ("cv.pdf", io.BytesIO(pdf), "application/pdf")},
      headers=auth,
  )
  assert r.status_code == 200, r.text
  url = r.json()["url"]
  assert url.startswith("/static/")
  assert url.endswith(".pdf")


def test_resume_upload_rejects_non_pdf():
  _reset_db()
  auth = _register_login("alice", "alice@x.com")
  # PNG asli (magic header + IHDR valid) supaya yang ditolak adalah aturan
  # "dokumen harus PDF", bukan cek magic-bytes.
  r = get_client().post(
      "/api/v1/me/upload/resume",
      files={"file": ("x.png", io.BytesIO(_PNG_1PX), "image/png")},
      headers=auth,
  )
  assert r.status_code == 400


def test_resume_upload_requires_auth():
  r = get_client().post(
      "/api/v1/me/upload/resume",
      files={"file": ("cv.pdf", io.BytesIO(b"%PDF-1.4\n"), "application/pdf")},
  )
  assert r.status_code == 401
```

- [ ] **Step 2: Jalankan, pastikan gagal**

Run: `cd backend; python -m pytest tests/test_upload_my_resume.py -q`
Expected: FAIL — 405/404 pada ketiga test.

- [ ] **Step 3: Implementasikan endpoint**

Di `backend/app/routers/me.py`, setelah `me_upload_avatar`:

```python
@router.post("/upload/resume")
async def me_upload_resume(
    file: UploadFile = File(...),
    current: User = Depends(get_current_user),
):
  return {
      "url": await storage_service.save_file(
          file, subfolder=f"u/{current.id}/resumes", is_document=True
      )
  }
```

- [ ] **Step 4: Jalankan test backend**

Run: `cd backend; python -m pytest tests/test_upload_my_resume.py -q; python -m pytest -q`
Expected: semua hijau.

- [ ] **Step 5: Tambah method service frontend**

Di `api_service.dart`, setelah `uploadMyAvatar`:

```dart
  /// POST /me/upload/resume (multipart FormData, PDF).
  Future<String> uploadMyResume(MultipartFile file) =>
      _uploadMultipart('/me/upload/resume', file);
```

- [ ] **Step 6: Pakai di form profil**

Di `user_dashboard_page.dart`, ganti blok baris 1380-1386:

```dart
          // sebelum
          folioField(
            _resume,
            'Resume URL',
            hint: 'https://... (hasil upload resume)',
            keyboard: TextInputType.url,
            icon: Icons.description_outlined,
          ),
```

dengan:

```dart
          UploadField(
            controller: _resume,
            label: 'Resume URL',
            hint: 'PDF maks 5 MB, atau klik ikon upload',
            icon: Icons.description_outlined,
            document: true,
            upload: ref.read(apiServiceProvider).uploadMyResume,
          ),
```

- [ ] **Step 7: Analyze + test + commit**

```bash
frontend\.fvm\flutter_sdk\bin\flutter analyze
frontend\.fvm\flutter_sdk\bin\flutter test
git add backend/app/routers/me.py backend/tests/test_upload_my_resume.py frontend/lib/core/network/api_service.dart frontend/lib/features/dashboard_me/user_dashboard_page.dart
git commit -m "feat(me): allow users to upload their own resume"
```

---

## Verification — cakupan akhir

Jalankan dua perintah ini untuk membuktikan setiap method service dipanggil dari luar `api_service.dart`/`auth_service.dart`:

```powershell
# 1) daftar method service
Select-String -Path frontend\lib\core\network\api_service.dart,frontend\lib\core\network\auth_service.dart -Pattern "Future<[^>]+> (\w+)\(" | ForEach-Object { $_.Matches[0].Groups[1].Value } | Sort-Object -Unique
# 2) untuk tiap nama, cek pemanggil di lib/features + lib/core/network/app_providers.dart
```

Expected akhir: **56 endpoint backend** (55 di daftar + `POST /auth/logout`) semuanya punya pemanggil. Yang boleh tanpa UI langsung:

- `/me/upload/cover|media|avatar` → dipakai lewat `UploadField` + `project_media_utils.dart`.
- `POST /auth/logout` → dipanggil `AuthService.logout`, bukan UI langsung.

Bukti per grup:

| Grup | Cek |
|---|---|
| Auth | `Select-String -Path frontend\lib -Recurse -Pattern "changePassword|\.register\(|\.login\(|service\.me\(\)"` |
| Public | `galleryProjectsProvider`, `userProfileProvider`, `userProjectsProvider`, `userSkillsProvider`, `userExperiencesProvider`, `sendContact` |
| Me upload | `uploadMyCover`, `uploadMyMedia`, `uploadMyAvatar`, `uploadMyResume` — masing-masing ≥1 hit di `lib/features` |
| Admin konten | `adminListSkills`, `adminListExperiences`, `adminCreateSkill`, `adminUpdateSkill`, `adminDeleteSkill`, `adminCreateExperience`, `adminUpdateExperience`, `adminDeleteExperience` |
| Admin upload | `adminUploadProjectCover`, `adminUploadProjectMedia`, `adminUploadResume`, `adminUploadAvatar` — masing-masing ≥1 hit di `lib/features` |

Final gate:

```bash
frontend\.fvm\flutter_sdk\bin\flutter analyze
frontend\.fvm\flutter_sdk\bin\flutter test
cd backend; python -m pytest -q
```

---

## Di luar cakupan (sengaja tidak dikerjakan)

- **`PUT`/`DELETE /projects/{id}/media`** — backend belum punya; `addMyProjectMedia` hanya menambah, tidak pernah menghapus. Perlu endpoint baru + kaskade file di `remove_project_files`.
- **`GET /admin/skills` pagination di UI** — service memakai `limit` default 100; UI belum punya "load more".
- **Refresh token** — auth memakai JWT tunggal tanpa refresh (lihat `AuthNotifier._restoreFailed`).
- **`403` handling khusus di `friendlyError`** — saat ini jatuh ke `e.message`; cukup untuk admin-only.

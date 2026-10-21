import 'package:flutter/material.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/core/utils/validators.dart' as v;
import 'package:frontend/shared/widgets/folio_field.dart';
import 'package:frontend/shared/widgets/upload_field.dart';

const _skillCategories = ['Frontend', 'Backend', 'Database', 'Tools', 'Other'];

const _projectStatuses = ['draft', 'published'];

final _slugPattern = v.kSlugPattern;

final _dateOk = RegExp(r'^\d{4}-\d{2}-\d{2}$');

String? _nullIfEmpty(String v) => v.trim().isEmpty ? null : v.trim();

void _warn(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
}

Future<bool> confirmDelete(BuildContext context, String label) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Hapus data?'),
      content: Text('$label akan dihapus permanen.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Dialog tambah/edit proyek. Mengembalikan payload siap kirim ke
/// `createMyProject` / `updateMyProject`, atau null bila dibatalkan.
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

class _ProjectDialog extends StatefulWidget {
  final ProjectModel? project;
  final List<SkillModel> allSkills;
  final UploadFn? uploadCover;

  const _ProjectDialog({
    required this.project,
    required this.allSkills,
    this.uploadCover,
  });

  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  late final _title = TextEditingController(text: widget.project?.title ?? '');
  late final _slug = TextEditingController(text: widget.project?.slug ?? '');
  late final _summary = TextEditingController(
    text: widget.project?.summary ?? '',
  );
  late final _liveUrl = TextEditingController(
    text: widget.project?.liveUrl ?? '',
  );
  late final _githubUrl = TextEditingController(
    text: widget.project?.githubUrl ?? '',
  );
  late final _coverUrl = TextEditingController(
    text: widget.project?.coverImageUrl ?? '',
  );
  late final _skillIds = TextEditingController(
    text: (widget.project?.skills ?? []).map((s) => '${s.id}').join(', '),
  );
  late String _status = widget.project?.status ?? 'published';

  @override
  void dispose() {
    _title.dispose();
    _slug.dispose();
    _summary.dispose();
    _liveUrl.dispose();
    _githubUrl.dispose();
    _coverUrl.dispose();
    _skillIds.dispose();
    super.dispose();
  }

  void _submit() {
    if (_title.text.trim().length < 3 || _summary.text.trim().length < 10) {
      _warn(context, 'Judul (min 3) dan ringkasan (min 10) wajib diisi');
      return;
    }
    if (!_slugPattern.hasMatch(_slug.text.trim())) {
      _warn(
        context,
        'Slug hanya huruf kecil, angka, dan strip (mis. toko-online)',
      );
      return;
    }
    final ids = _skillIds.text
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
    Navigator.pop(context, <String, dynamic>{
      'title': _title.text.trim(),
      'slug': _slug.text.trim(),
      'summary': _summary.text.trim(),
      'status': _status,
      'skill_ids': ids,
      'live_url': _nullIfEmpty(_liveUrl.text),
      'github_url': _nullIfEmpty(_githubUrl.text),
      'cover_image_url': _nullIfEmpty(_coverUrl.text),
    });
  }

  @override
  Widget build(BuildContext context) {
    final allSkills = widget.allSkills;
    final skillHint = allSkills.isEmpty
        ? 'Belum ada skill — kosongkan saja'
        : 'ID tersedia: ${allSkills.map((s) => '${s.id}=${s.name}').join(', ')}';
    return AlertDialog(
      title: Text(widget.project == null ? 'Proyek baru' : 'Edit proyek'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              folioField(_title, 'Judul*', hint: 'misal: Toko Online'),
              folioField(_slug, 'Slug*', hint: 'misal: toko-online'),
              folioField(
                _summary,
                'Ringkasan* (min 10 karakter)',
                hint: 'Ceritakan proyek ini...',
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                initialValue: _projectStatuses.contains(_status)
                    ? _status
                    : 'published',
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _projectStatuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? 'published'),
              ),
              const SizedBox(height: 10),
              folioField(
                _liveUrl,
                'Live URL',
                hint: 'https://...',
                keyboard: TextInputType.url,
              ),
              folioField(
                _githubUrl,
                'GitHub URL',
                hint: 'https://github.com/...',
                keyboard: TextInputType.url,
              ),
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
              folioField(
                _skillIds,
                'Skill IDs (koma)',
                hint: skillHint,
                keyboard: TextInputType.text,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

/// Dialog tambah/edit skill -> payload `createMySkill` / `updateMySkill`,
/// atau `adminCreateSkill` / `adminUpdateSkill` bila dipanggil dari admin.
/// `ownerId` (khusus admin) menambahkan `owner_id` ke payload dan hanya
/// berlaku saat create — PATCH tidak menerima field itu.
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

class _SkillDialog extends StatefulWidget {
  final SkillModel? skill;
  final int? ownerId;

  const _SkillDialog({required this.skill, this.ownerId});

  @override
  State<_SkillDialog> createState() => _SkillDialogState();
}

class _SkillDialogState extends State<_SkillDialog> {
  late final _name = TextEditingController(text: widget.skill?.name ?? '');
  late final _proficiency = TextEditingController(
    text: widget.skill?.proficiencyLevel?.toString() ?? '',
  );
  late String _category = _skillCategories.contains(widget.skill?.category)
      ? widget.skill!.category!
      : 'Other';

  @override
  void dispose() {
    _name.dispose();
    _proficiency.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      _warn(context, 'Nama skill wajib diisi');
      return;
    }
    final raw = _proficiency.text.trim();
    final level = int.tryParse(raw);
    if (raw.isNotEmpty && (level == null || level < 1 || level > 100)) {
      _warn(context, 'Proficiency harus angka 1-100 atau kosong');
      return;
    }
    Navigator.pop(context, <String, dynamic>{
      'name': _name.text.trim(),
      'category': _category,
      'proficiency_level': level,
      if (widget.ownerId != null) 'owner_id': widget.ownerId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.skill == null ? 'Skill baru' : 'Edit skill'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            folioField(_name, 'Nama*', hint: 'misal: Flutter'),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _skillCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Other'),
            ),
            const SizedBox(height: 10),
            folioField(
              _proficiency,
              'Proficiency (1-100, opsional)',
              hint: 'misal: 80',
              keyboard: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

String _fmtDate(DateTime? d) =>
    d == null ? '' : d.toIso8601String().substring(0, 10);

/// Dialog tambah/edit experience -> payload `createMyExperience` /
/// `updateMyExperience`, atau `adminCreateExperience` /
/// `adminUpdateExperience` bila dipanggil dari admin. Tanggal format
/// `YYYY-MM-DD`. `ownerId` (khusus admin) menambahkan `owner_id` ke payload
/// dan hanya berlaku saat create — PATCH tidak menerima field itu.
Future<Map<String, dynamic>?> showExperienceDialog(
  BuildContext context, {
  ExperienceModel? experience,
  int? ownerId,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => _ExperienceDialog(experience: experience, ownerId: ownerId),
  );
}

class _ExperienceDialog extends StatefulWidget {
  final ExperienceModel? experience;
  final int? ownerId;

  const _ExperienceDialog({required this.experience, this.ownerId});

  @override
  State<_ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<_ExperienceDialog> {
  late final _role = TextEditingController(text: widget.experience?.role ?? '');
  late final _company = TextEditingController(
    text: widget.experience?.company ?? '',
  );
  late final _location = TextEditingController(
    text: widget.experience?.location ?? '',
  );
  late final _start = TextEditingController(
    text: _fmtDate(widget.experience?.startDate),
  );
  late final _end = TextEditingController(
    text: _fmtDate(widget.experience?.endDate),
  );
  late final _description = TextEditingController(
    text: widget.experience?.description ?? '',
  );
  late final _tech = TextEditingController(
    text: (widget.experience?.technologiesUsed ?? []).join(', '),
  );
  late bool _isCurrent = widget.experience?.isCurrent ?? false;

  @override
  void dispose() {
    _role.dispose();
    _company.dispose();
    _location.dispose();
    _start.dispose();
    _end.dispose();
    _description.dispose();
    _tech.dispose();
    super.dispose();
  }

  void _submit() {
    final start = _start.text.trim();
    final end = _end.text.trim();
    if (_role.text.trim().length < 2 ||
        _company.text.trim().length < 2 ||
        !_dateOk.hasMatch(start) ||
        (end.isNotEmpty && !_dateOk.hasMatch(end))) {
      _warn(
        context,
        'Role, perusahaan (min 2), dan tanggal (YYYY-MM-DD) wajib valid',
      );
      return;
    }
    if (!_isCurrent && end.isNotEmpty && end.compareTo(start) < 0) {
      _warn(context, 'Tanggal selesai tidak boleh sebelum mulai');
      return;
    }
    final techs = _tech.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    Navigator.pop(context, <String, dynamic>{
      'role': _role.text.trim(),
      'company': _company.text.trim(),
      'location': _nullIfEmpty(_location.text),
      'start_date': start,
      'end_date': _isCurrent ? null : _nullIfEmpty(_end.text),
      'is_current': _isCurrent,
      'description': _nullIfEmpty(_description.text),
      'technologies_used': techs,
      if (widget.ownerId != null) 'owner_id': widget.ownerId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.experience == null ? 'Pengalaman baru' : 'Edit pengalaman',
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              folioField(_role, 'Role*', hint: 'misal: Frontend Engineer'),
              folioField(_company, 'Perusahaan*', hint: 'misal: FolioSpace'),
              folioField(_location, 'Lokasi', hint: 'misal: Jakarta'),
              folioField(
                _start,
                'Mulai* (YYYY-MM-DD)',
                hint: 'misal: 2023-01-15',
              ),
              folioField(
                _end,
                'Selesai (YYYY-MM-DD, kosong jika kini)',
                hint: 'misal: 2024-06-30',
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Masih bekerja di sini'),
                value: _isCurrent,
                onChanged: (v) => setState(() => _isCurrent = v ?? false),
              ),
              folioField(
                _description,
                'Deskripsi',
                hint: 'Ceritakan peranmu...',
                maxLines: 3,
              ),
              folioField(
                _tech,
                'Teknologi (koma)',
                hint: 'misal: Flutter, Go, Postgres',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

/// Dialog tambah media proyek -> dipakai `addMyProjectMedia`.
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

class _ProjectMediaDialogState extends State<_ProjectMediaDialog> {
  final _url = TextEditingController();
  final _caption = TextEditingController();
  String _type = 'image';

  @override
  void dispose() {
    _url.dispose();
    _caption.dispose();
    super.dispose();
  }

  void _submit() {
    if (_url.text.trim().isEmpty) {
      _warn(context, 'Media URL wajib diisi');
      return;
    }
    Navigator.pop(context, <String, String>{
      'media_url': _url.text.trim(),
      'media_type': _type,
      'caption': _caption.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah media proyek'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Tipe',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                'image',
                'video',
                'link',
              ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v ?? 'image'),
            ),
            const SizedBox(height: 10),
            folioField(_caption, 'Caption', hint: 'opsional'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Tambah')),
      ],
    );
  }
}

/// Dialog ganti password -> [current, baru], atau null bila dibatalkan.
Future<List<String>?> showChangePasswordDialog(BuildContext context) {
  return showDialog<List<String>>(
    context: context,
    builder: (_) => const _ChangePasswordDialog(),
  );
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _current = TextEditingController();
  final _fresh = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _fresh.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (_fresh.text.length < 8) {
      _warn(context, 'Password baru minimal 8 karakter');
      return;
    }
    if (_fresh.text != _confirm.text) {
      _warn(context, 'Konfirmasi password tidak cocok');
      return;
    }
    Navigator.pop(context, <String>[_current.text, _fresh.text]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ganti password'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            folioField(_current, 'Password saat ini', obscureText: true),
            folioField(_fresh, 'Password baru (min 8)', obscureText: true),
            folioField(_confirm, 'Ulangi password baru', obscureText: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

final _usernamePattern = v.kUsernamePattern;

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

class _AdminUserDialogState extends State<_AdminUserDialog> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  final _resume = TextEditingController();
  String _role = 'user';

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _fullName.dispose();
    _resume.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    if (!_usernamePattern.hasMatch(_username.text.trim())) {
      _warn(context, 'Username 3-30 karakter (huruf kecil, angka, underscore)');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _warn(context, 'Email tidak valid');
      return;
    }
    if (_password.text.length < 8) {
      _warn(context, 'Password minimal 8 karakter');
      return;
    }
    if (_fullName.text.trim().length < 2) {
      _warn(context, 'Nama lengkap minimal 2 karakter');
      return;
    }
    Navigator.pop(context, <String, dynamic>{
      'username': _username.text.trim(),
      'email': email,
      'password': _password.text,
      'full_name': _fullName.text.trim(),
      'role': _role,
      if (_resume.text.trim().isNotEmpty) 'resume_url': _resume.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('User baru'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              folioField(_username, 'Username*', hint: 'misal: budi_dev'),
              folioField(
                _email,
                'Email*',
                hint: 'misal: budi@mail.com',
                keyboard: TextInputType.emailAddress,
              ),
              folioField(
                _fullName,
                'Nama lengkap*',
                hint: 'misal: Budi Santoso',
              ),
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
              folioField(_password, 'Password* (min 8)', obscureText: true),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const ['user', 'admin']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v ?? 'user'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

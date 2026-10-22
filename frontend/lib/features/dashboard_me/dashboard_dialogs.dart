import 'package:flutter/material.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/utils/validators.dart' as v;
import 'package:frontend/shared/widgets/folio_date_field.dart';
import 'package:frontend/shared/widgets/folio_field.dart';
import 'package:frontend/shared/widgets/upload_field.dart';

const _skillCategories = ['Frontend', 'Backend', 'Database', 'Tools', 'Other'];

const _projectStatuses = ['draft', 'published'];

final _slugPattern = v.kSlugPattern;

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
/// `createMyProject` / `updateMyProject`, atau `adminCreateProject` /
/// `adminUpdateProject` bila dipanggil dari admin. `ownerId` (khusus admin)
/// menambahkan `owner_id` ke payload dan hanya berlaku saat create —
/// PATCH tidak menerima field itu.
Future<Map<String, dynamic>?> showProjectDialog(
  BuildContext context, {
  ProjectModel? project,
  List<SkillModel> allSkills = const [],
  UploadFn? uploadCover,
  int? ownerId,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => _ProjectDialog(
      project: project,
      allSkills: allSkills,
      uploadCover: uploadCover,
      ownerId: ownerId,
    ),
  );
}

class _ProjectDialog extends StatefulWidget {
  final ProjectModel? project;
  final List<SkillModel> allSkills;
  final UploadFn? uploadCover;
  final int? ownerId;

  const _ProjectDialog({
    required this.project,
    required this.allSkills,
    this.uploadCover,
    this.ownerId,
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
  /// Skill dipilih sebagai set supaya toggle O(1); payload tetap [List<int>]
  /// dengan format yang sama seperti versi ketik-ID-manual dulu.
  /// Nama skill disimpan juga agar chip skill tertaut yang sudah tidak ada
  /// di daftar [allSkills] (mis. skill dihapus) tetap punya label.
  late final Set<int> _selectedSkillIds = {
    for (final s in widget.project?.skills ?? const <SkillModel>[]) s.id,
  };
  late final Map<int, String> _linkedSkillNames = {
    for (final s in widget.project?.skills ?? const <SkillModel>[])
      s.id: s.name,
  };
  late String _status = widget.project?.status ?? 'published';

  @override
  void dispose() {
    _title.dispose();
    _slug.dispose();
    _summary.dispose();
    _liveUrl.dispose();
    _githubUrl.dispose();
    _coverUrl.dispose();
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
    Navigator.pop(context, <String, dynamic>{
      'title': _title.text.trim(),
      'slug': _slug.text.trim(),
      'summary': _summary.text.trim(),
      'status': _status,
      'skill_ids': _selectedSkillIds.toList(),
      'live_url': _nullIfEmpty(_liveUrl.text),
      'github_url': _nullIfEmpty(_githubUrl.text),
      'cover_image_url': _nullIfEmpty(_coverUrl.text),
      if (widget.ownerId != null) 'owner_id': widget.ownerId,
    });
  }

  /// Pemilih skill berupa chip — pengguna tinggal tap, tidak perlu tahu
  /// ID database. Daftar chip = [allSkills] + skill tertaut yang sudah
  /// tidak ada di daftar (mis. skill dihapus) supaya tetap terlihat dan
  /// bisa dilepas, bukan menghilang diam-diam saat dialog disimpan.
  Widget _skillPicker(List<SkillModel> allSkills) {
    final knownIds = {for (final s in allSkills) s.id};
    final linked = widget.project?.skills ?? const <SkillModel>[];
    final chips = [
      ...allSkills,
      ...linked.where((s) => !knownIds.contains(s.id)),
    ]..sort(_chipOrder);

    if (chips.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('Belum ada skill — buat dulu di menu Skill.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: _selectedSkillIds.isEmpty
              ? 'Skill dipakai'
              : 'Skill dipakai (${_selectedSkillIds.length})',
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in chips)
              FilterChip(
                label: Text(s.name),
                selected: _selectedSkillIds.contains(s.id),
                onSelected: (v) => setState(() {
                  if (v) {
                    _selectedSkillIds.add(s.id);
                  } else {
                    _selectedSkillIds.remove(s.id);
                  }
                }),
                selectedColor: AppColors.indigoSoft,
                checkmarkColor: AppColors.cyan,
                tooltip: knownIds.contains(s.id)
                    ? s.name
                    : '${_linkedSkillNames[s.id] ?? s.name} '
                        '(tidak ada di daftar skill)',
              ),
          ],
        ),
      ),
    );
  }

  /// Urut chip: per kategori (SKU konsisten dengan daftar skill), lalu nama.
  int _chipOrder(SkillModel a, SkillModel b) {
    final byCat = (a.category ?? 'Other').compareTo(b.category ?? 'Other');
    if (byCat != 0) return byCat;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final allSkills = widget.allSkills;
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
              _skillPicker(allSkills),
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

/// Dialog tambah/edit experience -> payload `createMyExperience` /
/// `updateMyExperience`, atau `adminCreateExperience` /
/// `adminUpdateExperience` bila dipanggil dari admin. Tanggal dikirim dengan
/// format `YYYY-MM-DD` dan dipilih lewat date picker, bukan diketik.
/// `ownerId` (khusus admin) menambahkan `owner_id` ke payload dan hanya
/// berlaku saat create — PATCH tidak menerima field itu.
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
  late DateTime? _startDate = widget.experience?.startDate;
  late DateTime? _endDate = widget.experience?.endDate;
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
    _description.dispose();
    _tech.dispose();
    super.dispose();
  }

  void _submit() {
    if (_role.text.trim().length < 2 || _company.text.trim().length < 2) {
      _warn(context, 'Role dan perusahaan minimal 2 karakter');
      return;
    }
    if (_startDate == null) {
      _warn(context, 'Tanggal mulai wajib dipilih');
      return;
    }
    if (!_isCurrent && _endDate != null && _endDate!.isBefore(_startDate!)) {
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
      'start_date': folioIsoDate(_startDate!),
      'end_date': _isCurrent || _endDate == null
          ? null
          : folioIsoDate(_endDate!),
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
              folioDateField(
                label: 'Mulai*',
                value: _startDate,
                onChanged: (d) => setState(() => _startDate = d),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100, 12, 31),
              ),
              folioDateField(
                label: 'Selesai',
                value: _endDate,
                enabled: !_isCurrent,
                onChanged: (d) => setState(() => _endDate = d),
                firstDate: _startDate ?? DateTime(1900),
                lastDate: DateTime(2100, 12, 31),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Masih bekerja di sini'),
                value: _isCurrent,
                onChanged: (v) => setState(() {
                  _isCurrent = v ?? false;
                  if (_isCurrent) _endDate = null;
                }),
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
            folioPasswordField(_current, 'Password saat ini'),
            folioPasswordField(_fresh, 'Password baru (min 8)'),
            folioPasswordField(_confirm, 'Ulangi password baru'),
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
              folioPasswordField(_password, 'Password* (min 8)'),
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

/// Dialog edit user (admin) -> payload `adminUpdateUser`.
/// `uploadAvatar` opsional: menulis ke `POST /admin/upload/avatar`.
Future<Map<String, dynamic>?> showAdminUserEditDialog(
  BuildContext context, {
  required UserModel user,
  UploadFn? uploadAvatar,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) =>
        _AdminUserEditDialog(user: user, uploadAvatar: uploadAvatar),
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
  late final _avatar = TextEditingController(text: widget.user.avatarUrl ?? '');

  @override
  void dispose() {
    _avatar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Judul menyebut avatar, bukan "Edit <nama>": payload dialog ini hanya
      // memuat `avatar_url`, jadi harus cocok dengan label menu "Edit avatar".
      title: Text(
        'Edit avatar — ${widget.user.fullName ?? widget.user.username}',
      ),
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
            // Kolom kosong dikirim sebagai `null` EKSPLISIT, bukan key yang
            // diabaikan: `admin_update_user` pakai `exclude_unset=True`, jadi
            // key yang tidak dikirim tidak melakukan apa-apa. Tanpa null
            // eksplisit di sini, admin tidak akan bisa menghapus avatar.
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

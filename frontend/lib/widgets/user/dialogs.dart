import 'package:flutter/material.dart';
import 'package:frontend/models/experience_model.dart';
import 'package:frontend/models/project_model.dart';
import 'package:frontend/models/skill_model.dart';

const _skillCategories = ['Frontend', 'Backend', 'Database', 'Tools', 'Other'];

const _projectStatuses = ['draft', 'published'];

final _slugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

String? _nullIfEmpty(String v) => v.trim().isEmpty ? null : v.trim();

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

Widget _field(
  TextEditingController c,
  String label, {
  String? hint,
  int maxLines = 1,
  TextInputType? keyboard,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    ),
  );
}

/// Dialog tambah/edit proyek. Mengembalikan payload siap kirim ke
/// `createMyProject` / `updateMyProject`, atau null bila dibatalkan.
Future<Map<String, dynamic>?> showProjectDialog(
  BuildContext context, {
  ProjectModel? project,
  List<SkillModel> allSkills = const [],
}) async {
  final title = TextEditingController(text: project?.title ?? '');
  final slug = TextEditingController(text: project?.slug ?? '');
  final summary = TextEditingController(text: project?.summary ?? '');
  final liveUrl = TextEditingController(text: project?.liveUrl ?? '');
  final githubUrl = TextEditingController(text: project?.githubUrl ?? '');
  final coverUrl = TextEditingController(text: project?.coverImageUrl ?? '');
  final skillIds = TextEditingController(
    text: (project?.skills ?? []).map((s) => '${s.id}').join(', '),
  );
  var status = project?.status ?? 'published';

  final skillHint = allSkills.isEmpty
      ? 'Belum ada skill — kosongkan saja'
      : 'ID tersedia: ${allSkills.map((s) => '${s.id}=${s.name}').join(', ')}';

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(project == null ? 'Proyek baru' : 'Edit proyek'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(title, 'Judul*', hint: 'misal: Toko Online'),
                _field(slug, 'Slug*', hint: 'misal: toko-online'),
                _field(
                  summary,
                  'Ringkasan* (min 10 karakter)',
                  hint: 'Ceritakan proyek ini...',
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _projectStatuses.contains(status)
                      ? status
                      : 'published',
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _projectStatuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => status = v ?? 'published'),
                ),
                const SizedBox(height: 10),
                _field(
                  liveUrl,
                  'Live URL',
                  hint: 'https://...',
                  keyboard: TextInputType.url,
                ),
                _field(
                  githubUrl,
                  'GitHub URL',
                  hint: 'https://github.com/...',
                  keyboard: TextInputType.url,
                ),
                _field(
                  coverUrl,
                  'Cover image URL',
                  hint: 'https://.../cover.png (hasil upload cover)',
                  keyboard: TextInputType.url,
                ),
                _field(
                  skillIds,
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (title.text.trim().length < 3 ||
                  summary.text.trim().length < 10) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Judul (min 3) dan ringkasan (min 10) wajib diisi',
                    ),
                  ),
                );
                return;
              }
              if (!_slugPattern.hasMatch(slug.text.trim())) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Slug hanya huruf kecil, angka, dan strip (mis. toko-online)',
                    ),
                  ),
                );
                return;
              }
              final ids = skillIds.text
                  .split(',')
                  .map((e) => int.tryParse(e.trim()))
                  .whereType<int>()
                  .toList();
              final payload = <String, dynamic>{
                'title': title.text.trim(),
                'slug': slug.text.trim(),
                'summary': summary.text.trim(),
                'status': status,
                'skill_ids': ids,
                'live_url': _nullIfEmpty(liveUrl.text),
                'github_url': _nullIfEmpty(githubUrl.text),
                'cover_image_url': _nullIfEmpty(coverUrl.text),
              };
              Navigator.pop(ctx, payload);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ),
  );
}

/// Dialog tambah/edit skill -> payload `createMySkill` / `updateMySkill`.
Future<Map<String, dynamic>?> showSkillDialog(
  BuildContext context, {
  SkillModel? skill,
}) async {
  final name = TextEditingController(text: skill?.name ?? '');
  final proficiency = TextEditingController(
    text: skill?.proficiencyLevel?.toString() ?? '',
  );
  var category = skill?.category ?? 'Other';
  if (!_skillCategories.contains(category)) category = 'Other';

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(skill == null ? 'Skill baru' : 'Edit skill'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(name, 'Nama*', hint: 'misal: Flutter'),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _skillCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => category = v ?? 'Other'),
              ),
              const SizedBox(height: 10),
              _field(
                proficiency,
                'Proficiency (1-100, opsional)',
                hint: 'misal: 80',
                keyboard: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Nama skill wajib diisi')),
                );
                return;
              }
              final raw = proficiency.text.trim();
              final level = int.tryParse(raw);
              if (raw.isNotEmpty &&
                  (level == null || level < 1 || level > 100)) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Proficiency harus angka 1-100 atau kosong'),
                  ),
                );
                return;
              }
              Navigator.pop(ctx, <String, dynamic>{
                'name': name.text.trim(),
                'category': category,
                'proficiency_level': level,
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ),
  );
}

/// Dialog tambah/edit experience -> payload `createMyExperience` /
/// `updateMyExperience`. Tanggal format `YYYY-MM-DD`.
Future<Map<String, dynamic>?> showExperienceDialog(
  BuildContext context, {
  ExperienceModel? experience,
}) async {
  String fmt(DateTime? d) =>
      d == null ? '' : d.toIso8601String().substring(0, 10);
  final role = TextEditingController(text: experience?.role ?? '');
  final company = TextEditingController(text: experience?.company ?? '');
  final location = TextEditingController(text: experience?.location ?? '');
  final start = TextEditingController(text: fmt(experience?.startDate));
  final end = TextEditingController(text: fmt(experience?.endDate));
  final description = TextEditingController(
    text: experience?.description ?? '',
  );
  final tech = TextEditingController(
    text: (experience?.technologiesUsed ?? []).join(', '),
  );
  var isCurrent = experience?.isCurrent ?? false;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(experience == null ? 'Pengalaman baru' : 'Edit pengalaman'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(role, 'Role*', hint: 'misal: Frontend Engineer'),
                _field(company, 'Perusahaan*', hint: 'misal: FolioSpace'),
                _field(location, 'Lokasi', hint: 'misal: Jakarta'),
                _field(start, 'Mulai* (YYYY-MM-DD)', hint: 'misal: 2023-01-15'),
                _field(
                  end,
                  'Selesai (YYYY-MM-DD, kosong jika kini)',
                  hint: 'misal: 2024-06-30',
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Masih bekerja di sini'),
                  value: isCurrent,
                  onChanged: (v) => setState(() => isCurrent = v ?? false),
                ),
                _field(
                  description,
                  'Deskripsi',
                  hint: 'Ceritakan peranmu...',
                  maxLines: 3,
                ),
                _field(
                  tech,
                  'Teknologi (koma)',
                  hint: 'misal: Flutter, Go, Postgres',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final dateOk = RegExp(r'^\d{4}-\d{2}-\d{2}$');
              if (role.text.trim().length < 2 ||
                  company.text.trim().length < 2 ||
                  !dateOk.hasMatch(start.text.trim()) ||
                  (end.text.trim().isNotEmpty &&
                      !dateOk.hasMatch(end.text.trim()))) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Role, perusahaan (min 2), dan tanggal (YYYY-MM-DD) wajib valid',
                    ),
                  ),
                );
                return;
              }
              final techs = tech.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              Navigator.pop(ctx, <String, dynamic>{
                'role': role.text.trim(),
                'company': company.text.trim(),
                'location': _nullIfEmpty(location.text),
                'start_date': start.text.trim(),
                'end_date': isCurrent ? null : _nullIfEmpty(end.text),
                'is_current': isCurrent,
                'description': _nullIfEmpty(description.text),
                'technologies_used': techs,
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ),
  );
}

/// Dialog tambah media proyek -> dipakai `addMyProjectMedia`.
Future<Map<String, String>?> showProjectMediaDialog(
  BuildContext context,
) async {
  final url = TextEditingController();
  final caption = TextEditingController();
  var type = 'image';

  return showDialog<Map<String, String>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Tambah media proyek'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(
                url,
                'Media URL*',
                hint: 'https://... (hasil upload media)',
                keyboard: TextInputType.url,
              ),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(
                  labelText: 'Tipe',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const ['image', 'video', 'link']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => type = v ?? 'image'),
              ),
              const SizedBox(height: 10),
              _field(caption, 'Caption', hint: 'opsional'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (url.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Media URL wajib diisi')),
                );
                return;
              }
              Navigator.pop(ctx, {
                'media_url': url.text.trim(),
                'media_type': type,
                'caption': caption.text.trim(),
              });
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    ),
  );
}

/// Dialog ganti password -> [current, baru], atau null bila dibatalkan.
Future<List<String>?> showChangePasswordDialog(BuildContext context) async {
  final current = TextEditingController();
  final fresh = TextEditingController();
  final confirm = TextEditingController();

  return showDialog<List<String>>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Ganti password'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(current, 'Password saat ini'),
            _field(fresh, 'Password baru (min 8)'),
            _field(confirm, 'Ulangi password baru'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (fresh.text.length < 8) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Password baru minimal 8 karakter'),
                ),
              );
              return;
            }
            if (fresh.text != confirm.text) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Konfirmasi password tidak cocok'),
                ),
              );
              return;
            }
            Navigator.pop(ctx, [current.text, fresh.text]);
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}

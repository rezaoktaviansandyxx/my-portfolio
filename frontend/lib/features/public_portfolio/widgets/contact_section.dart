import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/errors.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/skeleton.dart';

/// Form kontak publik: sender_name/sender_email/subject/content
/// -> POST /public/u/{slug}/contact.
/// Rate limit backend: 5 pesan/menit.
class ContactSection extends ConsumerStatefulWidget {
  final String slug;

  const ContactSection({super.key, required this.slug});

  @override
  ConsumerState<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends ConsumerState<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _sending = false;
  String? _notice;
  bool _noticeIsError = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _sending = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.sendContact(
        widget.slug,
        MessageCreateModel(
          senderName: _nameCtrl.text.trim(),
          senderEmail: _emailCtrl.text.trim(),
          subject: _subjectCtrl.text.trim().isEmpty
              ? null
              : _subjectCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
        ),
      );
      if (!mounted) return;
      _formKey.currentState?.reset();
      _nameCtrl.clear();
      _emailCtrl.clear();
      _subjectCtrl.clear();
      _contentCtrl.clear();
      setState(() {
        _noticeIsError = false;
        _notice = 'Pesan terkirim. Kreator akan membalas via email.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _noticeIsError = true;
        _notice = e is ApiException && e.isRateLimited
            ? 'Batas 5 pesan per menit tercapai. Coba lagi sebentar.'
            : friendlyError(e, 'Gagal mengirim pesan');
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted;
    final wide = MediaQuery.sizeOf(context).width >= 700;

    final header = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.mail_outline_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hubungi Saya',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
              Text(
                'Pesan akan dikirim langsung ke email kreator.',
                style: TextStyle(color: muted, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ],
    );

    final nameField = TextFormField(
      controller: _nameCtrl,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        hintText: 'Nama lengkap',
        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
    );

    final emailField = TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'email@contoh.com',
        prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
      ),
      validator: (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return 'Email wajib diisi';
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
          return 'Format email tidak valid';
        }
        return null;
      },
    );

    final subjectField = TextFormField(
      controller: _subjectCtrl,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        hintText: 'Tentang apa pesan ini?',
        prefixIcon: Icon(Icons.tag_rounded, size: 20),
      ),
    );

    final contentField = TextFormField(
      controller: _contentCtrl,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        hintText: 'Ceritakan proyek atau kebutuhanmu...',
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Pesan wajib diisi' : null,
    );

    final submitBtn = SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _sending ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.indigo,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.indigo.withValues(alpha: 0.55),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        icon: _sending
            ? const SkeletonBox(width: 16, height: 16, radius: 8)
            : const Icon(Icons.send_rounded, size: 17),
        label: Text(
          _sending ? 'Mengirim...' : 'Kirim Pesan',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );

    final rateNote = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 13, color: muted),
        const SizedBox(width: 5),
        Text(
          'Dilindungi rate limit: maksimal 5 pesan per menit.',
          style: TextStyle(color: muted, fontSize: 11.5),
        ),
      ],
    );

    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 16),
            if (wide) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: nameField),
                  const SizedBox(width: 12),
                  Expanded(child: emailField),
                ],
              ),
              const SizedBox(height: 12),
            ] else ...[
              nameField,
              const SizedBox(height: 12),
              emailField,
              const SizedBox(height: 12),
            ],
            subjectField,
            const SizedBox(height: 12),
            contentField,
            if (_notice != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      (_noticeIsError ? AppColors.danger : AppColors.success)
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        (_noticeIsError ? AppColors.danger : AppColors.success)
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
            const SizedBox(height: 18),
            submitBtn,
            const SizedBox(height: 10),
            rateNote,
          ],
        ),
      ),
    );
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'public_profile_model.g.dart';

/// Profil publik kreator untuk halaman `/u/:slug`.
///
/// PENTING: model ini BERBEDA dari [UserModel] dengan sengaja.
/// Backend memakai schema `PublicProfileResponse`
/// (`backend/app/schemas/auth.py`) yang hanya mengirim field yang pantas
/// tampil ke pengunjung: `username`, `full_name`, `headline`, `bio`,
/// `avatar_url`, `resume_url`, `profile_slug`.
///
/// Field internal seperti `id`, `email`, `role`, `is_active`, dan
/// `is_published` TIDAK dikirim backend (ada test anti-bocor di
/// `backend/tests/test_low_items.py::test_public_profile_hides_internal_fields`).
/// Karena itu model publik tidak punya field tersebut sama sekali —
/// kalau ditambah, email login kreator bisa bocor ke UI publik.
@JsonSerializable()
class PublicProfileModel {
  final String username;
  @JsonKey(name: 'full_name') final String? fullName;
  final String? headline;
  final String? bio;
  @JsonKey(name: 'avatar_url') final String? avatarUrl;
  @JsonKey(name: 'resume_url') final String? resumeUrl;
  @JsonKey(name: 'profile_slug') final String? profileSlug;

  PublicProfileModel({
    required this.username,
    this.fullName,
    this.headline,
    this.bio,
    this.avatarUrl,
    this.resumeUrl,
    this.profileSlug,
  });

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$PublicProfileModelToJson(this);
}

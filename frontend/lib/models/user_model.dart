import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'full_name') final String? fullName;
  final String? headline;
  final String? bio;
  @JsonKey(name: 'profile_slug') final String? profileSlug;
  @JsonKey(name: 'avatar_url') final String? avatarUrl;
  @JsonKey(name: 'resume_url') final String? resumeUrl;
  @JsonKey(name: 'is_published') final bool isPublished;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.headline,
    this.bio,
    this.profileSlug,
    this.avatarUrl,
    this.resumeUrl,
    this.isPublished = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

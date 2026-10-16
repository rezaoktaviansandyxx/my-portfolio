// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String?,
  headline: json['headline'] as String?,
  bio: json['bio'] as String?,
  profileSlug: json['profile_slug'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  resumeUrl: json['resume_url'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  role: json['role'] as String?,
  isPublished: json['is_published'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'full_name': instance.fullName,
  'headline': instance.headline,
  'bio': instance.bio,
  'profile_slug': instance.profileSlug,
  'avatar_url': instance.avatarUrl,
  'resume_url': instance.resumeUrl,
  'is_active': instance.isActive,
  'role': instance.role,
  'is_published': instance.isPublished,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicProfileModel _$PublicProfileModelFromJson(Map<String, dynamic> json) =>
    PublicProfileModel(
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      headline: json['headline'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      resumeUrl: json['resume_url'] as String?,
      profileSlug: json['profile_slug'] as String?,
    );

Map<String, dynamic> _$PublicProfileModelToJson(PublicProfileModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'full_name': instance.fullName,
      'headline': instance.headline,
      'bio': instance.bio,
      'avatar_url': instance.avatarUrl,
      'resume_url': instance.resumeUrl,
      'profile_slug': instance.profileSlug,
    };

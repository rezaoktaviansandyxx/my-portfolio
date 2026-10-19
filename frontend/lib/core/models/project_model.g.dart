// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  slug: json['slug'] as String,
  summary: json['summary'] as String?,
  problemStatement: json['problem_statement'] as String?,
  solution: json['solution'] as String?,
  keyFeatures: (json['key_features'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  coverImageUrl: json['cover_image_url'] as String?,
  metaDescription: json['meta_description'] as String?,
  liveUrl: json['live_url'] as String?,
  githubUrl: json['github_url'] as String?,
  isFeatured: json['is_featured'] as bool? ?? false,
  status: json['status'] as String?,
  displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
  media: (json['media'] as List<dynamic>?)
      ?.map((e) => ProjectMediaModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  skills: (json['skills'] as List<dynamic>?)
      ?.map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  owner: json['owner'] == null
      ? null
      : ProjectOwnerModel.fromJson(json['owner'] as Map<String, dynamic>),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'summary': instance.summary,
      'problem_statement': instance.problemStatement,
      'solution': instance.solution,
      'key_features': instance.keyFeatures,
      'cover_image_url': instance.coverImageUrl,
      'meta_description': instance.metaDescription,
      'live_url': instance.liveUrl,
      'github_url': instance.githubUrl,
      'is_featured': instance.isFeatured,
      'status': instance.status,
      'display_order': instance.displayOrder,
      'media': instance.media,
      'skills': instance.skills,
      'owner': instance.owner,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

ProjectMediaModel _$ProjectMediaModelFromJson(Map<String, dynamic> json) =>
    ProjectMediaModel(
      id: (json['id'] as num).toInt(),
      mediaUrl: json['media_url'] as String,
      mediaType: json['media_type'] as String?,
      caption: json['caption'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProjectMediaModelToJson(ProjectMediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media_url': instance.mediaUrl,
      'media_type': instance.mediaType,
      'caption': instance.caption,
      'display_order': instance.displayOrder,
    };

ProjectOwnerModel _$ProjectOwnerModelFromJson(Map<String, dynamic> json) =>
    ProjectOwnerModel(
      profileSlug: json['profile_slug'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$ProjectOwnerModelToJson(ProjectOwnerModel instance) =>
    <String, dynamic>{
      'profile_slug': instance.profileSlug,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
    };

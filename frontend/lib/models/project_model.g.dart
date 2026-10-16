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
  description: json['description'] as String?,
  status: json['status'] as String?,
  coverImage: json['cover_image'] as String?,
  projectUrl: json['project_url'] as String?,
  githubUrl: json['github_url'] as String?,
  media: (json['media'] as List<dynamic>?)
      ?.map((e) => ProjectMediaModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  skills: (json['skills'] as List<dynamic>?)
      ?.map((e) => SkillBriefModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'summary': instance.summary,
      'description': instance.description,
      'status': instance.status,
      'cover_image': instance.coverImage,
      'project_url': instance.projectUrl,
      'github_url': instance.githubUrl,
      'media': instance.media,
      'skills': instance.skills,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ProjectMediaModel _$ProjectMediaModelFromJson(Map<String, dynamic> json) =>
    ProjectMediaModel(
      id: (json['id'] as num).toInt(),
      mediaUrl: json['media_url'] as String,
      mediaType: json['media_type'] as String?,
      caption: json['caption'] as String?,
    );

Map<String, dynamic> _$ProjectMediaModelToJson(ProjectMediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media_url': instance.mediaUrl,
      'media_type': instance.mediaType,
      'caption': instance.caption,
    };

SkillBriefModel _$SkillBriefModelFromJson(Map<String, dynamic> json) =>
    SkillBriefModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String?,
      iconUrl: json['icon_url'] as String?,
    );

Map<String, dynamic> _$SkillBriefModelToJson(SkillBriefModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'icon_url': instance.iconUrl,
    };

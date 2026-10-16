import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  final int id;
  final String title;
  final String slug;
  final String? summary;
  final String? description;
  final String? status;
  @JsonKey(name: 'cover_image') final String? coverImage;
  @JsonKey(name: 'project_url') final String? projectUrl;
  @JsonKey(name: 'github_url') final String? githubUrl;
  final List<ProjectMediaModel>? media;
  final List<SkillBriefModel>? skills;
  @JsonKey(name: 'created_at') final DateTime createdAt;
  @JsonKey(name: 'updated_at') final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    this.description,
    this.status,
    this.coverImage,
    this.projectUrl,
    this.githubUrl,
    this.media,
    this.skills,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
}

@JsonSerializable()
class ProjectMediaModel {
  final int id;
  @JsonKey(name: 'media_url') final String mediaUrl;
  @JsonKey(name: 'media_type') final String? mediaType;
  final String? caption;

  ProjectMediaModel({
    required this.id,
    required this.mediaUrl,
    this.mediaType,
    this.caption,
  });

  factory ProjectMediaModel.fromJson(Map<String, dynamic> json) => _$ProjectMediaModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectMediaModelToJson(this);
}

@JsonSerializable()
class SkillBriefModel {
  final int id;
  final String name;
  final String? category;
  @JsonKey(name: 'icon_url') final String? iconUrl;

  SkillBriefModel({
    required this.id,
    required this.name,
    this.category,
    this.iconUrl,
  });

  factory SkillBriefModel.fromJson(Map<String, dynamic> json) => _$SkillBriefModelFromJson(json);
  Map<String, dynamic> toJson() => _$SkillBriefModelToJson(this);
}

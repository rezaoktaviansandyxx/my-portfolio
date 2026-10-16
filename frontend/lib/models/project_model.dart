import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/models/skill_model.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  final int id;
  final String title;
  final String slug;
  final String? summary;
  @JsonKey(name: 'problem_statement') final String? problemStatement;
  final String? solution;
  @JsonKey(name: 'key_features') final List<String>? keyFeatures;
  @JsonKey(name: 'cover_image_url') final String? coverImageUrl;
  @JsonKey(name: 'meta_description') final String? metaDescription;
  @JsonKey(name: 'live_url') final String? liveUrl;
  @JsonKey(name: 'github_url') final String? githubUrl;
  @JsonKey(name: 'is_featured') final bool isFeatured;
  final String? status;
  @JsonKey(name: 'display_order') final int displayOrder;
  final List<ProjectMediaModel>? media;
  final List<SkillModel>? skills;
  @JsonKey(name: 'created_at') final DateTime? createdAt;
  @JsonKey(name: 'updated_at') final DateTime? updatedAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    this.problemStatement,
    this.solution,
    this.keyFeatures,
    this.coverImageUrl,
    this.metaDescription,
    this.liveUrl,
    this.githubUrl,
    this.isFeatured = false,
    this.status,
    this.displayOrder = 0,
    this.media,
    this.skills,
    this.createdAt,
    this.updatedAt,
  });

  // Kompatibilitas dengan widget lama
  String? get coverImage => coverImageUrl;
  String? get projectUrl => liveUrl;

  factory ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
}

@JsonSerializable()
class ProjectMediaModel {
  final int id;
  @JsonKey(name: 'media_url') final String mediaUrl;
  @JsonKey(name: 'media_type') final String? mediaType;
  final String? caption;
  @JsonKey(name: 'display_order') final int displayOrder;

  ProjectMediaModel({
    required this.id,
    required this.mediaUrl,
    this.mediaType,
    this.caption,
    this.displayOrder = 0,
  });

  factory ProjectMediaModel.fromJson(Map<String, dynamic> json) => _$ProjectMediaModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectMediaModelToJson(this);
}

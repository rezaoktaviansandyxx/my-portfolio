import 'package:json_annotation/json_annotation.dart';

part 'experience_model.g.dart';

@JsonSerializable()
class ExperienceModel {
  final int id;
  final String role;
  final String company;
  final String? location;
  @JsonKey(name: 'employment_type') final String? employmentType;
  @JsonKey(name: 'start_date') final DateTime? startDate;
  @JsonKey(name: 'end_date') final DateTime? endDate;
  @JsonKey(name: 'is_current') final bool isCurrent;
  final String? description;
  @JsonKey(name: 'technologies_used') final List<String>? technologiesUsed;

  ExperienceModel({
    required this.id,
    required this.role,
    required this.company,
    this.location,
    this.employmentType,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
    this.technologiesUsed,
  });

  // Kompatibilitas widget lama (title -> role)
  String get title => role;

  factory ExperienceModel.fromJson(Map<String, dynamic> json) => _$ExperienceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExperienceModelToJson(this);
}

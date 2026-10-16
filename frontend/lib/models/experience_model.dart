import 'package:json_annotation/json_annotation.dart';

part 'experience_model.g.dart';

@JsonSerializable()
class ExperienceModel {
  final int id;
  final String title;
  final String? company;
  final String? location;
  @JsonKey(name: 'start_date') final DateTime? startDate;
  @JsonKey(name: 'end_date') final DateTime? endDate;
  @JsonKey(name: 'is_current') final bool isCurrent;
  final String? description;
  final String? industry;

  ExperienceModel({
    required this.id,
    required this.title,
    this.company,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
    this.industry,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) => _$ExperienceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExperienceModelToJson(this);
}

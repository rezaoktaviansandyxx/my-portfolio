import 'package:json_annotation/json_annotation.dart';

part 'skill_model.g.dart';

@JsonSerializable()
class SkillModel {
  final int id;
  final String name;
  final String? category;
  @JsonKey(name: 'proficiency_level') final int? proficiencyLevel;
  @JsonKey(name: 'icon_url') final String? iconUrl;
  @JsonKey(name: 'display_order') final int? displayOrder;

  SkillModel({
    required this.id,
    required this.name,
    this.category,
    this.proficiencyLevel,
    this.iconUrl,
    this.displayOrder,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) => _$SkillModelFromJson(json);
  Map<String, dynamic> toJson() => _$SkillModelToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkillModel _$SkillModelFromJson(Map<String, dynamic> json) => SkillModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  category: json['category'] as String?,
  iconUrl: json['icon_url'] as String?,
  displayOrder: (json['display_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$SkillModelToJson(SkillModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'icon_url': instance.iconUrl,
      'display_order': instance.displayOrder,
    };

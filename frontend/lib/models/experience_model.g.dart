// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experience_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperienceModel _$ExperienceModelFromJson(Map<String, dynamic> json) =>
    ExperienceModel(
      id: (json['id'] as num).toInt(),
      role: json['role'] as String,
      company: json['company'] as String,
      location: json['location'] as String?,
      employmentType: json['employment_type'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      isCurrent: json['is_current'] as bool? ?? false,
      description: json['description'] as String?,
      technologiesUsed: (json['technologies_used'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ExperienceModelToJson(ExperienceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'company': instance.company,
      'location': instance.location,
      'employment_type': instance.employmentType,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'is_current': instance.isCurrent,
      'description': instance.description,
      'technologies_used': instance.technologiesUsed,
    };

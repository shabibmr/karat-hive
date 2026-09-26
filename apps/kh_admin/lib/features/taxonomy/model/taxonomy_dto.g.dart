// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateTaxonomyDto _$CreateTaxonomyDtoFromJson(Map<String, dynamic> json) =>
    _CreateTaxonomyDto(
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      icon: json['icon'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$CreateTaxonomyDtoToJson(_CreateTaxonomyDto instance) =>
    <String, dynamic>{
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'icon': instance.icon,
      'displayOrder': instance.displayOrder,
      'isActive': instance.isActive,
    };

_UpdateTaxonomyDto _$UpdateTaxonomyDtoFromJson(Map<String, dynamic> json) =>
    _UpdateTaxonomyDto(
      nameEn: json['nameEn'] as String?,
      nameAr: json['nameAr'] as String?,
      icon: json['icon'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$UpdateTaxonomyDtoToJson(_UpdateTaxonomyDto instance) =>
    <String, dynamic>{
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'icon': instance.icon,
      'displayOrder': instance.displayOrder,
      'isActive': instance.isActive,
    };

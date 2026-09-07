// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateTaxonomyDtoImpl _$$CreateTaxonomyDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CreateTaxonomyDtoImpl(
  parentId: json['parentId'] as String?,
  nameEn: json['nameEn'] as String,
  nameAr: json['nameAr'] as String,
  icon: json['icon'] as String?,
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$CreateTaxonomyDtoImplToJson(
  _$CreateTaxonomyDtoImpl instance,
) => <String, dynamic>{
  'parentId': instance.parentId,
  'nameEn': instance.nameEn,
  'nameAr': instance.nameAr,
  'icon': instance.icon,
  'displayOrder': instance.displayOrder,
  'isActive': instance.isActive,
};

_$UpdateTaxonomyDtoImpl _$$UpdateTaxonomyDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateTaxonomyDtoImpl(
  parentId: json['parentId'] as String?,
  nameEn: json['nameEn'] as String?,
  nameAr: json['nameAr'] as String?,
  icon: json['icon'] as String?,
  displayOrder: (json['displayOrder'] as num?)?.toInt(),
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$$UpdateTaxonomyDtoImplToJson(
  _$UpdateTaxonomyDtoImpl instance,
) => <String, dynamic>{
  'parentId': instance.parentId,
  'nameEn': instance.nameEn,
  'nameAr': instance.nameAr,
  'icon': instance.icon,
  'displayOrder': instance.displayOrder,
  'isActive': instance.isActive,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaxonomyNodeImpl _$$TaxonomyNodeImplFromJson(Map<String, dynamic> json) =>
    _$TaxonomyNodeImpl(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      icon: json['icon'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$TaxonomyNodeImplToJson(_$TaxonomyNodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'icon': instance.icon,
      'displayOrder': instance.displayOrder,
      'isActive': instance.isActive,
    };

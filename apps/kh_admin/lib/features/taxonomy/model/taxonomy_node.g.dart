// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaxonomyNode _$TaxonomyNodeFromJson(Map<String, dynamic> json) =>
    _TaxonomyNode(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      icon: json['icon'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$TaxonomyNodeToJson(_TaxonomyNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'icon': instance.icon,
      'displayOrder': instance.displayOrder,
      'isActive': instance.isActive,
    };

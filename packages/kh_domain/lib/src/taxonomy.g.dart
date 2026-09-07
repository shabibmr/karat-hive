// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaxonomyNode _$TaxonomyNodeFromJson(Map<String, dynamic> json) =>
    _TaxonomyNode(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => TaxonomyNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TaxonomyNode>[],
    );

Map<String, dynamic> _$TaxonomyNodeToJson(_TaxonomyNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'children': instance.children,
    };

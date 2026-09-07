// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_preset_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FilterPresetItem _$FilterPresetItemFromJson(Map<String, dynamic> json) =>
    _FilterPresetItem(
      id: json['id'] as String,
      name: json['name'] as String,
      filters:
          json['filters'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FilterPresetItemToJson(_FilterPresetItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'filters': instance.filters,
      'createdAt': instance.createdAt.toIso8601String(),
    };

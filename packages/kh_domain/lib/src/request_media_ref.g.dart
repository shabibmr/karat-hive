// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_media_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RequestMediaRef _$RequestMediaRefFromJson(Map<String, dynamic> json) =>
    _RequestMediaRef(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      contentType: json['contentType'] as String? ?? 'image/jpeg',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      displayUrl: json['displayUrl'] as String?,
    );

Map<String, dynamic> _$RequestMediaRefToJson(_RequestMediaRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'contentType': instance.contentType,
      'displayOrder': instance.displayOrder,
      'thumbnailUrl': instance.thumbnailUrl,
      'displayUrl': instance.displayUrl,
    };

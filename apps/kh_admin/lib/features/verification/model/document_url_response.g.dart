// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_url_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentUrlResponse _$DocumentUrlResponseFromJson(Map<String, dynamic> json) =>
    _DocumentUrlResponse(
      url: json['url'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$DocumentUrlResponseToJson(
  _DocumentUrlResponse instance,
) => <String, dynamic>{
  'url': instance.url,
  'expiresAt': instance.expiresAt.toIso8601String(),
};

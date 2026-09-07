// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_url_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentUrlResponseImpl _$$DocumentUrlResponseImplFromJson(
  Map<String, dynamic> json,
) => _$DocumentUrlResponseImpl(
  url: json['url'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$$DocumentUrlResponseImplToJson(
  _$DocumentUrlResponseImpl instance,
) => <String, dynamic>{
  'url': instance.url,
  'expiresAt': instance.expiresAt.toIso8601String(),
};

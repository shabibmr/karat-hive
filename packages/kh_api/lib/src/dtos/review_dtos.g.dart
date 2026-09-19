// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewDto _$ReviewDtoFromJson(Map<String, dynamic> json) => _ReviewDto(
  id: json['id'] as String,
  connectionId: json['connectionId'] as String,
  authorType: json['authorType'] as String,
  authorDisplayName: json['authorDisplayName'] as String?,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  state: json['state'] as String,
  vendorResponse: json['vendorResponse'] == null
      ? null
      : ReviewResponseDto.fromJson(
          json['vendorResponse'] as Map<String, dynamic>,
        ),
  editableUntil: DateTime.parse(json['editableUntil'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$ReviewDtoToJson(_ReviewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'connectionId': instance.connectionId,
      'authorType': instance.authorType,
      'authorDisplayName': instance.authorDisplayName,
      'rating': instance.rating,
      'comment': instance.comment,
      'state': instance.state,
      'vendorResponse': instance.vendorResponse,
      'editableUntil': instance.editableUntil.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };

_ReviewResponseDto _$ReviewResponseDtoFromJson(Map<String, dynamic> json) =>
    _ReviewResponseDto(
      text: json['text'] as String,
      state: json['state'] as String,
    );

Map<String, dynamic> _$ReviewResponseDtoToJson(_ReviewResponseDto instance) =>
    <String, dynamic>{'text': instance.text, 'state': instance.state};

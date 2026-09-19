// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewVendorResponse _$ReviewVendorResponseFromJson(
  Map<String, dynamic> json,
) => _ReviewVendorResponse(
  text: json['text'] as String,
  state: const _ReviewStateConverter().fromJson(json['state'] as String?),
);

Map<String, dynamic> _$ReviewVendorResponseToJson(
  _ReviewVendorResponse instance,
) => <String, dynamic>{
  'text': instance.text,
  'state': const _ReviewStateConverter().toJson(instance.state),
};

_Review _$ReviewFromJson(Map<String, dynamic> json) => _Review(
  id: json['id'] as String,
  connectionId: json['connectionId'] as String,
  authorType: const _PartyRoleConverter().fromJson(
    json['authorType'] as String?,
  ),
  rating: (json['rating'] as num).toInt(),
  state: const _ReviewStateConverter().fromJson(json['state'] as String?),
  editableUntil: DateTime.parse(json['editableUntil'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  comment: json['comment'] as String?,
  vendorResponse: json['vendorResponse'] == null
      ? null
      : ReviewVendorResponse.fromJson(
          json['vendorResponse'] as Map<String, dynamic>,
        ),
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  authorDisplayName: json['authorDisplayName'] as String?,
);

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  'id': instance.id,
  'connectionId': instance.connectionId,
  'authorType': const _PartyRoleConverter().toJson(instance.authorType),
  'rating': instance.rating,
  'state': const _ReviewStateConverter().toJson(instance.state),
  'editableUntil': instance.editableUntil.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'comment': instance.comment,
  'vendorResponse': instance.vendorResponse?.toJson(),
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'authorDisplayName': instance.authorDisplayName,
};

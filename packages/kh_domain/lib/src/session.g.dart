// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerMe _$CustomerMeFromJson(Map<String, dynamic> json) => _CustomerMe(
  displayName: json['displayName'] as String,
  reviewCount: (json['reviewCount'] as num).toInt(),
  connectionCount: (json['connectionCount'] as num).toInt(),
  photoUrl: json['photoUrl'] as String?,
  defaultRegion: const _DefaultRegionConverter().fromJson(
    json['defaultRegion'],
  ),
  rating: const _NullableRatingSummaryConverter().fromJson(json['rating']),
  liveRequestCount: (json['liveRequestCount'] as num?)?.toInt(),
  canCreateRequest: json['canCreateRequest'] as bool?,
  lifetimeRequestCount: (json['lifetimeRequestCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$CustomerMeToJson(_CustomerMe instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'reviewCount': instance.reviewCount,
      'connectionCount': instance.connectionCount,
      'photoUrl': instance.photoUrl,
      'defaultRegion': const _DefaultRegionConverter().toJson(
        instance.defaultRegion,
      ),
      'rating': const _NullableRatingSummaryConverter().toJson(instance.rating),
      'liveRequestCount': instance.liveRequestCount,
      'canCreateRequest': instance.canCreateRequest,
      'lifetimeRequestCount': instance.lifetimeRequestCount,
    };

_BusinessDayHours _$BusinessDayHoursFromJson(Map<String, dynamic> json) =>
    _BusinessDayHours(
      open: json['open'] as String,
      close: json['close'] as String,
      closed: json['closed'] as bool? ?? false,
    );

Map<String, dynamic> _$BusinessDayHoursToJson(_BusinessDayHours instance) =>
    <String, dynamic>{
      'open': instance.open,
      'close': instance.close,
      'closed': instance.closed,
    };

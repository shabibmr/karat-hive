// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_queue_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerificationQueueItem _$VerificationQueueItemFromJson(
  Map<String, dynamic> json,
) => _VerificationQueueItem(
  id: json['id'] as String,
  legalBusinessName: json['legalBusinessName'] as String,
  tradeLicenceNumber: json['tradeLicenceNumber'] as String,
  oldestWaitingHours: (json['oldestWaitingHours'] as num?)?.toDouble() ?? 0,
  tradingName: json['tradingName'] as String?,
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
);

Map<String, dynamic> _$VerificationQueueItemToJson(
  _VerificationQueueItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'legalBusinessName': instance.legalBusinessName,
  'tradeLicenceNumber': instance.tradeLicenceNumber,
  'oldestWaitingHours': instance.oldestWaitingHours,
  'tradingName': instance.tradingName,
  'submittedAt': instance.submittedAt?.toIso8601String(),
};

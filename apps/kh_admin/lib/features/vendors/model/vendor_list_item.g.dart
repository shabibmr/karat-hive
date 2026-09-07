// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VendorListItemImpl _$$VendorListItemImplFromJson(Map<String, dynamic> json) =>
    _$VendorListItemImpl(
      id: json['id'] as String,
      legalBusinessName: json['legalBusinessName'] as String,
      tradingName: json['tradingName'] as String,
      verificationState: $enumDecode(
        _$VendorVerificationStateEnumMap,
        json['verificationState'],
        unknownValue: VendorVerificationState.registered,
      ),
      accountState: $enumDecode(
        _$VendorAccountStateEnumMap,
        json['accountState'],
        unknownValue: VendorAccountState.active,
      ),
      tradeLicenceNumber: json['tradeLicenceNumber'] as String?,
      region: json['region'] as String?,
      offerCount: (json['offerCount'] as num?)?.toInt(),
      acceptanceRate: (json['acceptanceRate'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      waitingHours: (json['oldestWaitingHours'] as num?)?.toInt(),
      registeredAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$VendorListItemImplToJson(
  _$VendorListItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'legalBusinessName': instance.legalBusinessName,
  'tradingName': instance.tradingName,
  'verificationState':
      _$VendorVerificationStateEnumMap[instance.verificationState]!,
  'accountState': _$VendorAccountStateEnumMap[instance.accountState]!,
  'tradeLicenceNumber': instance.tradeLicenceNumber,
  'region': instance.region,
  'offerCount': instance.offerCount,
  'acceptanceRate': instance.acceptanceRate,
  'rating': instance.rating,
  'oldestWaitingHours': instance.waitingHours,
  'createdAt': instance.registeredAt?.toIso8601String(),
};

const _$VendorVerificationStateEnumMap = {
  VendorVerificationState.registered: 'REGISTERED',
  VendorVerificationState.pendingVerification: 'PENDING_VERIFICATION',
  VendorVerificationState.verified: 'VERIFIED',
  VendorVerificationState.rejected: 'REJECTED',
};

const _$VendorAccountStateEnumMap = {
  VendorAccountState.active: 'ACTIVE',
  VendorAccountState.suspended: 'SUSPENDED',
  VendorAccountState.deactivated: 'DEACTIVATED',
};

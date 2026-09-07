// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VendorMe _$VendorMeFromJson(Map<String, dynamic> json) => _VendorMe(
  vendorProfileId: json['vendorProfileId'] as String,
  lifecycle: const _VendorLifecycleConverter().fromJson(
    json['lifecycle'] as String?,
  ),
  awaitingApproval: json['awaitingApproval'] as bool,
  tradingName: json['tradingName'] as String,
  legalBusinessName: json['legalBusinessName'] as String,
  categoryCount: (json['categoryCount'] as num).toInt(),
  regionCount: (json['regionCount'] as num).toInt(),
  categoryIds:
      (json['categoryIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  regionIds:
      (json['regionIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  awayMode: json['awayMode'] as bool? ?? false,
  awaitingApprovalReason: const _AwaitingApprovalReasonConverter().fromJson(
    json['awaitingApprovalReason'] as String?,
  ),
  verificationMessage: json['verificationMessage'] as String?,
);

Map<String, dynamic> _$VendorMeToJson(_VendorMe instance) => <String, dynamic>{
  'vendorProfileId': instance.vendorProfileId,
  'lifecycle': const _VendorLifecycleConverter().toJson(instance.lifecycle),
  'awaitingApproval': instance.awaitingApproval,
  'tradingName': instance.tradingName,
  'legalBusinessName': instance.legalBusinessName,
  'categoryCount': instance.categoryCount,
  'regionCount': instance.regionCount,
  'categoryIds': instance.categoryIds,
  'regionIds': instance.regionIds,
  'awayMode': instance.awayMode,
  'awaitingApprovalReason': const _AwaitingApprovalReasonConverter().toJson(
    instance.awaitingApprovalReason,
  ),
  'verificationMessage': instance.verificationMessage,
};

_MeUser _$MeUserFromJson(Map<String, dynamic> json) => _MeUser(
  userId: json['userId'] as String,
  userType: json['userType'] as String,
  mobileNumber: json['mobileNumber'] as String,
  preferredLanguage: json['preferredLanguage'] as String,
  email: json['email'] as String?,
  vendor: json['vendor'] == null
      ? null
      : VendorMe.fromJson(json['vendor'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MeUserToJson(_MeUser instance) => <String, dynamic>{
  'userId': instance.userId,
  'userType': instance.userType,
  'mobileNumber': instance.mobileNumber,
  'preferredLanguage': instance.preferredLanguage,
  'email': instance.email,
  'vendor': instance.vendor,
};

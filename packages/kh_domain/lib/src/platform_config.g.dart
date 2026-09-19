// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlatformConfig _$PlatformConfigFromJson(
  Map<String, dynamic> json,
) => _PlatformConfig(
  requestLifetimeHours: (json['requestLifetimeHours'] as num?)?.toInt() ?? 48,
  offerValidityHours:
      (json['offerValidityHours'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [12, 24, 48],
  defaultOfferValidityHours:
      (json['defaultOfferValidityHours'] as num?)?.toInt() ?? 24,
  bullionMinimumAed: json['bullionMinimumAed'] as String? ?? '5000',
  maxConcurrentLiveRequests:
      (json['maxConcurrentLiveRequests'] as num?)?.toInt() ?? 3,
  maxRequestImages: (json['maxRequestImages'] as num?)?.toInt() ?? 5,
  maxOfferImages: (json['maxOfferImages'] as num?)?.toInt() ?? 3,
  maxImageBytes: (json['maxImageBytes'] as num?)?.toInt() ?? 0,
  acceptedImageTypes:
      (json['acceptedImageTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['image/jpeg', 'image/png', 'image/webp'],
  karatList:
      (json['karatList'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const ['18', '21', '22', '24'],
  maxOfferRevisions: (json['maxOfferRevisions'] as num?)?.toInt() ?? 3,
  requestExpiryWarningHours:
      (json['requestExpiryWarningHours'] as num?)?.toInt() ?? 6,
  termsUrl: json['termsUrl'] as String?,
  privacyUrl: json['privacyUrl'] as String?,
  supportContactUrl: json['supportContactUrl'] as String?,
  subscriptionContactUrl: json['subscriptionContactUrl'] as String?,
);

Map<String, dynamic> _$PlatformConfigToJson(_PlatformConfig instance) =>
    <String, dynamic>{
      'requestLifetimeHours': instance.requestLifetimeHours,
      'offerValidityHours': instance.offerValidityHours,
      'defaultOfferValidityHours': instance.defaultOfferValidityHours,
      'bullionMinimumAed': instance.bullionMinimumAed,
      'maxConcurrentLiveRequests': instance.maxConcurrentLiveRequests,
      'maxRequestImages': instance.maxRequestImages,
      'maxOfferImages': instance.maxOfferImages,
      'maxImageBytes': instance.maxImageBytes,
      'acceptedImageTypes': instance.acceptedImageTypes,
      'karatList': instance.karatList,
      'maxOfferRevisions': instance.maxOfferRevisions,
      'requestExpiryWarningHours': instance.requestExpiryWarningHours,
      'termsUrl': instance.termsUrl,
      'privacyUrl': instance.privacyUrl,
      'supportContactUrl': instance.supportContactUrl,
      'subscriptionContactUrl': instance.subscriptionContactUrl,
    };

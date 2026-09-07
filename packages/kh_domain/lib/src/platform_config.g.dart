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
  maxOfferRevisions: (json['maxOfferRevisions'] as num?)?.toInt() ?? 3,
  requestExpiryWarningHours:
      (json['requestExpiryWarningHours'] as num?)?.toInt() ?? 6,
  karatList:
      (json['karatList'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const ['18', '21', '22', '24'],
  supportContactUrl:
      json['supportContactUrl'] as String? ?? 'https://karathive.ae/support',
  subscriptionContactUrl:
      json['subscriptionContactUrl'] as String? ??
      'https://karathive.ae/subscriptions',
  termsUrl: json['termsUrl'] as String? ?? 'https://karathive.ae/terms',
  privacyUrl: json['privacyUrl'] as String? ?? 'https://karathive.ae/privacy',
);

Map<String, dynamic> _$PlatformConfigToJson(_PlatformConfig instance) =>
    <String, dynamic>{
      'requestLifetimeHours': instance.requestLifetimeHours,
      'offerValidityHours': instance.offerValidityHours,
      'defaultOfferValidityHours': instance.defaultOfferValidityHours,
      'bullionMinimumAed': instance.bullionMinimumAed,
      'maxConcurrentLiveRequests': instance.maxConcurrentLiveRequests,
      'maxOfferRevisions': instance.maxOfferRevisions,
      'requestExpiryWarningHours': instance.requestExpiryWarningHours,
      'karatList': instance.karatList,
      'supportContactUrl': instance.supportContactUrl,
      'subscriptionContactUrl': instance.subscriptionContactUrl,
      'termsUrl': instance.termsUrl,
      'privacyUrl': instance.privacyUrl,
    };

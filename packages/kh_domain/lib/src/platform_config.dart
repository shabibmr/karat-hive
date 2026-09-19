import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_config.freezed.dart';
part 'platform_config.g.dart';

List<int> _parseOfferValidity(Object? raw) {
  if (raw is List && raw.isNotEmpty) {
    return raw.map((e) => int.tryParse(e.toString()) ?? 0).toList(growable: false);
  }
  return const [12, 24, 48];
}

List<String> _parseKaratList(Object? raw) {
  if (raw is List && raw.isNotEmpty) {
    return raw.map((e) => e.toString()).toList(growable: false);
  }
  return const ['18', '21', '22', '24'];
}

List<String> _parseAcceptedImageTypes(Object? raw) {
  if (raw is List && raw.isNotEmpty) {
    return raw.map((e) => e.toString()).toList(growable: false);
  }
  return const ['image/jpeg', 'image/png', 'image/webp'];
}

Map<String, dynamic> _normalizePlatformConfigJson(Map<String, dynamic> json) {
  final legal = (json['legal'] as Map<String, dynamic>?) ?? const {};
  final support = (json['support'] as Map<String, dynamic>?) ?? const {};

  return {
    'requestLifetimeHours': (json['requestLifetimeHours'] as num?)?.toInt() ?? 48,
    'offerValidityHours': _parseOfferValidity(json['offerValidityHours']),
    'defaultOfferValidityHours':
        (json['defaultOfferValidityHours'] as num?)?.toInt() ?? 24,
    'bullionMinimumAed': json['bullionMinimumAed']?.toString() ?? '5000',
    'maxConcurrentLiveRequests':
        (json['maxConcurrentLiveRequests'] as num?)?.toInt() ?? 3,
    'maxRequestImages': (json['maxRequestImages'] as num?)?.toInt() ?? 5,
    'maxOfferImages': (json['maxOfferImages'] as num?)?.toInt() ?? 3,
    'maxImageBytes': (json['maxImageBytes'] as num?)?.toInt() ?? 0,
    'acceptedImageTypes': _parseAcceptedImageTypes(json['acceptedImageTypes']),
    'karatList': _parseKaratList(json['karatList'] ?? json['karats']),
    'maxOfferRevisions': (json['maxOfferRevisions'] as num?)?.toInt() ?? 3,
    'requestExpiryWarningHours':
        (json['requestExpiryWarningHours'] as num?)?.toInt() ?? 6,
    'termsUrl': (json['termsUrl'] ?? legal['termsUrl']) as String?,
    'privacyUrl': (json['privacyUrl'] ?? legal['privacyUrl']) as String?,
    'supportContactUrl':
        (json['supportContactUrl'] ?? support['contactUrl']) as String?,
    'subscriptionContactUrl': json['subscriptionContactUrl'] as String?,
  };
}

@freezed
abstract class PlatformConfig with _$PlatformConfig {
  const factory PlatformConfig({
    @Default(48) int requestLifetimeHours,
    @Default([12, 24, 48]) List<int> offerValidityHours,
    @Default(24) int defaultOfferValidityHours,
    @Default('5000') String bullionMinimumAed,
    @Default(3) int maxConcurrentLiveRequests,
    @Default(5) int maxRequestImages,
    @Default(3) int maxOfferImages,
    @Default(0) int maxImageBytes,
    @Default(['image/jpeg', 'image/png', 'image/webp'])
    List<String> acceptedImageTypes,
    @Default(['18', '21', '22', '24']) List<String> karatList,
    @Default(3) int maxOfferRevisions,
    @Default(6) int requestExpiryWarningHours,
    String? termsUrl,
    String? privacyUrl,
    String? supportContactUrl,
    String? subscriptionContactUrl,
  }) = _PlatformConfig;

  factory PlatformConfig.fromJson(Map<String, dynamic> json) =>
      _$PlatformConfigFromJson(_normalizePlatformConfigJson(json));
}

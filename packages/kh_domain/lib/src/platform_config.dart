import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_config.freezed.dart';
part 'platform_config.g.dart';

Map<String, dynamic> _normalizePlatformConfigJson(Map<String, dynamic> json) {
  final legal = (json['legal'] as Map<String, dynamic>?) ?? const {};
  final support = (json['support'] as Map<String, dynamic>?) ?? const {};
  return {
    ...json,
    'offerValidityHours': ((json['offerValidityHours'] as List?) ?? [12, 24, 48])
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .toList(growable: false),
    'bullionMinimumAed': json['bullionMinimumAed']?.toString() ?? '5000',
    'karatList': ((json['karatList'] ?? json['karats']) as List?)
            ?.map((e) => e.toString())
            .toList(growable: false) ??
        const ['18', '21', '22', '24'],
    'supportContactUrl': json['supportContactUrl'] as String? ??
        support['contactUrl'] as String? ??
        'https://karathive.ae/support',
    'subscriptionContactUrl': json['subscriptionContactUrl'] as String? ??
        'https://karathive.ae/subscriptions',
    'termsUrl': json['termsUrl'] as String? ??
        legal['termsUrl'] as String? ??
        'https://karathive.ae/terms',
    'privacyUrl': json['privacyUrl'] as String? ??
        legal['privacyUrl'] as String? ??
        'https://karathive.ae/privacy',
  };
}

/// Public platform configuration (CP2-F06 freezed pattern).
///
/// [fromJson] flattens nested `legal` / `support` maps and accepts `karats` as
/// an alias for `karatList`, matching the prior hand-written parser.
@freezed
abstract class PlatformConfig with _$PlatformConfig {
  const factory PlatformConfig({
    @Default(48) int requestLifetimeHours,
    @Default([12, 24, 48]) List<int> offerValidityHours,
    @Default(24) int defaultOfferValidityHours,
    @Default('5000') String bullionMinimumAed,
    @Default(3) int maxConcurrentLiveRequests,
    @Default(3) int maxOfferRevisions,
    @Default(6) int requestExpiryWarningHours,
    @Default(['18', '21', '22', '24']) List<String> karatList,
    @Default('https://karathive.ae/support') String supportContactUrl,
    @Default('https://karathive.ae/subscriptions') String subscriptionContactUrl,
    @Default('https://karathive.ae/terms') String termsUrl,
    @Default('https://karathive.ae/privacy') String privacyUrl,
  }) = _PlatformConfig;

  factory PlatformConfig.fromJson(Map<String, dynamic> json) =>
      _$PlatformConfigFromJson(_normalizePlatformConfigJson(json));
}

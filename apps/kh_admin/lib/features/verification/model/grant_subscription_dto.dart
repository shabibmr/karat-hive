import 'package:kh_admin/features/requests/model/request_enums.dart';

/// Body for `POST /v1/admin/vendors/{id}/subscriptions`.
///
/// The endpoint records a paid entitlement, so `VendorTypeSubscription` wants a
/// billing period and a price alongside the Request type. There is no
/// subscription product catalogue yet — `FR-VEN-031` AC1/AC5 put prices and
/// billing periods under `FR-ADM-030`, but the only subscription key in
/// `PlatformSetting` today is `subscription.contact_url`. Until that catalogue
/// exists the approve dialog records *which* types the Vendor bought and leaves
/// the commercial terms on the placeholders below;
/// `PATCH /v1/admin/vendors/{id}/subscriptions/{requestType}` can correct the
/// period afterwards.
class GrantSubscriptionDto {
  const GrantSubscriptionDto({
    required this.requestType,
    required this.periodStart,
    required this.periodEnd,
    required this.priceAed,
    this.paymentReference,
  });

  /// Placeholder billing period used when the admin only ticks the type.
  static const int defaultPeriodDays = 30;

  /// Placeholder price — amounts are collected off-platform today, so nothing
  /// in the portal knows what this Vendor actually paid.
  static const String defaultPriceAed = '0.00';

  /// A grant carrying only the Request type, on the placeholder terms above.
  factory GrantSubscriptionDto.forType(RequestType requestType, {DateTime? now}) {
    final start = (now ?? DateTime.now()).toUtc();
    return GrantSubscriptionDto(
      requestType: requestType,
      periodStart: start,
      periodEnd: start.add(const Duration(days: defaultPeriodDays)),
      priceAed: defaultPriceAed,
    );
  }

  final RequestType requestType;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String priceAed;
  final String? paymentReference;

  Map<String, dynamic> toJson() => {
        'requestType': requestType.apiValue,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
        'priceAed': priceAed,
        if (paymentReference != null) 'paymentReference': paymentReference,
      };
}

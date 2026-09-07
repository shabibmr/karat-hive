import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_subscription_item.freezed.dart';
part 'vendor_subscription_item.g.dart';

Map<String, dynamic> _normalizeVendorSubscriptionItemJson(
  Map<String, dynamic> json,
) {
  DateTime? parseDate(dynamic v) =>
      v != null ? DateTime.tryParse(v.toString()) : null;

  return {
    ...json,
    'priceAed': json['priceAed']?.toString() ?? '0.00',
    'periodStart': parseDate(json['periodStart'])?.toIso8601String(),
    'periodEnd': parseDate(json['periodEnd'])?.toIso8601String(),
    'graceEndsAt': parseDate(json['graceEndsAt'])?.toIso8601String(),
    'renewalDate': parseDate(json['renewalDate'])?.toIso8601String(),
    'canOffer': json['canOffer'] as bool? ?? false,
  };
}

/// Vendor type-subscription row (CP2-F06 freezed pattern).
@freezed
abstract class VendorSubscriptionItem with _$VendorSubscriptionItem {
  const factory VendorSubscriptionItem({
    required String requestType,
    required String state,
    @Default('0.00') String priceAed,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? graceEndsAt,
    DateTime? renewalDate,
    @Default(false) bool canOffer,
  }) = _VendorSubscriptionItem;

  factory VendorSubscriptionItem.fromJson(Map<String, dynamic> json) =>
      _$VendorSubscriptionItemFromJson(
        _normalizeVendorSubscriptionItemJson(json),
      );
}

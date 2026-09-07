// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_subscription_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VendorSubscriptionItem _$VendorSubscriptionItemFromJson(
  Map<String, dynamic> json,
) => _VendorSubscriptionItem(
  requestType: json['requestType'] as String,
  state: json['state'] as String,
  priceAed: json['priceAed'] as String? ?? '0.00',
  periodStart: json['periodStart'] == null
      ? null
      : DateTime.parse(json['periodStart'] as String),
  periodEnd: json['periodEnd'] == null
      ? null
      : DateTime.parse(json['periodEnd'] as String),
  graceEndsAt: json['graceEndsAt'] == null
      ? null
      : DateTime.parse(json['graceEndsAt'] as String),
  renewalDate: json['renewalDate'] == null
      ? null
      : DateTime.parse(json['renewalDate'] as String),
  canOffer: json['canOffer'] as bool? ?? false,
);

Map<String, dynamic> _$VendorSubscriptionItemToJson(
  _VendorSubscriptionItem instance,
) => <String, dynamic>{
  'requestType': instance.requestType,
  'state': instance.state,
  'priceAed': instance.priceAed,
  'periodStart': instance.periodStart?.toIso8601String(),
  'periodEnd': instance.periodEnd?.toIso8601String(),
  'graceEndsAt': instance.graceEndsAt?.toIso8601String(),
  'renewalDate': instance.renewalDate?.toIso8601String(),
  'canOffer': instance.canOffer,
};

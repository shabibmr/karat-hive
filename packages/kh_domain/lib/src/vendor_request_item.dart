import 'package:freezed_annotation/freezed_annotation.dart';

import 'party.dart';
import 'request_media_ref.dart';

part 'vendor_request_item.freezed.dart';
part 'vendor_request_item.g.dart';

Map<String, dynamic> _normalizeVendorRequestItemJson(Map<String, dynamic> json) {
  DateTime? parseDate(dynamic v) =>
      v != null ? DateTime.tryParse(v.toString()) : null;
  double? parseDouble(dynamic v) =>
      v != null ? double.tryParse(v.toString()) : null;

  final customerJson = (json['customer'] as Map<String, dynamic>?) ??
      const <String, dynamic>{};
  final mediaList = (json['media'] as List?) ?? const [];

  return {
    ...json,
    'requestType': json['requestType'] as String? ?? 'FIND_ORNAMENT',
    'direction': json['direction'] as String? ?? 'BUY',
    'state': json['state'] as String? ?? 'PUBLISHED',
    'categoryId': json['categoryId'] as String? ?? '',
    'categoryName':
        (json['category'] as Map<String, dynamic>?)?['nameEn'] as String? ??
            json['categoryName'] as String?,
    'regionId': json['regionId'] as String? ?? '',
    'regionName':
        (json['region'] as Map<String, dynamic>?)?['nameEn'] as String? ??
            json['regionName'] as String?,
    'weightGrams': parseDouble(json['weightGrams']),
    'weightIsApproximate': json['weightIsApproximate'] as bool? ?? false,
    'purityKarat': json['purityKarat']?.toString(),
    'budgetMin': parseDouble(json['budgetMin']),
    'budgetMax': parseDouble(json['budgetMax']),
    'budgetIsFlexible': json['budgetIsFlexible'] as bool? ?? false,
    'publishedAt': parseDate(json['publishedAt'])?.toIso8601String(),
    'expiresAt': parseDate(json['expiresAt'])?.toIso8601String(),
    'offerCount': json['offerCount'] as int? ?? 0,
    'viewedAt': parseDate(json['viewedAt'])?.toIso8601String(),
    'hasResponded': json['hasResponded'] as bool? ?? false,
    'customer': customerJson,
    'media': mediaList
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList(growable: false),
  };
}

/// Vendor-facing request row in the feed or detail screen (CP2-F06).
///
/// Customer identity is strictly [MaskedParty] per BR-006 / AD-FE-07.
@freezed
abstract class VendorRequestItem with _$VendorRequestItem {
  const VendorRequestItem._();

  const factory VendorRequestItem({
    required String id,
    String? reference,
    required String requestType,
    required String direction,
    required String state,
    required String categoryId,
    String? categoryName,
    required String regionId,
    String? regionName,
    double? weightGrams,
    @Default(false) bool weightIsApproximate,
    String? purityKarat,
    double? budgetMin,
    double? budgetMax,
    @Default(false) bool budgetIsFlexible,
    String? notes,
    DateTime? publishedAt,
    DateTime? expiresAt,
    @Default(0) int offerCount,
    DateTime? viewedAt,
    @Default(false) bool hasResponded,
    required MaskedParty customer,
    @Default(<RequestMediaRef>[]) List<RequestMediaRef> media,
  }) = _VendorRequestItem;

  bool get isViewed => viewedAt != null;

  factory VendorRequestItem.fromJson(Map<String, dynamic> json) =>
      _$VendorRequestItemFromJson(_normalizeVendorRequestItemJson(json));
}

// `GET /v1/me/vendor/performance` and `/export` wire maps (`FR-VEN-023`,
// inventory §20). No offered-vs-accepted price comparison is exposed here:
// with a single lost Offer in period, any such "average" degenerates to the
// exact winning competitor's price, so the stat is not computed or returned
// (`BR-008`).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_dtos.freezed.dart';
part 'performance_dtos.g.dart';

Map<String, dynamic> _normalizeRatingTrendPointJson(Map<String, dynamic> json) => {
      'period': json['period'] as String? ?? '',
      'average': (json['average'] as num?)?.toDouble() ?? 0,
      'count': (json['count'] as num?)?.toInt() ?? 0,
    };

@freezed
abstract class RatingTrendPointDto with _$RatingTrendPointDto {
  const factory RatingTrendPointDto({
    /// `YYYY-MM` calendar month (`SAM-GAP-8`).
    required String period,
    required double average,
    required int count,
  }) = _RatingTrendPointDto;

  factory RatingTrendPointDto.fromJson(Map<String, dynamic> json) =>
      _$RatingTrendPointDtoFromJson(_normalizeRatingTrendPointJson(json));
}

Map<String, dynamic> _normalizePerformanceOutcomeJson(Map<String, dynamic> json) => {
      'state': json['state'] as String? ?? '',
      'count': (json['count'] as num?)?.toInt() ?? 0,
    };

@freezed
abstract class PerformanceOutcomeDto with _$PerformanceOutcomeDto {
  const factory PerformanceOutcomeDto({
    required String state,
    required int count,
  }) = _PerformanceOutcomeDto;

  factory PerformanceOutcomeDto.fromJson(Map<String, dynamic> json) =>
      _$PerformanceOutcomeDtoFromJson(_normalizePerformanceOutcomeJson(json));
}

/// Controllers that return `{ data }` get re-wrapped by the envelope; tolerate
/// both the unwrapped body and a nested `data` object (see SubscriptionsClient).
Map<String, dynamic> _unwrapVendorPerformancePayload(Map<String, dynamic> json) {
  if (json.containsKey('offersSubmitted')) return json;
  final nested = json['data'];
  if (nested is Map) return Map<String, dynamic>.from(nested);
  return json;
}

Map<String, dynamic> _normalizeVendorPerformanceJson(Map<String, dynamic> json) {
  final j = _unwrapVendorPerformancePayload(json);
  return {
    'offersSubmitted': (j['offersSubmitted'] as num?)?.toInt() ?? 0,
    'acceptanceRate': (j['acceptanceRate'] ?? '0.00').toString(),
    'averageResponseMinutes': (j['averageResponseMinutes'] as num?)?.toInt() ?? 0,
    'byOutcome': ((j['byOutcome'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false),
    'ratingTrend': ((j['ratingTrend'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false),
  };
}

/// Vendor performance aggregates for `VEN-S14`.
@freezed
abstract class VendorPerformanceDto with _$VendorPerformanceDto {
  const factory VendorPerformanceDto({
    required int offersSubmitted,

    /// Decimal string from the API (e.g. `"0.25"`).
    required String acceptanceRate,
    required int averageResponseMinutes,
    @Default(<PerformanceOutcomeDto>[]) List<PerformanceOutcomeDto> byOutcome,

    /// Six `{ period, average, count }` points (`CP5-A05.2`).
    @Default(<RatingTrendPointDto>[]) List<RatingTrendPointDto> ratingTrend,
  }) = _VendorPerformanceDto;

  factory VendorPerformanceDto.fromJson(Map<String, dynamic> json) =>
      _$VendorPerformanceDtoFromJson(_normalizeVendorPerformanceJson(json));
}

Map<String, dynamic> _normalizePerformanceExportJson(Map<String, dynamic> json) => {
      'downloadUrl': json['downloadUrl'] as String? ?? '',
      'expiresAt': (DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true))
          .toIso8601String(),
    };

/// Signed CSV download for `GET /v1/me/vendor/performance/export`.
@freezed
abstract class PerformanceExportDto with _$PerformanceExportDto {
  const factory PerformanceExportDto({
    required String downloadUrl,
    required DateTime expiresAt,
  }) = _PerformanceExportDto;

  factory PerformanceExportDto.fromJson(Map<String, dynamic> json) =>
      _$PerformanceExportDtoFromJson(_normalizePerformanceExportJson(json));
}

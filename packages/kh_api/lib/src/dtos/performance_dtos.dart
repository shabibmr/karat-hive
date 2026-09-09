// `GET /v1/me/vendor/performance` and `/export` wire maps (`FR-VEN-023`,
// inventory §20). No offered-vs-accepted price comparison is exposed here:
// with a single lost Offer in period, any such "average" degenerates to the
// exact winning competitor's price, so the stat is not computed or returned
// (`BR-008`).

class RatingTrendPointDto {
  const RatingTrendPointDto({
    required this.period,
    required this.average,
    required this.count,
  });

  /// `YYYY-MM` calendar month (`SAM-GAP-8`).
  final String period;
  final double average;
  final int count;

  static RatingTrendPointDto fromJson(Map<String, dynamic> j) =>
      RatingTrendPointDto(
        period: j['period'] as String? ?? '',
        average: (j['average'] as num?)?.toDouble() ?? 0,
        count: (j['count'] as num?)?.toInt() ?? 0,
      );
}

class PerformanceOutcomeDto {
  const PerformanceOutcomeDto({
    required this.state,
    required this.count,
  });

  final String state;
  final int count;

  static PerformanceOutcomeDto fromJson(Map<String, dynamic> j) =>
      PerformanceOutcomeDto(
        state: j['state'] as String? ?? '',
        count: (j['count'] as num?)?.toInt() ?? 0,
      );
}

/// Vendor performance aggregates for `VEN-S14`.
class VendorPerformanceDto {
  const VendorPerformanceDto({
    required this.offersSubmitted,
    required this.acceptanceRate,
    required this.averageResponseMinutes,
    this.byOutcome = const [],
    this.ratingTrend = const [],
  });

  final int offersSubmitted;

  /// Decimal string from the API (e.g. `"0.25"`).
  final String acceptanceRate;
  final int averageResponseMinutes;
  final List<PerformanceOutcomeDto> byOutcome;

  /// Six `{ period, average, count }` points (`CP5-A05.2`).
  final List<RatingTrendPointDto> ratingTrend;

  static Map<String, dynamic> _payload(Map<String, dynamic> j) {
    // Controllers that return `{ data }` get re-wrapped by the envelope; tolerate
    // both the unwrapped body and a nested `data` object (see SubscriptionsClient).
    if (j.containsKey('offersSubmitted')) return j;
    final nested = j['data'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return j;
  }

  static VendorPerformanceDto fromJson(Map<String, dynamic> json) {
    final j = _payload(json);
    return VendorPerformanceDto(
      offersSubmitted: (j['offersSubmitted'] as num?)?.toInt() ?? 0,
      acceptanceRate: (j['acceptanceRate'] ?? '0.00').toString(),
      averageResponseMinutes:
          (j['averageResponseMinutes'] as num?)?.toInt() ?? 0,
      byOutcome: ((j['byOutcome'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => PerformanceOutcomeDto.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(growable: false),
      ratingTrend: ((j['ratingTrend'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => RatingTrendPointDto.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(growable: false),
    );
  }
}

/// Signed CSV download for `GET /v1/me/vendor/performance/export`.
class PerformanceExportDto {
  const PerformanceExportDto({
    required this.downloadUrl,
    required this.expiresAt,
  });

  final String downloadUrl;
  final DateTime expiresAt;

  static PerformanceExportDto fromJson(Map<String, dynamic> j) =>
      PerformanceExportDto(
        downloadUrl: j['downloadUrl'] as String? ?? '',
        expiresAt: DateTime.tryParse(j['expiresAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
}

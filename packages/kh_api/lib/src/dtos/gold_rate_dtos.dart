/// `gold-rate.presenter.ts` `GoldRateSnapshot` — `GET /v1/gold-rates`.
///
/// The client must branch on [available] / [stale] flags, never infer staleness
/// from timestamps (`CBG-02`, Screen-API-Map rows 59–62). When the display is
/// not licensed the payload is `{ available:false, reason:'DISPLAY_NOT_LICENSED' }`
/// and [rates] is empty.
class GoldRateSnapshotDto {
  const GoldRateSnapshotDto({
    required this.available,
    required this.stale,
    this.reason,
    this.source,
    this.sourceTimestamp,
    this.ingestedAt,
    this.staleAfter,
    this.rates = const [],
    this.disclaimer,
  });

  final bool available;
  final bool stale;
  final String? reason;
  final String? source;
  final DateTime? sourceTimestamp;
  final DateTime? ingestedAt;
  final DateTime? staleAfter;
  final List<GoldRateRowDto> rates;
  final String? disclaimer;

  static DateTime? _d(dynamic v) =>
      v == null ? null : DateTime.tryParse(v as String);

  static GoldRateSnapshotDto fromJson(Map<String, dynamic> j) =>
      GoldRateSnapshotDto(
        available: j['available'] as bool? ?? false,
        stale: j['stale'] as bool? ?? false,
        reason: j['reason'] as String?,
        source: j['source'] as String?,
        sourceTimestamp: _d(j['sourceTimestamp']),
        ingestedAt: _d(j['ingestedAt']),
        staleAfter: _d(j['staleAfter']),
        rates: ((j['rates'] as List?) ?? const [])
            .map((e) => GoldRateRowDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        disclaimer: j['disclaimer'] as String?,
      );
}

class GoldRateRowDto {
  const GoldRateRowDto({required this.karat, required this.ratePerGramAed});

  final String karat;
  final String ratePerGramAed;

  static GoldRateRowDto fromJson(Map<String, dynamic> j) => GoldRateRowDto(
        karat: j['karat'] as String? ?? '',
        ratePerGramAed: (j['ratePerGramAed'] ?? '0').toString(),
      );
}

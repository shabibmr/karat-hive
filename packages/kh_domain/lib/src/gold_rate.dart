import 'request.dart';

enum GoldRateSource {
  feed,
  manualOverride,
  unknown;

  static GoldRateSource parse(String? raw) => switch (raw) {
        'FEED' => feed,
        'MANUAL_OVERRIDE' => manualOverride,
        _ => unknown,
      };
}

class GoldRateRow {
  const GoldRateRow({required this.karat, required this.ratePerGramAed});

  final Karat karat;
  final String ratePerGramAed;
}

class GoldRateSnapshot {
  const GoldRateSnapshot({
    required this.available,
    required this.stale,
    this.source = GoldRateSource.unknown,
    this.sourceTimestamp,
    this.ingestedAt,
    this.staleAfter,
    this.rates = const [],
    this.disclaimer,
    this.reason,
  });

  final bool available;
  final bool stale;
  final GoldRateSource source;
  final DateTime? sourceTimestamp;
  final DateTime? ingestedAt;
  final DateTime? staleAfter;
  final List<GoldRateRow> rates;
  final String? disclaimer;
  final String? reason;

  static GoldRateSnapshot fromJson(Map<String, dynamic> j) {
    final ratesRaw = j['rates'] as List? ?? const [];
    return GoldRateSnapshot(
      available: j['available'] as bool? ?? false,
      stale: j['stale'] as bool? ?? false,
      source: GoldRateSource.parse(j['source'] as String?),
      sourceTimestamp: j['sourceTimestamp'] is String
          ? DateTime.tryParse(j['sourceTimestamp'] as String)
          : null,
      ingestedAt: j['ingestedAt'] is String
          ? DateTime.tryParse(j['ingestedAt'] as String)
          : null,
      staleAfter: j['staleAfter'] is String
          ? DateTime.tryParse(j['staleAfter'] as String)
          : null,
      rates: ratesRaw
          .map((e) {
            final m = e is Map<String, dynamic>
                ? e
                : Map<String, dynamic>.from(e as Map);
            return GoldRateRow(
              karat: Karat.parse(m['karat'] as String?),
              ratePerGramAed: m['ratePerGramAed']?.toString() ?? '',
            );
          })
          .toList(growable: false),
      disclaimer: j['disclaimer'] as String?,
      reason: j['reason'] as String?,
    );
  }
}

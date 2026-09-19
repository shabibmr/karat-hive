import 'package:freezed_annotation/freezed_annotation.dart';

import 'request.dart';

part 'gold_rate.freezed.dart';
part 'gold_rate.g.dart';

enum GoldRateSource {
  feed,
  manualOverride,
  unknown;

  static GoldRateSource parse(String? raw) => switch (raw) {
        'FEED' => feed,
        'MANUAL_OVERRIDE' => manualOverride,
        _ => unknown,
      };

  String get wire => switch (this) {
        feed => 'FEED',
        manualOverride => 'MANUAL_OVERRIDE',
        unknown => 'UNKNOWN',
      };
}

class _GoldRateSourceConverter
    implements JsonConverter<GoldRateSource, String?> {
  const _GoldRateSourceConverter();

  @override
  GoldRateSource fromJson(String? json) => GoldRateSource.parse(json);

  @override
  String toJson(GoldRateSource object) => object.wire;
}

class _KaratConverter implements JsonConverter<Karat, String?> {
  const _KaratConverter();

  @override
  Karat fromJson(String? json) => Karat.parse(json);

  @override
  String toJson(Karat object) => object.wire;
}

Map<String, dynamic> _normalizeGoldRateRowJson(Map<String, dynamic> json) => {
      'karat': json['karat']?.toString(),
      'ratePerGramAed': json['ratePerGramAed']?.toString() ?? '',
    };

@freezed
abstract class GoldRateRow with _$GoldRateRow {
  const factory GoldRateRow({
    @_KaratConverter() required Karat karat,
    required String ratePerGramAed,
  }) = _GoldRateRow;

  factory GoldRateRow.fromJson(Map<String, dynamic> json) =>
      _$GoldRateRowFromJson(_normalizeGoldRateRowJson(json));
}

DateTime? _dt(Object? raw) {
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  return null;
}

Map<String, dynamic> _normalizeGoldRateSnapshotJson(
    Map<String, dynamic> json) {
  final ratesRaw = json['rates'] as List? ?? const [];
  return {
    ...json,
    'available': json['available'] as bool? ?? false,
    'stale': json['stale'] as bool? ?? false,
    'source': json['source']?.toString(),
    'sourceTimestamp': _dt(json['sourceTimestamp'])?.toIso8601String(),
    'ingestedAt': _dt(json['ingestedAt'])?.toIso8601String(),
    'staleAfter': _dt(json['staleAfter'])?.toIso8601String(),
    'rates': ratesRaw
        .map((e) => e is Map<String, dynamic>
            ? e
            : Map<String, dynamic>.from(e as Map))
        .toList(growable: false),
  };
}

@freezed
abstract class GoldRateSnapshot with _$GoldRateSnapshot {
  const factory GoldRateSnapshot({
    required bool available,
    required bool stale,
    @_GoldRateSourceConverter() @Default(GoldRateSource.unknown) GoldRateSource source,
    DateTime? sourceTimestamp,
    DateTime? ingestedAt,
    DateTime? staleAfter,
    @Default(<GoldRateRow>[]) List<GoldRateRow> rates,
    String? disclaimer,
    String? reason,
  }) = _GoldRateSnapshot;

  factory GoldRateSnapshot.fromJson(Map<String, dynamic> json) =>
      _$GoldRateSnapshotFromJson(_normalizeGoldRateSnapshotJson(json));
}

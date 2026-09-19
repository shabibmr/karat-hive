import 'package:freezed_annotation/freezed_annotation.dart';

part 'gold_rate_dtos.freezed.dart';
part 'gold_rate_dtos.g.dart';

String? _tryIso(dynamic v) =>
    v == null ? null : DateTime.tryParse(v as String)?.toIso8601String();

Map<String, dynamic> _normalizeGoldRateSnapshotJson(Map<String, dynamic> json) => {
      ...json,
      'available': json['available'] as bool? ?? false,
      'stale': json['stale'] as bool? ?? false,
      'sourceTimestamp': _tryIso(json['sourceTimestamp']),
      'ingestedAt': _tryIso(json['ingestedAt']),
      'staleAfter': _tryIso(json['staleAfter']),
      'rates': (json['rates'] as List?) ?? const [],
    };

/// `gold-rate.presenter.ts` `GoldRateSnapshot` — `GET /v1/gold-rates`.
///
/// The client must branch on [available] / [stale] flags, never infer staleness
/// from timestamps (`CBG-02`, Screen-API-Map rows 59–62). When the display is
/// not licensed the payload is `{ available:false, reason:'DISPLAY_NOT_LICENSED' }`
/// and [rates] is empty.
@freezed
abstract class GoldRateSnapshotDto with _$GoldRateSnapshotDto {
  const factory GoldRateSnapshotDto({
    required bool available,
    required bool stale,
    String? reason,
    String? source,
    DateTime? sourceTimestamp,
    DateTime? ingestedAt,
    DateTime? staleAfter,
    @Default(<GoldRateRowDto>[]) List<GoldRateRowDto> rates,
    String? disclaimer,
  }) = _GoldRateSnapshotDto;

  factory GoldRateSnapshotDto.fromJson(Map<String, dynamic> json) =>
      _$GoldRateSnapshotDtoFromJson(_normalizeGoldRateSnapshotJson(json));
}

Map<String, dynamic> _normalizeGoldRateRowJson(Map<String, dynamic> json) => {
      'karat': json['karat'] as String? ?? '',
      'ratePerGramAed': (json['ratePerGramAed'] ?? '0').toString(),
    };

@freezed
abstract class GoldRateRowDto with _$GoldRateRowDto {
  const factory GoldRateRowDto({
    required String karat,
    required String ratePerGramAed,
  }) = _GoldRateRowDto;

  factory GoldRateRowDto.fromJson(Map<String, dynamic> json) =>
      _$GoldRateRowDtoFromJson(_normalizeGoldRateRowJson(json));
}

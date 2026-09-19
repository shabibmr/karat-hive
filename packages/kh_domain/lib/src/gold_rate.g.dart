// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gold_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoldRateRow _$GoldRateRowFromJson(Map<String, dynamic> json) => _GoldRateRow(
  karat: const _KaratConverter().fromJson(json['karat'] as String?),
  ratePerGramAed: json['ratePerGramAed'] as String,
);

Map<String, dynamic> _$GoldRateRowToJson(_GoldRateRow instance) =>
    <String, dynamic>{
      'karat': const _KaratConverter().toJson(instance.karat),
      'ratePerGramAed': instance.ratePerGramAed,
    };

_GoldRateSnapshot _$GoldRateSnapshotFromJson(Map<String, dynamic> json) =>
    _GoldRateSnapshot(
      available: json['available'] as bool,
      stale: json['stale'] as bool,
      source: json['source'] == null
          ? GoldRateSource.unknown
          : const _GoldRateSourceConverter().fromJson(
              json['source'] as String?,
            ),
      sourceTimestamp: json['sourceTimestamp'] == null
          ? null
          : DateTime.parse(json['sourceTimestamp'] as String),
      ingestedAt: json['ingestedAt'] == null
          ? null
          : DateTime.parse(json['ingestedAt'] as String),
      staleAfter: json['staleAfter'] == null
          ? null
          : DateTime.parse(json['staleAfter'] as String),
      rates:
          (json['rates'] as List<dynamic>?)
              ?.map((e) => GoldRateRow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GoldRateRow>[],
      disclaimer: json['disclaimer'] as String?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$GoldRateSnapshotToJson(_GoldRateSnapshot instance) =>
    <String, dynamic>{
      'available': instance.available,
      'stale': instance.stale,
      'source': const _GoldRateSourceConverter().toJson(instance.source),
      'sourceTimestamp': instance.sourceTimestamp?.toIso8601String(),
      'ingestedAt': instance.ingestedAt?.toIso8601String(),
      'staleAfter': instance.staleAfter?.toIso8601String(),
      'rates': instance.rates.map((e) => e.toJson()).toList(),
      'disclaimer': instance.disclaimer,
      'reason': instance.reason,
    };

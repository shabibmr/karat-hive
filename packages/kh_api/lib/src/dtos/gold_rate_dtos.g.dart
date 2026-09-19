// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gold_rate_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoldRateSnapshotDto _$GoldRateSnapshotDtoFromJson(Map<String, dynamic> json) =>
    _GoldRateSnapshotDto(
      available: json['available'] as bool,
      stale: json['stale'] as bool,
      reason: json['reason'] as String?,
      source: json['source'] as String?,
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
              ?.map((e) => GoldRateRowDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GoldRateRowDto>[],
      disclaimer: json['disclaimer'] as String?,
    );

Map<String, dynamic> _$GoldRateSnapshotDtoToJson(
  _GoldRateSnapshotDto instance,
) => <String, dynamic>{
  'available': instance.available,
  'stale': instance.stale,
  'reason': instance.reason,
  'source': instance.source,
  'sourceTimestamp': instance.sourceTimestamp?.toIso8601String(),
  'ingestedAt': instance.ingestedAt?.toIso8601String(),
  'staleAfter': instance.staleAfter?.toIso8601String(),
  'rates': instance.rates,
  'disclaimer': instance.disclaimer,
};

_GoldRateRowDto _$GoldRateRowDtoFromJson(Map<String, dynamic> json) =>
    _GoldRateRowDto(
      karat: json['karat'] as String,
      ratePerGramAed: json['ratePerGramAed'] as String,
    );

Map<String, dynamic> _$GoldRateRowDtoToJson(_GoldRateRowDto instance) =>
    <String, dynamic>{
      'karat': instance.karat,
      'ratePerGramAed': instance.ratePerGramAed,
    };

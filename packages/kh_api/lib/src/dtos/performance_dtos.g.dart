// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RatingTrendPointDto _$RatingTrendPointDtoFromJson(Map<String, dynamic> json) =>
    _RatingTrendPointDto(
      period: json['period'] as String,
      average: (json['average'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$RatingTrendPointDtoToJson(
  _RatingTrendPointDto instance,
) => <String, dynamic>{
  'period': instance.period,
  'average': instance.average,
  'count': instance.count,
};

_PerformanceOutcomeDto _$PerformanceOutcomeDtoFromJson(
  Map<String, dynamic> json,
) => _PerformanceOutcomeDto(
  state: json['state'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$PerformanceOutcomeDtoToJson(
  _PerformanceOutcomeDto instance,
) => <String, dynamic>{'state': instance.state, 'count': instance.count};

_VendorPerformanceDto _$VendorPerformanceDtoFromJson(
  Map<String, dynamic> json,
) => _VendorPerformanceDto(
  offersSubmitted: (json['offersSubmitted'] as num).toInt(),
  acceptanceRate: json['acceptanceRate'] as String,
  averageResponseMinutes: (json['averageResponseMinutes'] as num).toInt(),
  byOutcome:
      (json['byOutcome'] as List<dynamic>?)
          ?.map(
            (e) => PerformanceOutcomeDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <PerformanceOutcomeDto>[],
  ratingTrend:
      (json['ratingTrend'] as List<dynamic>?)
          ?.map((e) => RatingTrendPointDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RatingTrendPointDto>[],
);

Map<String, dynamic> _$VendorPerformanceDtoToJson(
  _VendorPerformanceDto instance,
) => <String, dynamic>{
  'offersSubmitted': instance.offersSubmitted,
  'acceptanceRate': instance.acceptanceRate,
  'averageResponseMinutes': instance.averageResponseMinutes,
  'byOutcome': instance.byOutcome,
  'ratingTrend': instance.ratingTrend,
};

_PerformanceExportDto _$PerformanceExportDtoFromJson(
  Map<String, dynamic> json,
) => _PerformanceExportDto(
  downloadUrl: json['downloadUrl'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$PerformanceExportDtoToJson(
  _PerformanceExportDto instance,
) => <String, dynamic>{
  'downloadUrl': instance.downloadUrl,
  'expiresAt': instance.expiresAt.toIso8601String(),
};

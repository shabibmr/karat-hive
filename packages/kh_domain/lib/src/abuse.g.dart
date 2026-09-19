// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abuse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AbuseReport _$AbuseReportFromJson(Map<String, dynamic> json) => _AbuseReport(
  id: json['id'] as String,
  state: const _AbuseReportStateConverter().fromJson(json['state'] as String?),
  acknowledged: json['acknowledged'] as bool,
);

Map<String, dynamic> _$AbuseReportToJson(_AbuseReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'state': const _AbuseReportStateConverter().toJson(instance.state),
      'acknowledged': instance.acknowledged,
    };

import 'package:freezed_annotation/freezed_annotation.dart';

part 'abuse.freezed.dart';
part 'abuse.g.dart';

/// Inventory `AbuseEntityType` plus live `VENDOR` / `CUSTOMER` (`SAM-GAP-4` built).
enum AbuseEntityType {
  request,
  offer,
  connection,
  review,
  vendor,
  customer,
  unknown;

  static AbuseEntityType parse(String? raw) => switch (raw) {
        'REQUEST' => request,
        'OFFER' => offer,
        'CONNECTION' => connection,
        'REVIEW' => review,
        'VENDOR' => vendor,
        'CUSTOMER' => customer,
        _ => unknown,
      };

  String get wire => switch (this) {
        request => 'REQUEST',
        offer => 'OFFER',
        connection => 'CONNECTION',
        review => 'REVIEW',
        vendor => 'VENDOR',
        customer => 'CUSTOMER',
        unknown => 'UNKNOWN',
      };
}

enum AbuseReportState {
  open,
  unknown;

  static AbuseReportState parse(String? raw) => switch (raw) {
        'OPEN' => open,
        _ => unknown,
      };

  String get wire => switch (this) {
        open => 'OPEN',
        unknown => 'UNKNOWN',
      };
}

class _AbuseReportStateConverter
    implements JsonConverter<AbuseReportState, String?> {
  const _AbuseReportStateConverter();

  @override
  AbuseReportState fromJson(String? json) => AbuseReportState.parse(json);

  @override
  String toJson(AbuseReportState object) => object.wire;
}

Map<String, dynamic> _normalizeAbuseReportJson(Map<String, dynamic> json) => {
      'id': json['id'] as String,
      'state': json['state']?.toString(),
      'acknowledged': json['acknowledged'] as bool? ?? false,
    };

@freezed
abstract class AbuseReport with _$AbuseReport {
  const factory AbuseReport({
    required String id,
    @_AbuseReportStateConverter() required AbuseReportState state,
    required bool acknowledged,
  }) = _AbuseReport;

  factory AbuseReport.fromJson(Map<String, dynamic> json) =>
      _$AbuseReportFromJson(_normalizeAbuseReportJson(json));
}

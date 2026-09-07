import 'abuse_report_enums.dart';

class AbuseReportFilters {
  const AbuseReportFilters({
    this.state,
    this.entityType,
    this.query = '',
  });

  final AbuseReportState? state;
  final AbuseEntityType? entityType;
  final String query;

  AbuseReportFilters copyWith({
    AbuseReportState? state,
    bool clearState = false,
    AbuseEntityType? entityType,
    bool clearEntityType = false,
    String? query,
  }) {
    return AbuseReportFilters(
      state: clearState ? null : (state ?? this.state),
      entityType: clearEntityType ? null : (entityType ?? this.entityType),
      query: query ?? this.query,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (state != null) 'state': state!.wireValue,
    };
  }
}

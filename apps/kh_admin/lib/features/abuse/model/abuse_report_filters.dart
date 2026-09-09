import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';

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
      if (entityType != null) 'entityType': entityType!.wireValue,
      if (query.trim().isNotEmpty) 'q': query.trim(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AbuseReportFilters &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          entityType == other.entityType &&
          query == other.query;

  @override
  int get hashCode => Object.hash(state, entityType, query);

  @override
  String toString() =>
      'AbuseReportFilters(state: $state, entityType: $entityType, query: $query)';
}

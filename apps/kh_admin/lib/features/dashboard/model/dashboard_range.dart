import 'package:kh_admin/core/time/clock.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';

/// Date-range presets for the ADM-S02 dashboard (`TR-S6-03`).
///
/// The dashboard shows a platform-health glance, so it offers fixed windows
/// rather than the ADM-S17 reports screen's free-text date fields.
enum DashboardRange {
  last7Days(7),
  last30Days(30),
  last90Days(90);

  const DashboardRange(this.days);

  /// Number of days the window spans, counting back from today.
  final int days;

  /// English fallback label (ARB keys are resolved at the call site).
  String get fallbackLabel {
    switch (this) {
      case DashboardRange.last7Days:
        return 'Last 7 days';
      case DashboardRange.last30Days:
        return 'Last 30 days';
      case DashboardRange.last90Days:
        return 'Last 90 days';
    }
  }

  /// `to` = today (UTC, date-floored); `from` = `to` minus [days].
  ///
  /// Reuses [ReportFilters] so the dashboard and reports screens share one
  /// date-range encoding (`ReportFilters.toIsoDate` → `yyyy-MM-dd`).
  ReportFilters toFilters(Clock clock) {
    final now = clock.now().toUtc();
    final to = DateTime.utc(now.year, now.month, now.day);
    final from = to.subtract(Duration(days: days));
    return ReportFilters(from: from, to: to);
  }
}

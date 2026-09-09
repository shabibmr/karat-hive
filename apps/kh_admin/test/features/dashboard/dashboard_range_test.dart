import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/time/clock.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_range.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  // 2026-09-09 14:30 UTC — the `to` bound must floor to the date.
  final clock = _FixedClock(DateTime.utc(2026, 9, 9, 14, 30));

  test('days and fallbackLabel are stable per preset', () {
    expect(DashboardRange.last7Days.days, 7);
    expect(DashboardRange.last30Days.days, 30);
    expect(DashboardRange.last90Days.days, 90);
    expect(DashboardRange.last7Days.fallbackLabel, 'Last 7 days');
    expect(DashboardRange.last90Days.fallbackLabel, 'Last 90 days');
  });

  test('toFilters floors `to` to today and sets `from` days back', () {
    final f7 = DashboardRange.last7Days.toFilters(clock);
    expect(ReportFilters.toIsoDate(f7.to!), '2026-09-09');
    expect(ReportFilters.toIsoDate(f7.from!), '2026-09-02');

    final f30 = DashboardRange.last30Days.toFilters(clock);
    expect(ReportFilters.toIsoDate(f30.from!), '2026-08-10');

    final f90 = DashboardRange.last90Days.toFilters(clock);
    expect(ReportFilters.toIsoDate(f90.from!), '2026-06-11');
  });

  test('toFilters ignores local time-of-day (works from a local clock)', () {
    final local = _FixedClock(DateTime(2026, 9, 9, 23, 59));
    final f = DashboardRange.last7Days.toFilters(local);
    // to == date-floored UTC of the instant; from is exactly 7 days earlier.
    expect(f.to!.difference(f.from!).inDays, 7);
  });
}

/// Date range and optional taxonomy filters for admin reports.
class ReportFilters {
  const ReportFilters({
    this.from,
    this.to,
    this.regionId,
  });

  final DateTime? from;
  final DateTime? to;
  final String? regionId;

  static ReportFilters lastThirtyDays({DateTime? now}) {
    final gstNow = (now ?? DateTime.now().toUtc()).toUtc().add(const Duration(hours: 4));
    final to = DateTime.utc(gstNow.year, gstNow.month, gstNow.day);
    final from = to.subtract(const Duration(days: 30));
    return ReportFilters(from: from, to: to);
  }

  ReportFilters copyWith({
    DateTime? from,
    DateTime? to,
    String? regionId,
    bool clearFrom = false,
    bool clearTo = false,
    bool clearRegionId = false,
  }) {
    return ReportFilters(
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      regionId: clearRegionId ? null : (regionId ?? this.regionId),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (from != null) 'from': toIsoDate(from!),
      if (to != null) 'to': toIsoDate(to!),
      if (regionId != null && regionId!.trim().isNotEmpty)
        'regionId': regionId!.trim(),
    };
  }

  Map<String, dynamic> toJson() => toQueryParameters();

  static String toIsoDate(DateTime value) {
    final utc = value.toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportFilters &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          regionId == other.regionId;

  @override
  int get hashCode => Object.hash(from, to, regionId);

  @override
  String toString() =>
      'ReportFilters(from: $from, to: $to, regionId: $regionId)';
}

/// Date range and optional taxonomy filters for admin reports.
class ReportFilters {
  const ReportFilters({
    this.from,
    this.to,
    this.regionId,
    this.categoryId,
  });

  final DateTime? from;
  final DateTime? to;
  final String? regionId;
  final String? categoryId;

  static ReportFilters lastThirtyDays({DateTime? now}) {
    final today = now ?? DateTime.now().toUtc();
    final to = DateTime.utc(today.year, today.month, today.day);
    final from = to.subtract(const Duration(days: 30));
    return ReportFilters(from: from, to: to);
  }

  ReportFilters copyWith({
    DateTime? from,
    DateTime? to,
    String? regionId,
    String? categoryId,
    bool clearFrom = false,
    bool clearTo = false,
    bool clearRegionId = false,
    bool clearCategoryId = false,
  }) {
    return ReportFilters(
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      regionId: clearRegionId ? null : (regionId ?? this.regionId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (from != null) 'from': toIsoDate(from!),
      if (to != null) 'to': toIsoDate(to!),
      if (regionId != null && regionId!.trim().isNotEmpty)
        'regionId': regionId!.trim(),
      if (categoryId != null && categoryId!.trim().isNotEmpty)
        'categoryId': categoryId!.trim(),
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
}

/// Canonical admin report names for `GET /v1/admin/reports/{name}` (ADM-S17).
enum ReportName {
  acquisition('acquisition'),
  vendorLeague('vendor-league'),
  requestVolume('request-volume'),
  offerCompetitiveness('offer-competitiveness'),
  funnel('funnel'),
  liquidityGaps('liquidity-gaps'),
  ratingDistribution('rating-distribution');

  const ReportName(this.apiValue);

  final String apiValue;

  static const List<ReportName> all = ReportName.values;

  static ReportName fromApi(String? raw) {
    final value = raw?.trim().toLowerCase();
    for (final name in ReportName.values) {
      if (name.apiValue == value) return name;
    }
    return ReportName.acquisition;
  }

  String get fallbackLabel {
    switch (this) {
      case ReportName.acquisition:
        return 'Customer acquisition & retention';
      case ReportName.vendorLeague:
        return 'Vendor performance league';
      case ReportName.requestVolume:
        return 'Request volume';
      case ReportName.offerCompetitiveness:
        return 'Offer competitiveness';
      case ReportName.funnel:
        return 'Funnel conversion';
      case ReportName.liquidityGaps:
        return 'Liquidity gaps';
      case ReportName.ratingDistribution:
        return 'Rating distribution';
    }
  }
}

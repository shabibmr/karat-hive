import 'abuse_report_item.dart';

class AbuseReportPage {
  const AbuseReportPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<AbuseReportItem> items;
  final String? nextCursor;
  final bool hasMore;
}

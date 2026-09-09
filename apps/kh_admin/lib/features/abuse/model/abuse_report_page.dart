import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_item.dart';

/// Cursor-paginated page of abuse report entries (ADM-S21).
typedef AbuseReportPage = Paginated<AbuseReportItem>;

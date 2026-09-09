import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/audit/model/audit_log_item.dart';

/// Cursor-paginated page of audit log entries (ADM-S22).
typedef AuditLogPage = Paginated<AuditLogItem>;

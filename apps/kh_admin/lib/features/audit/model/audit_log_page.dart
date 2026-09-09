import 'package:kh_admin/features/audit/model/audit_log_item.dart';

/// Cursor-paginated page of audit log entries (ADM-S22).
class AuditLogPage {
  const AuditLogPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<AuditLogItem> items;
  final String? nextCursor;
  final bool hasMore;

  bool get canLoadMore =>
      hasMore && nextCursor != null && nextCursor!.isNotEmpty;

  AuditLogPage copyWith({
    List<AuditLogItem>? items,
    String? nextCursor,
    bool? hasMore,
  }) {
    return AuditLogPage(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

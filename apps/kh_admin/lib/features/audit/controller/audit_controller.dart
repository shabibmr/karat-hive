import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/audit/model/audit_log_filters.dart';
import 'package:kh_admin/features/audit/model/audit_log_item.dart';
import 'package:kh_admin/features/audit/repository/audit_repository.dart';

typedef AuditState = CursorListState<AuditLogItem, AuditLogFilters>;

/// Controller managing ADM-S22 audit log state, filters, and pagination (TR-S1-17f).
class AuditController
    extends CursorPaginatedNotifier<AuditLogItem, AuditLogFilters> {
  @override
  AuditLogFilters get initialFilters => const AuditLogFilters();

  @override
  Object? Function(AuditLogItem item)? get itemKey => (item) => item.id;

  @override
  int get pageSize => 50;

  @override
  Future<Paginated<AuditLogItem>> fetchPage({
    required AuditLogFilters filters,
    String? cursor,
    int limit = 50,
  }) {
    return ref.read(auditRepositoryProvider).fetchAuditLogs(
          filters: filters,
          cursor: cursor,
          limit: limit,
        );
  }

  void setActionFilter(String? action) {
    applyFilters(
      state.filters.copyWith(
        action: action,
        clearAction: action == null || action.trim().isEmpty,
      ),
    );
  }

  void setEntityTypeFilter(String? entityType) {
    applyFilters(
      state.filters.copyWith(
        entityType: entityType,
        clearEntityType: entityType == null || entityType.trim().isEmpty,
      ),
    );
  }

  void setActorFilter(String? actorUserId) {
    applyFilters(
      state.filters.copyWith(
        actorUserId: actorUserId,
        clearActorUserId: actorUserId == null || actorUserId.trim().isEmpty,
      ),
    );
  }

  void setIpFilter(String? ip) {
    applyFilters(
      state.filters.copyWith(
        ip: ip,
        clearIp: ip == null || ip.trim().isEmpty,
      ),
    );
  }

  void setDateRange(DateTime? from, DateTime? to) {
    applyFilters(
      state.filters.copyWith(
        from: from,
        to: to,
        clearFrom: from == null,
        clearTo: to == null,
      ),
    );
  }

  void clearFilters() {
    applyFilters(const AuditLogFilters());
  }

  void selectItem(AuditLogItem? item) {}
}

final auditControllerProvider =
    NotifierProvider<AuditController, AuditState>(AuditController.new);

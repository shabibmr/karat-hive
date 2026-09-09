import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_filters.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_item.dart';
import 'package:kh_admin/features/abuse/repository/abuse_repository.dart';

typedef AbuseListState = CursorListState<AbuseReportItem, AbuseReportFilters>;

class AbuseListController
    extends CursorPaginatedNotifier<AbuseReportItem, AbuseReportFilters> {
  @override
  AbuseReportFilters get initialFilters => const AbuseReportFilters();

  @override
  Object? Function(AbuseReportItem item)? get itemKey => (item) => item.id;

  @override
  int get pageSize => 50;

  @override
  Future<Paginated<AbuseReportItem>> fetchPage({
    required AbuseReportFilters filters,
    String? cursor,
    int limit = 50,
  }) {
    return ref.read(abuseRepositoryProvider).fetchAbuseReports(
          filters: filters,
          cursor: cursor,
          limit: limit,
        );
  }

  void setSearchQuery(String query) {
    applyFilters(state.filters.copyWith(query: query));
  }

  void submitSearch() => refresh();

  void setStateFilter(AbuseReportState? reportState) {
    applyFilters(
      state.filters.copyWith(
        state: reportState,
        clearState: reportState == null,
      ),
    );
  }

  void setEntityTypeFilter(AbuseEntityType? entityType) {
    applyFilters(
      state.filters.copyWith(
        entityType: entityType,
        clearEntityType: entityType == null,
      ),
    );
  }

  Future<bool> resolveReport(String id, String resolution) async {
    try {
      await ref.read(abuseRepositoryProvider).resolveAbuseReport(
            id,
            resolution: resolution,
          );
      await refresh();
      return true;
    } on Object catch (_) {
      return false;
    }
  }

  Future<bool> dismissReport(String id, String resolution) async {
    try {
      await ref.read(abuseRepositoryProvider).dismissAbuseReport(
            id,
            resolution: resolution,
          );
      await refresh();
      return true;
    } on Object catch (_) {
      return false;
    }
  }

  /// FR-ADM-032 AC3 — dismiss / warn / suspend / deactivate the reported party,
  /// each with a mandatory rationale. Refreshes the list so the row reflects the
  /// new report state.
  Future<bool> actionReport(
    String id,
    AbuseReportAction action,
    String rationale,
  ) async {
    try {
      await ref.read(abuseRepositoryProvider).actionAbuseReport(
            id,
            action: action,
            rationale: rationale,
          );
      await refresh();
      return true;
    } on Object catch (_) {
      return false;
    }
  }
}

final abuseListControllerProvider =
    NotifierProvider<AbuseListController, AbuseListState>(
  AbuseListController.new,
);

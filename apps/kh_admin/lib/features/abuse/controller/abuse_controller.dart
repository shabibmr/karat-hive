import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_filters.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_item.dart';
import 'package:kh_admin/features/abuse/repository/abuse_repository.dart';

class AbuseListState {
  const AbuseListState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.items = const [],
    this.filters = const AbuseReportFilters(),
    this.errorMessage,
    this.nextCursor,
    this.hasMore = false,
  });

  final bool isLoading;
  final bool isActionLoading;
  final List<AbuseReportItem> items;
  final AbuseReportFilters filters;
  final String? errorMessage;
  final String? nextCursor;
  final bool hasMore;

  AbuseListState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<AbuseReportItem>? items,
    AbuseReportFilters? filters,
    String? errorMessage,
    bool clearError = false,
    String? nextCursor,
    bool clearCursor = false,
    bool? hasMore,
  }) {
    return AbuseListState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      items: items ?? this.items,
      filters: filters ?? this.filters,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class AbuseListController extends StateNotifier<AbuseListState> {
  AbuseListController(this._repository) : super(const AbuseListState()) {
    loadInitial();
  }

  final AbuseRepository _repository;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _repository.fetchAbuseReports(
        filters: state.filters,
      );
      state = state.copyWith(
        isLoading: false,
        items: page.items,
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        hasMore: page.hasMore,
      );
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.nextCursor == null) return;
    try {
      final page = await _repository.fetchAbuseReports(
        filters: state.filters,
        cursor: state.nextCursor,
      );
      state = state.copyWith(
        items: [...state.items, ...page.items],
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        hasMore: page.hasMore,
      );
    } on Object catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> refresh() => loadInitial();

  void setSearchQuery(String query) {
    state = state.copyWith(
      filters: state.filters.copyWith(query: query),
    );
  }

  void submitSearch() => loadInitial();

  void setStateFilter(AbuseReportState? reportState) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        state: reportState,
        clearState: reportState == null,
      ),
    );
    loadInitial();
  }

  void setEntityTypeFilter(AbuseEntityType? entityType) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        entityType: entityType,
        clearEntityType: entityType == null,
      ),
    );
    loadInitial();
  }

  Future<bool> resolveReport(String id, String resolution) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _repository.resolveAbuseReport(id, resolution: resolution);
      state = state.copyWith(isActionLoading: false);
      await refresh();
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to resolve report: $e',
      );
      return false;
    }
  }

  Future<bool> dismissReport(String id, String resolution) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _repository.dismissAbuseReport(id, resolution: resolution);
      state = state.copyWith(isActionLoading: false);
      await refresh();
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to dismiss report: $e',
      );
      return false;
    }
  }
}

final abuseListControllerProvider =
    StateNotifierProvider<AbuseListController, AbuseListState>((ref) {
  final repository = ref.watch(abuseRepositoryProvider);
  return AbuseListController(repository);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/features/audit/model/audit_log_filters.dart';
import 'package:kh_admin/features/audit/model/audit_log_item.dart';
import 'package:kh_admin/features/audit/repository/audit_repository.dart';

/// State object for the ADM-S22 audit log viewer.
class AuditState {
  const AuditState({
    this.items = const [],
    this.filters = const AuditLogFilters(),
    this.nextCursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.cursorHistory = const [null],
    this.selectedItem,
  });

  final List<AuditLogItem> items;
  final AuditLogFilters filters;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final List<String?> cursorHistory;
  final AuditLogItem? selectedItem;

  bool get canLoadMore =>
      hasMore && nextCursor != null && nextCursor!.isNotEmpty;
  bool get canGoNext => canLoadMore && !isLoading && !isLoadingMore;
  bool get canGoPrevious => page > 1 && !isLoading && !isLoadingMore;

  AuditState copyWith({
    List<AuditLogItem>? items,
    AuditLogFilters? filters,
    String? nextCursor,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    int? page,
    List<String?>? cursorHistory,
    AuditLogItem? selectedItem,
    bool clearSelectedItem = false,
  }) {
    return AuditState(
      items: items ?? this.items,
      filters: filters ?? this.filters,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      cursorHistory: cursorHistory ?? this.cursorHistory,
      selectedItem:
          clearSelectedItem ? null : (selectedItem ?? this.selectedItem),
    );
  }
}

class AuditController extends Notifier<AuditState> {
  @override
  AuditState build() {
    Future.microtask(refresh);
    return const AuditState(isLoading: true);
  }

  AuditRepository get _repository => ref.read(auditRepositoryProvider);

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      clearError: true,
      items: const [],
      nextCursor: null,
      hasMore: false,
      page: 1,
      cursorHistory: const [null],
    );

    try {
      final page = await _repository.fetchAuditLogs(filters: state.filters);
      state = state.copyWith(
        isLoading: false,
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        page: 1,
        cursorHistory: const [null],
      );
    } on Object catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      state = state.copyWith(
        isLoading: false,
        error: msg,
      );
    }
  }

  Future<void> nextPage() async {
    if (!state.canGoNext) return;
    final currentCursor = state.nextCursor;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await _repository.fetchAuditLogs(
        filters: state.filters,
        cursor: currentCursor,
      );
      final newHistory = [...state.cursorHistory, currentCursor];
      state = state.copyWith(
        isLoadingMore: false,
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        page: state.page + 1,
        cursorHistory: newHistory,
      );
    } on Object catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> previousPage() async {
    if (!state.canGoPrevious) return;
    final targetPage = state.page - 1;
    final targetCursor = state.cursorHistory[targetPage - 1];
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await _repository.fetchAuditLogs(
        filters: state.filters,
        cursor: targetCursor,
      );
      state = state.copyWith(
        isLoadingMore: false,
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        page: targetPage,
      );
    } on Object catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.canLoadMore) return;
    final currentCursor = state.nextCursor;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await _repository.fetchAuditLogs(
        filters: state.filters,
        cursor: currentCursor,
      );
      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } on Object catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void applyFilters(AuditLogFilters filters) {
    state = state.copyWith(filters: filters);
    refresh();
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
    state = state.copyWith(filters: const AuditLogFilters());
    refresh();
  }

  void selectItem(AuditLogItem? item) {
    state = state.copyWith(
      selectedItem: item,
      clearSelectedItem: item == null,
    );
  }
}

final auditControllerProvider =
    NotifierProvider<AuditController, AuditState>(AuditController.new);

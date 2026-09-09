import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kh_admin/features/vendors/model/vendor_list_filters.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_item.dart';
import 'package:kh_admin/features/vendors/repository/vendor_repository.dart';

part 'vendor_list_controller.freezed.dart';

/// Riverpod state for the ADM-S05 vendor table (filters + cursor pagination).
@freezed
class VendorListState with _$VendorListState {
  const VendorListState._();

  const factory VendorListState({
    @Default([]) List<VendorListItem> items,
    @Default(VendorListFilters()) VendorListFilters filters,
    String? nextCursor,
    bool? hasMore,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    String? error,
    @Default(1) int page,
    @Default([null]) List<String?> cursorHistory,
  }) = _VendorListState;

  bool get canLoadMore {
    if (hasMore == false) return false;
    final cursor = nextCursor;
    return cursor != null && cursor.isNotEmpty;
  }

  bool get canGoNext => canLoadMore && !isLoading && !isLoadingMore;
  bool get canGoPrevious => page > 1 && !isLoading && !isLoadingMore;
}

class VendorListController extends Notifier<VendorListState> {
  @override
  VendorListState build() {
    Future.microtask(refresh);
    return const VendorListState(isLoading: true);
  }

  VendorRepository get _repository => ref.read(vendorRepositoryProvider);

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      error: null,
      items: const [],
      nextCursor: null,
      hasMore: null,
      page: 1,
      cursorHistory: const [null],
    );

    try {
      final page = await _repository.fetchVendors(filters: state.filters);
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

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.canLoadMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final page = await _repository.fetchVendors(
        filters: state.filters,
        cursor: state.nextCursor,
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

  Future<void> nextPage() async {
    if (!state.canGoNext) return;
    final currentCursor = state.nextCursor;
    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final page = await _repository.fetchVendors(
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
    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final page = await _repository.fetchVendors(
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

  Future<void> applyFilters(VendorListFilters filters) async {
    state = state.copyWith(filters: filters);
    await refresh();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      filters: state.filters.copyWith(query: query),
    );
  }

  Future<void> submitSearch() => refresh();
}

final NotifierProvider<VendorListController, VendorListState>
    vendorListControllerProvider =
    NotifierProvider<VendorListController, VendorListState>(
  VendorListController.new,
);

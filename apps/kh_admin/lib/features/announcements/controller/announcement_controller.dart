import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';
import 'package:kh_admin/features/announcements/model/announcement_item.dart';
import 'package:kh_admin/features/announcements/model/create_announcement_dto.dart';
import 'package:kh_admin/features/announcements/repository/announcement_repository.dart';

class AnnouncementListState {
  const AnnouncementListState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.items = const [],
    this.filters = const AnnouncementFilters(),
    this.errorMessage,
    this.nextCursor,
    this.hasMore = false,
  });

  final bool isLoading;
  final bool isActionLoading;
  final List<AnnouncementItem> items;
  final AnnouncementFilters filters;
  final String? errorMessage;
  final String? nextCursor;
  final bool hasMore;

  AnnouncementListState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<AnnouncementItem>? items,
    AnnouncementFilters? filters,
    String? errorMessage,
    bool clearError = false,
    String? nextCursor,
    bool clearCursor = false,
    bool? hasMore,
  }) {
    return AnnouncementListState(
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

class AnnouncementListController extends StateNotifier<AnnouncementListState> {
  AnnouncementListController(this._repository) : super(const AnnouncementListState()) {
    loadInitial();
  }

  final AnnouncementRepository _repository;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _repository.fetchAnnouncements(
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
      final page = await _repository.fetchAnnouncements(
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

  void setStatusFilter(AnnouncementStatus? status) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        status: status,
        clearStatus: status == null,
      ),
    );
    loadInitial();
  }

  void setAudienceFilter(AudienceType? audienceType) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        audienceType: audienceType,
        clearAudienceType: audienceType == null,
      ),
    );
    loadInitial();
  }

  Future<bool> createAnnouncement(CreateAnnouncementDto dto) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _repository.createAnnouncement(dto);
      state = state.copyWith(isActionLoading: false);
      await refresh();
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to create announcement: $e',
      );
      return false;
    }
  }

  Future<bool> cancelAnnouncement(String id) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _repository.cancelAnnouncement(id);
      state = state.copyWith(isActionLoading: false);
      await refresh();
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to cancel announcement: $e',
      );
      return false;
    }
  }
}

final announcementListControllerProvider =
    StateNotifierProvider<AnnouncementListController, AnnouncementListState>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  return AnnouncementListController(repository);
});

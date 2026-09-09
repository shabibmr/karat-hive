import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/features/moderation/model/moderation_enums.dart';
import 'package:kh_admin/features/moderation/model/moderation_filters.dart';
import 'package:kh_admin/features/moderation/model/moderation_review_item.dart';
import 'package:kh_admin/features/moderation/repository/moderation_repository.dart';

class ModerationListState {
  const ModerationListState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.items = const [],
    this.filters = const ModerationFilters(),
    this.errorMessage,
    this.nextCursor,
    this.hasMore = false,
  });

  final bool isLoading;
  final bool isActionLoading;
  final List<ModerationReviewItem> items;
  final ModerationFilters filters;
  final String? errorMessage;
  final String? nextCursor;
  final bool hasMore;

  ModerationListState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<ModerationReviewItem>? items,
    ModerationFilters? filters,
    String? errorMessage,
    bool clearError = false,
    String? nextCursor,
    bool clearCursor = false,
    bool? hasMore,
  }) {
    return ModerationListState(
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

class ModerationListController extends StateNotifier<ModerationListState> {
  ModerationListController(this._repository) : super(const ModerationListState()) {
    loadInitial();
  }

  final ModerationRepository _repository;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _repository.fetchReviews(
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
      final page = await _repository.fetchReviews(
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

  void setStateFilter(ReviewState? reviewState) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        state: reviewState,
        clearState: reviewState == null,
      ),
    );
    loadInitial();
  }

  void setAuthorTypeFilter(AuthorType? authorType) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        authorType: authorType,
        clearAuthorType: authorType == null,
      ),
    );
    loadInitial();
  }

  Future<bool> approveReview(String id) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _repository.approveReview(id);
      state = state.copyWith(isActionLoading: false);
      await refresh();
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to approve review: $e',
      );
      return false;
    }
  }

  Future<bool> rejectReview(String id, String rationale) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _repository.rejectReview(id, rationale: rationale);
      state = state.copyWith(isActionLoading: false);
      await refresh();
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to reject review: $e',
      );
      return false;
    }
  }

  Future<bool> redactReview(String id, String rationale, String redactedComment) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _repository.redactReview(
        id,
        rationale: rationale,
        redactedComment: redactedComment,
      );
      state = state.copyWith(isActionLoading: false);
      await refresh();
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Failed to redact review: $e',
      );
      return false;
    }
  }
}

final moderationListControllerProvider =
    StateNotifierProvider<ModerationListController, ModerationListState>((ref) {
  final repository = ref.watch(moderationRepositoryProvider);
  return ModerationListController(repository);
});

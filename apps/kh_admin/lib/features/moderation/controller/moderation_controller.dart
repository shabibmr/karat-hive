import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/moderation/model/moderation_enums.dart';
import 'package:kh_admin/features/moderation/model/moderation_filters.dart';
import 'package:kh_admin/features/moderation/model/moderation_review_item.dart';
import 'package:kh_admin/features/moderation/repository/moderation_repository.dart';

typedef ModerationListState
    = CursorListState<ModerationReviewItem, ModerationFilters>;

class ModerationListController
    extends CursorPaginatedNotifier<ModerationReviewItem, ModerationFilters> {
  @override
  ModerationFilters get initialFilters => const ModerationFilters();

  @override
  Object? Function(ModerationReviewItem item)? get itemKey => (item) => item.id;

  @override
  int get pageSize => 50;

  @override
  Future<Paginated<ModerationReviewItem>> fetchPage({
    required ModerationFilters filters,
    String? cursor,
    int limit = 50,
  }) {
    return ref.read(moderationRepositoryProvider).fetchReviews(
          filters: filters,
          cursor: cursor,
          limit: limit,
        );
  }

  void setSearchQuery(String query) {
    replaceFilters(state.filters.copyWith(query: query));
  }

  void submitSearch() => refresh();

  void setStateFilter(ReviewState? reviewState) {
    applyFilters(
      state.filters.copyWith(
        state: reviewState,
        clearState: reviewState == null,
      ),
    );
  }

  void setAuthorTypeFilter(AuthorType? authorType) {
    applyFilters(
      state.filters.copyWith(
        authorType: authorType,
        clearAuthorType: authorType == null,
      ),
    );
  }

  Future<bool> approveReview(String id) async {
    await ref.read(moderationRepositoryProvider).approveReview(id);
    await refresh();
    return true;
  }

  Future<bool> rejectReview(String id, String rationale) async {
    await ref.read(moderationRepositoryProvider).rejectReview(
          id,
          rationale: rationale,
        );
    await refresh();
    return true;
  }

  Future<bool> redactReview(
    String id,
    String rationale,
    String redactedComment,
  ) async {
    await ref.read(moderationRepositoryProvider).redactReview(
          id,
          rationale: rationale,
          redactedComment: redactedComment,
        );
    await refresh();
    return true;
  }
}

final moderationListControllerProvider =
    NotifierProvider<ModerationListController, ModerationListState>(
  ModerationListController.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/moderation/controller/moderation_controller.dart';
import 'package:kh_admin/features/moderation/model/moderation_enums.dart';
import 'package:kh_admin/features/moderation/model/moderation_filters.dart';
import 'package:kh_admin/features/moderation/model/moderation_page.dart';
import 'package:kh_admin/features/moderation/model/moderation_review_item.dart';
import 'package:kh_admin/features/moderation/repository/moderation_repository.dart';

class _MockModerationRepository extends ModerationRepository {
  _MockModerationRepository() : super(ApiClient());

  ModerationFilters? lastFilters;
  String? lastCursor;
  int fetchCount = 0;
  String? approvedId;
  String? rejectedId;
  String? rejectedRationale;
  String? redactedId;
  String? redactedRationale;
  String? redactedComment;

  @override
  Future<ModerationPage> fetchReviews({
    ModerationFilters filters = const ModerationFilters(),
    String? cursor,
    int limit = ModerationRepository.defaultLimit,
  }) async {
    fetchCount++;
    lastFilters = filters;
    lastCursor = cursor;

    return ModerationPage(
      items: [
        ModerationReviewItem(
          id: 'rev-1',
          connectionId: 'conn-1',
          authorType: AuthorType.customer,
          authorUserId: 'user-1',
          subjectUserId: 'user-2',
          rating: 4,
          comment: 'Good service overall',
          state: ReviewState.pendingModeration,
          createdAt: DateTime(2026, 9, 1, 10, 0),
        ),
      ],
      nextCursor: null,
      hasMore: false,
    );
  }

  @override
  Future<void> approveReview(String id) async {
    approvedId = id;
  }

  @override
  Future<void> rejectReview(String id, {required String rationale}) async {
    rejectedId = id;
    rejectedRationale = rationale;
  }

  @override
  Future<void> redactReview(
    String id, {
    required String rationale,
    required String redactedComment,
  }) async {
    redactedId = id;
    redactedRationale = rationale;
    this.redactedComment = redactedComment;
  }
}

Future<void> _settle(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!container.read(moderationListControllerProvider).isLoading) return;
  }
  fail('ModerationListController did not finish loading');
}

void main() {
  late ProviderContainer container;
  late _MockModerationRepository mockRepository;

  setUp(() {
    mockRepository = _MockModerationRepository();
    container = ProviderContainer(
      overrides: [
        moderationRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('ModerationListController', () {
    test('initializes and loads reviews', () async {
      await _settle(container);

      final state = container.read(moderationListControllerProvider);
      expect(state.isLoading, false);
      expect(state.items.length, 1);
      expect(state.items.first.id, 'rev-1');
      expect(state.items.first.rating, 4);
    });

    test('updates state filter and triggers reload', () async {
      await _settle(container);

      final controller = container.read(moderationListControllerProvider.notifier);
      controller.setStateFilter(ReviewState.published);
      await _settle(container);

      expect(mockRepository.lastFilters?.state, ReviewState.published);
      expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
    });

    test('approves review successfully', () async {
      await _settle(container);

      final controller = container.read(moderationListControllerProvider.notifier);
      final success = await controller.approveReview('rev-1');
      await _settle(container);

      expect(success, true);
      expect(mockRepository.approvedId, 'rev-1');
    });

    test('rejects review successfully', () async {
      await _settle(container);

      final controller = container.read(moderationListControllerProvider.notifier);
      final success = await controller.rejectReview('rev-1', 'Inappropriate content');
      await _settle(container);

      expect(success, true);
      expect(mockRepository.rejectedId, 'rev-1');
      expect(mockRepository.rejectedRationale, 'Inappropriate content');
    });

    test('redacts review successfully', () async {
      await _settle(container);

      final controller = container.read(moderationListControllerProvider.notifier);
      final success = await controller.redactReview('rev-1', 'PII', 'Clean comment');
      await _settle(container);

      expect(success, true);
      expect(mockRepository.redactedId, 'rev-1');
      expect(mockRepository.redactedRationale, 'PII');
      expect(mockRepository.redactedComment, 'Clean comment');
    });
  });
}

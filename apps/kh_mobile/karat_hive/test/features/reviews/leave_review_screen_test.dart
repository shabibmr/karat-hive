import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:karat_hive/features/reviews/presentation/leave_review_screen.dart';
import 'package:karat_hive/features/reviews/repository/reviews_repository.dart';
import 'package:kh_api/kh_api.dart';

class _MockReviewsRepository implements ReviewsRepository {
  int? lastRating;
  String? lastComment;
  String? lastConnectionId;
  bool returnAlreadyExists = false;

  @override
  Future<Result<Review>> create({
    required String connectionId,
    required int rating,
    String? comment,
  }) async {
    lastConnectionId = connectionId;
    lastRating = rating;
    lastComment = comment;

    if (returnAlreadyExists) {
      return const Err(
        ConflictFailure(
          code: 'REVIEW_ALREADY_EXISTS',
          message: 'Review already exists for this connection.',
        ),
      );
    }

    return Ok(
      Review(
        id: 'rev-1',
        connectionId: connectionId,
        authorType: PartyRole.vendor,
        rating: rating,
        comment: comment,
        state: ReviewState.pendingModeration,
        editableUntil: DateTime.now().add(const Duration(days: 14)),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<void>> flag(String id) async => const Ok(null);

  @override
  Future<Result<PagedResult<Review>>> list({
    String? role,
    String? cursor,
    int limit = 20,
  }) async =>
      const Ok(PagedResult.empty());

  @override
  Future<Result<Review>> patch(String id, {int? rating, String? comment}) async =>
      throw UnimplementedError();

  @override
  Future<Result<Review>> respond(String id, {required String response}) async =>
      throw UnimplementedError();

  @override
  Future<Result<Review>> withdraw(String id) async => throw UnimplementedError();

  @override
  Future<Result<VendorPerformanceDto>> getPerformance() async =>
      throw UnimplementedError();
}

void main() {
  testWidgets('VEN-S19 renders star input, comment, and submits feedback',
      (tester) async {
    final mockRepo = _MockReviewsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const VendorLeaveReviewScreen(
            connectionId: 'conn-101',
            customerLabel: 'Fatima M.',
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('leave-review-screen')), findsOneWidget);
    expect(find.text('Fatima M.'), findsOneWidget);
    expect(find.text('Connection ID: conn-101'), findsOneWidget);
    expect(find.byKey(const Key('star-rating-input')), findsOneWidget);
    expect(find.byKey(const Key('review-comment-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('review-comment-field-input')),
      'Smooth payment and clear specifications.',
    );

    await tester.tap(find.byKey(const Key('leave-review-submit-button')));
    await tester.pumpAndSettle();

    expect(mockRepo.lastConnectionId, 'conn-101');
    expect(mockRepo.lastRating, 5);
    expect(mockRepo.lastComment, 'Smooth payment and clear specifications.');
    expect(find.byKey(const Key('leave-review-submitted')), findsOneWidget);
  });

  testWidgets('VEN-S19 shows already-reviewed card when REVIEW_ALREADY_EXISTS',
      (tester) async {
    final mockRepo = _MockReviewsRepository()..returnAlreadyExists = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const VendorLeaveReviewScreen(
            connectionId: 'conn-101',
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('leave-review-submit-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('leave-review-already-reviewed')), findsOneWidget);
    expect(find.text('Feedback Already Submitted'), findsOneWidget);
  });
}

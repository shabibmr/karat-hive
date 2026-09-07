import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/moderation/model/moderation_enums.dart';
import 'package:kh_admin/features/moderation/model/moderation_filters.dart';
import 'package:kh_admin/features/moderation/model/moderation_page.dart';
import 'package:kh_admin/features/moderation/model/moderation_review_item.dart';
import 'package:kh_admin/features/moderation/presentation/moderation_screen.dart';
import 'package:kh_admin/features/moderation/repository/moderation_repository.dart';

class _FakeModerationRepository extends ModerationRepository {
  _FakeModerationRepository() : super(ApiClient());

  bool empty = false;
  bool failNext = false;
  String? approvedReviewId;
  String? rejectedReviewId;
  String? rejectedRationale;
  String? redactedReviewId;
  String? redactedRationale;
  String? redactedComment;

  @override
  Future<ModerationPage> fetchReviews({
    ModerationFilters filters = const ModerationFilters(),
    String? cursor,
    int limit = ModerationRepository.defaultLimit,
  }) async {
    if (failNext) throw Exception('Review moderation queue unavailable');
    if (empty) return const ModerationPage(items: []);

    return ModerationPage(
      items: [
        ModerationReviewItem(
          id: 'rev-1',
          connectionId: 'conn-1',
          authorType: AuthorType.customer,
          authorUserId: 'user-1',
          subjectUserId: 'user-2',
          rating: 5,
          comment: 'Exceptional craftsmanship and smooth transaction.',
          state: ReviewState.pendingModeration,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          authorName: 'Fatima M.',
          subjectName: 'Al Noor Jewellery LLC',
        ),
      ],
    );
  }

  @override
  Future<void> approveReview(String id) async {
    approvedReviewId = id;
  }

  @override
  Future<void> rejectReview(String id, {required String rationale}) async {
    rejectedReviewId = id;
    rejectedRationale = rationale;
  }

  @override
  Future<void> redactReview(
    String id, {
    required String rationale,
    required String redactedComment,
  }) async {
    redactedReviewId = id;
    redactedRationale = rationale;
    this.redactedComment = redactedComment;
  }
}

void main() {
  Widget buildTestableScreen({required ModerationRepository repository}) {
    return ProviderScope(
      overrides: [
        moderationRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: buildKhAdminTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: const Scaffold(body: ModerationScreen()),
      ),
    );
  }

  group('ModerationScreen', () {
    testWidgets('renders review queue header, metrics and review rows', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeModerationRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Review Moderation Queue'), findsOneWidget);
      expect(find.text('Pending Moderation'), findsWidgets);
      expect(find.text('Exceptional craftsmanship and smooth transaction.'), findsOneWidget);
      expect(find.text('Fatima M.'), findsOneWidget);
      expect(find.text('Al Noor Jewellery LLC'), findsOneWidget);
    });

    testWidgets('opens detail dialog on review tap', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeModerationRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fatima M.'));
      await tester.pumpAndSettle();

      expect(find.text('Review Details #rev-1'), findsOneWidget);
      expect(find.text('Review Comment'), findsOneWidget);
    });

    testWidgets('approves review from list action', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeModerationRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      final approveIcon = find.byIcon(Icons.check_circle_outline);
      expect(approveIcon, findsOneWidget);
      await tester.tap(approveIcon);
      await tester.pumpAndSettle();

      expect(find.text('Approve Review #rev-1'), findsOneWidget);
      await tester.tap(find.byKey(const Key('moderation-confirm-approve-button')));
      await tester.pumpAndSettle();

      expect(repo.approvedReviewId, 'rev-1');
    });

    testWidgets('rejects review with rationale', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeModerationRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      final rejectIcon = find.byIcon(Icons.cancel_outlined);
      expect(rejectIcon, findsOneWidget);
      await tester.tap(rejectIcon);
      await tester.pumpAndSettle();

      expect(find.text('Reject Review #rev-1'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('moderation-reject-rationale-field')),
        'Inappropriate phrasing',
      );
      await tester.tap(find.byKey(const Key('moderation-confirm-reject-button')));
      await tester.pumpAndSettle();

      expect(repo.rejectedReviewId, 'rev-1');
      expect(repo.rejectedRationale, 'Inappropriate phrasing');
    });

    testWidgets('redacts review with rationale and new text', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeModerationRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      final redactIcon = find.byIcon(Icons.edit_note);
      expect(redactIcon, findsOneWidget);
      await tester.tap(redactIcon);
      await tester.pumpAndSettle();

      expect(find.text('Redact Review #rev-1'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('moderation-redacted-comment-field')),
        'Craftsmanship was great [phone number redacted].',
      );
      await tester.enterText(
        find.byKey(const Key('moderation-redact-rationale-field')),
        'PII telephone number redacted',
      );
      await tester.tap(find.byKey(const Key('moderation-confirm-redact-button')));
      await tester.pumpAndSettle();

      expect(repo.redactedReviewId, 'rev-1');
      expect(repo.redactedComment, 'Craftsmanship was great [phone number redacted].');
      expect(repo.redactedRationale, 'PII telephone number redacted');
    });

    testWidgets('renders empty state when no reviews found', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeModerationRepository()..empty = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('moderation-list-empty')), findsOneWidget);
      expect(find.text('No reviews found'), findsOneWidget);
    });

    testWidgets('renders error state on failure with retry', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeModerationRepository()..failNext = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('moderation-list-error')), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

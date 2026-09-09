import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';
import 'package:karat_hive/features/profile_settings/controller/business_profile_controller.dart';
import 'package:karat_hive/features/reviews/presentation/my_reviews_screen.dart';
import 'package:karat_hive/features/reviews/repository/reviews_repository.dart';

class _MockReviewsRepoForList implements ReviewsRepository {
  _MockReviewsRepoForList({
    this.onRespond,
    this.onFlag,
    this.reviews,
    this.performance,
  });

  final Future<Result<Review>> Function(String id, String response)? onRespond;
  final Future<Result<void>> Function(String id)? onFlag;
  final List<Review>? reviews;
  final VendorPerformanceDto? performance;

  int listCalls = 0;
  int respondCalls = 0;
  int flagCalls = 0;
  String? lastRespondedId;
  String? lastResponseText;
  String? lastFlaggedId;

  @override
  Future<Result<VendorPerformanceDto>> getPerformance() async {
    return Ok(performance ??
        const VendorPerformanceDto(
          offersSubmitted: 0,
          acceptanceRate: '0.00',
          averageResponseMinutes: 0,
          ratingTrend: [],
        ));
  }

  @override
  Future<Result<PagedResult<Review>>> list({
    String? role,
    String? cursor,
    int limit = 20,
  }) async {
    listCalls++;
    return Ok(
      PagedResult(
        items: reviews ??
            [
              Review(
                id: 'rev-1',
                connectionId: 'conn-1',
                authorType: PartyRole.customer,
                authorDisplayName: 'Fatima M.',
                rating: 5,
                comment: 'Exceptional craftsmanship and smooth transaction.',
                state: ReviewState.published,
                editableUntil: DateTime.now().add(const Duration(days: 14)),
                createdAt: DateTime.utc(2026, 8, 10),
                publishedAt: DateTime.utc(2026, 8, 10),
              ),
            ],
      ),
    );
  }

  @override
  Future<Result<Review>> create({
    required String connectionId,
    required int rating,
    String? comment,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> flag(String id) async {
    flagCalls++;
    lastFlaggedId = id;
    if (onFlag != null) {
      return onFlag!(id);
    }
    return const Ok(null);
  }

  @override
  Future<Result<Review>> patch(String id, {int? rating, String? comment}) =>
      throw UnimplementedError();

  @override
  Future<Result<Review>> respond(String id, {required String response}) async {
    respondCalls++;
    lastRespondedId = id;
    lastResponseText = response;
    if (onRespond != null) {
      return onRespond!(id, response);
    }
    return Ok(
      Review(
        id: id,
        connectionId: 'conn-1',
        authorType: PartyRole.customer,
        authorDisplayName: 'Fatima M.',
        rating: 5,
        comment: 'Exceptional craftsmanship and smooth transaction.',
        state: ReviewState.published,
        editableUntil: DateTime.now().add(const Duration(days: 14)),
        createdAt: DateTime.utc(2026, 8, 10),
        publishedAt: DateTime.utc(2026, 8, 10),
        vendorResponse: ReviewVendorResponse(
          text: response,
          state: ReviewState.published,
        ),
      ),
    );
  }

  @override
  Future<Result<Review>> withdraw(String id) => throw UnimplementedError();
}

void main() {
  testWidgets('VEN-S20 renders aggregate header with 1 dp and transactions count',
      (tester) async {
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(average: 4.7, count: 12, limitedHistory: false),
      offersSubmittedCount: 15,
      connectionCount: 12,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    final mockRepo = _MockReviewsRepoForList();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('my-reviews-screen')), findsOneWidget);
    expect(find.byKey(const Key('my-reviews-aggregate-header')), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('12 total transactions completed'), findsOneWidget);
    expect(find.text('Fatima M.'), findsOneWidget);
    expect(
      find.text('Exceptional craftsmanship and smooth transaction.'),
      findsOneWidget,
    );
  });

  testWidgets('VEN-S20 displays limited history banner when rating has < 3 reviews',
      (tester) async {
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary.score(4.7, 2),
      offersSubmittedCount: 15,
      connectionCount: 2,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    final mockRepo = _MockReviewsRepoForList();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('my-reviews-screen')), findsOneWidget);
    expect(find.text('New vendor — limited rating history'), findsOneWidget);
  });

  testWidgets(
      'VEN-S20 opens response dialog and validates character length (<= 500 chars)',
      (tester) async {
    final mockRepo = _MockReviewsRepoForList();
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(average: 4.7, count: 12, limitedHistory: false),
      offersSubmittedCount: 15,
      connectionCount: 12,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Respond"
    final respondBtn = find.byKey(const Key('respond-button-rev-1'));
    expect(respondBtn, findsOneWidget);
    await tester.tap(respondBtn);
    await tester.pumpAndSettle();

    // Dialog elements
    expect(find.text('Respond to Review'), findsOneWidget);
    expect(find.byKey(const Key('vendor-response-input')), findsOneWidget);
    expect(find.byKey(const Key('response-character-counter')), findsOneWidget);
    expect(find.text('0 / 500'), findsOneWidget);

    // Empty validation
    final submitBtn = find.byKey(const Key('submit-response-button'));
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Response cannot be empty.'), findsOneWidget);
    expect(mockRepo.respondCalls, 0);

    // Over 500 characters validation
    final over500 = ('This response is excessively long! ' * 20).substring(0, 501);
    await tester.enterText(
        find.byKey(const Key('vendor-response-input')), over500);
    await tester.pumpAndSettle();

    expect(find.text('501 / 500'), findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Maximum 500 characters.'), findsOneWidget);
    expect(mockRepo.respondCalls, 0);

    // Valid 500 characters
    final exactly500 = ('This response is exactly limit! ' * 20).substring(0, 500);
    await tester.enterText(
        find.byKey(const Key('vendor-response-input')), exactly500);
    await tester.pumpAndSettle();
    expect(find.text('500 / 500'), findsOneWidget);

    // Cancel closes dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Respond to Review'), findsNothing);
  });

  testWidgets('VEN-S20 submitting response calls controller and updates UI',
      (tester) async {
    final mockRepo = _MockReviewsRepoForList();
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(average: 4.7, count: 12, limitedHistory: false),
      offersSubmittedCount: 15,
      connectionCount: 12,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Respond"
    await tester.tap(find.byKey(const Key('respond-button-rev-1')));
    await tester.pumpAndSettle();

    // Enter valid response
    const validResponse =
        'Thank you for your kind words! We look forward to serving you again.';
    await tester.enterText(
      find.byKey(const Key('vendor-response-input')),
      validResponse,
    );
    await tester.pumpAndSettle();

    expect(find.text('${validResponse.length} / 500'), findsOneWidget);

    // Submit
    await tester.tap(find.byKey(const Key('submit-response-button')));
    await tester.pumpAndSettle();

    expect(mockRepo.respondCalls, 1);
    expect(mockRepo.lastRespondedId, 'rev-1');
    expect(mockRepo.lastResponseText, validResponse);

    // Dialog dismissed
    expect(find.text('Respond to Review'), findsNothing);

    // Snackbar displayed
    expect(find.text('Response submitted. Held for moderation.'),
        findsOneWidget);

    // List refreshed
    expect(mockRepo.listCalls, greaterThanOrEqualTo(2));
  });

  testWidgets(
      'VEN-S20 conflict error (REVIEW_RESPONSE_EXISTS) shows single response permitted message',
      (tester) async {
    final mockRepo = _MockReviewsRepoForList(
      onRespond: (id, resp) async => const Err(
        ConflictFailure(
          code: 'REVIEW_RESPONSE_EXISTS',
          message: 'Review response already exists',
        ),
      ),
    );
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(average: 4.7, count: 12, limitedHistory: false),
      offersSubmittedCount: 15,
      connectionCount: 12,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Respond"
    await tester.tap(find.byKey(const Key('respond-button-rev-1')));
    await tester.pumpAndSettle();

    // Enter valid response and submit
    await tester.enterText(
      find.byKey(const Key('vendor-response-input')),
      'Duplicate response attempt',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('submit-response-button')));
    await tester.pumpAndSettle();

    expect(mockRepo.respondCalls, 1);

    // Dialog stays open and shows conflict error message
    expect(find.text('Respond to Review'), findsOneWidget);
    expect(
      find.text('Only one public response is permitted per review.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'VEN-S20 conflict error (CONFLICT code) shows single response permitted message',
      (tester) async {
    final mockRepo = _MockReviewsRepoForList(
      onRespond: (id, resp) async => const Err(
        ConflictFailure(
          code: 'CONFLICT',
          message: 'Conflict occurred',
        ),
      ),
    );
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(average: 4.7, count: 12, limitedHistory: false),
      offersSubmittedCount: 15,
      connectionCount: 12,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Respond"
    await tester.tap(find.byKey(const Key('respond-button-rev-1')));
    await tester.pumpAndSettle();

    // Enter valid response and submit
    await tester.enterText(
      find.byKey(const Key('vendor-response-input')),
      'Another duplicate response attempt',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('submit-response-button')));
    await tester.pumpAndSettle();

    expect(mockRepo.respondCalls, 1);

    // Dialog stays open and shows conflict error message
    expect(find.text('Respond to Review'), findsOneWidget);
    expect(
      find.text('Only one public response is permitted per review.'),
      findsOneWidget,
    );
  });

  testWidgets('VEN-S20 tapping "Flag as unfair" shows confirmation dialog',
      (tester) async {
    final mockRepo = _MockReviewsRepoForList();
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(average: 4.7, count: 12, limitedHistory: false),
      offersSubmittedCount: 15,
      connectionCount: 12,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Flag as unfair"
    final flagBtn = find.byKey(const Key('flag-button-rev-1'));
    expect(flagBtn, findsOneWidget);
    await tester.tap(flagBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog elements
    expect(find.text('Flag Review as Unfair'), findsOneWidget);
    expect(
      find.textContaining('Admin moderation queue'),
      findsOneWidget,
    );
    expect(find.text('Flag for Review'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Cancel dismisses dialog without flagging
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Flag Review as Unfair'), findsNothing);
    expect(mockRepo.flagCalls, 0);
  });

  testWidgets(
      'VEN-S20 confirming dialog invokes repo flag method and displays snackbar "Review flagged for moderation."',
      (tester) async {
    final mockRepo = _MockReviewsRepoForList();
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(average: 4.7, count: 12, limitedHistory: false),
      offersSubmittedCount: 15,
      connectionCount: 12,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Flag as unfair"
    await tester.tap(find.byKey(const Key('flag-button-rev-1')));
    await tester.pumpAndSettle();

    // Confirm dialog
    await tester.tap(find.text('Flag for Review'));
    await tester.pumpAndSettle();

    // Verify repo flag method was called
    expect(mockRepo.flagCalls, 1);
    expect(mockRepo.lastFlaggedId, 'rev-1');

    // Verify confirmation snackbar
    expect(find.text('Review flagged for moderation.'), findsOneWidget);
  });

  testWidgets(
      'VEN-S20 flagged review displays the "Flagged for moderation" badge and disables/hides the flag button',
      (tester) async {
    final mockRepo = _MockReviewsRepoForList();
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(average: 4.7, count: 12, limitedHistory: false),
      offersSubmittedCount: 15,
      connectionCount: 12,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially flag button is present and flagged badge is not
    expect(find.byKey(const Key('flag-button-rev-1')), findsOneWidget);
    expect(find.byKey(const Key('flagged-badge-rev-1')), findsNothing);

    // Tap flag and confirm
    await tester.tap(find.byKey(const Key('flag-button-rev-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flag for Review'));
    await tester.pumpAndSettle();

    // Flagged review displays persistent badge and flag button is hidden
    expect(find.byKey(const Key('flagged-badge-rev-1')), findsOneWidget);
    expect(find.text('Flagged for moderation'), findsOneWidget);
    expect(find.byKey(const Key('flag-button-rev-1')), findsNothing);
  });

  testWidgets(
      'VEN-S20 review in pendingModeration state initially displays badge and hides flag button',
      (tester) async {
    final pendingReview = Review(
      id: 'rev-pending',
      connectionId: 'conn-2',
      authorType: PartyRole.customer,
      authorDisplayName: 'Tariq S.',
      rating: 4,
      comment: 'Good service overall.',
      state: ReviewState.pendingModeration,
      editableUntil: DateTime.now().add(const Duration(days: 14)),
      createdAt: DateTime.utc(2026, 8, 12),
      publishedAt: DateTime.utc(2026, 8, 12),
    );

    final mockRepo = _MockReviewsRepoForList(reviews: [pendingReview]);
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(average: 4.7, count: 12, limitedHistory: false),
      offersSubmittedCount: 15,
      connectionCount: 12,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Displays badge and hides flag button
    expect(find.byKey(const Key('flagged-badge-rev-pending')), findsOneWidget);
    expect(find.text('Flagged for moderation'), findsOneWidget);
    expect(find.byKey(const Key('flag-button-rev-pending')), findsNothing);
  });

  testWidgets('VEN-S20 flag error displays error snackbar', (tester) async {
    final mockRepo = _MockReviewsRepoForList(
      onFlag: (id) async => const Err(
        ServerFailure(message: 'Failed to flag review. Try again later.'),
      ),
    );
    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(average: 4.7, count: 12, limitedHistory: false),
      offersSubmittedCount: 15,
      connectionCount: 12,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('flag-button-rev-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flag for Review'));
    await tester.pumpAndSettle();

    expect(mockRepo.flagCalls, 1);
    expect(
      find.text('Failed to flag review. Try again later.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('flagged-badge-rev-1')), findsNothing);
  });

  testWidgets(
      'VEN-S20 displays rating history & trends header, distribution bars, and rating trend chart',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockVendor = VendorMe(
      vendorProfileId: 'v-1',
      tradingName: 'Al Karat Jewellers',
      legalBusinessName: 'Al Karat Gold LLC',
      lifecycle: VendorLifecycle.active,
      awaitingApproval: false,
      categoryCount: 3,
      regionCount: 2,
      verificationMessage: null,
      rating: const RatingSummary(
        average: 4.8,
        count: 25,
        distribution: {'5': 20, '4': 3, '3': 2, '2': 0, '1': 0},
        limitedHistory: false,
      ),
      offersSubmittedCount: 30,
      connectionCount: 25,
      verifiedAt: DateTime.utc(2026, 1, 1),
      businessHours: const {},
    );

    final mockRepo = _MockReviewsRepoForList(
      performance: const VendorPerformanceDto(
        offersSubmitted: 30,
        acceptanceRate: '0.85',
        averageResponseMinutes: 12,
        ratingTrend: [
          RatingTrendPointDto(period: '2026-03', average: 4.5, count: 4),
          RatingTrendPointDto(period: '2026-04', average: 4.6, count: 5),
          RatingTrendPointDto(period: '2026-05', average: 4.7, count: 4),
          RatingTrendPointDto(period: '2026-06', average: 4.8, count: 6),
          RatingTrendPointDto(period: '2026-07', average: 4.9, count: 3),
          RatingTrendPointDto(period: '2026-08', average: 5.0, count: 3),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorProfileProvider.overrideWith((ref) => Future.value(mockVendor)),
          reviewsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: khTheme(),
          home: const MyReviewsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Aggregate rating header
    expect(find.byKey(const Key('my-reviews-aggregate-header')), findsOneWidget);

    // Distribution breakdown
    expect(find.byKey(const Key('rating-summary-distribution')), findsOneWidget);

    // Section header
    expect(find.text('Rating History & Trends'), findsOneWidget);

    // Rating trend chart
    expect(find.byKey(const Key('my-reviews-trend-card')), findsOneWidget);
    expect(find.byType(RatingTrendChart), findsOneWidget);
  });
}


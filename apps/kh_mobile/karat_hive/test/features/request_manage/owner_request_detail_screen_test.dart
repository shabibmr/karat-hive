import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/features/request_manage/presentation/owner_request_detail_screen.dart';
import 'package:karat_hive/features/request_manage/repository/request_manage_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

class _FakeRequestManageRepository implements RequestManageRepository {
  _FakeRequestManageRepository({required this.request});

  RequestForCustomer request;
  Failure? patchError;
  Failure? cancelError;
  String? lastCancelReason;

  @override
  Future<Result<PagedResult<RequestForCustomer>>> listMine({
    String? cursor,
    int limit = 20,
    List<String>? state,
    String? requestType,
    String? direction,
    String? q,
    String? from,
    String? to,
  }) async =>
      Ok(PagedResult(items: [request]));

  @override
  Future<Result<RequestForCustomer>> getMine(String id) async => Ok(request);

  @override
  Future<Result<RequestForCustomer>> patchMine(
    String id, {
    String? notes,
    String? budgetMin,
    String? budgetMax,
    bool? budgetIsFlexible,
    List<String>? mediaKeys,
  }) async {
    if (patchError != null) return Err(patchError!);
    return Ok(request);
  }

  @override
  Future<Result<RequestForCustomer>> cancel(String id, {String? reason}) async {
    lastCancelReason = reason;
    if (cancelError != null) return Err(cancelError!);
    return Ok(request);
  }
}

RequestForCustomer _testRequest({
  String id = 'req-101',
  String reference = 'REQ-2026-0101',
  RequestState state = RequestState.published,
  int offerCount = 0,
  String? connectionId,
}) {
  return RequestForCustomer(
    id: id,
    reference: reference,
    requestType: RequestType.findOrnament,
    direction: Direction.buy,
    state: state,
    category: const CategorySummary(id: 'cat-ring', nameEn: 'Rings', nameAr: 'خواتم'),
    region: const RegionSummary(id: 'reg-dxb', nameEn: 'Dubai', nameAr: 'دبي'),
    weightIsApproximate: false,
    budgetIsFlexible: false,
    offerCount: offerCount,
    media: const [],
    createdAt: DateTime.utc(2026, 9, 1),
    updatedAt: DateTime.utc(2026, 9, 1),
    notes: 'Looking for a simple band ring',
    budgetMin: '2000',
    budgetMax: '3000',
    expiresAt: DateTime.utc(2026, 9, 12),
    connectionId: connectionId,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required RequestManageRepository repo,
  required String requestId,
}) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: '/customer/requests/$requestId',
    routes: [
      GoRoute(
        path: '/customer/requests/:requestId',
        builder: (context, state) => OwnerRequestDetailScreen(
          requestId: state.pathParameters['requestId']!,
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [requestManageRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(
        theme: khTheme(),
        localizationsDelegates: KhStrings.delegates,
        supportedLocales: KhStrings.supportedLocales,
        routerConfig: router,
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('OwnerRequestDetailScreen (CUS-S10)', () {
    testWidgets('renders spec grid, offer count and edit fields for a live request',
        (tester) async {
      final repo = _FakeRequestManageRepository(
        request: _testRequest(offerCount: 2),
      );

      await _pump(tester, repo: repo, requestId: 'req-101');

      expect(find.byKey(const Key('owner-request-detail-screen')), findsOneWidget);
      expect(find.text('REQ-2026-0101'), findsOneWidget);
      expect(find.byKey(const Key('offer-count')), findsOneWidget);
      expect(find.textContaining('2'), findsWidgets);
      expect(find.text('Rings'), findsOneWidget);
      expect(find.text('Dubai'), findsOneWidget);
    });

    testWidgets('shows zero-offers copy when offerCount is 0', (tester) async {
      final repo = _FakeRequestManageRepository(
        request: _testRequest(offerCount: 0),
      );

      await _pump(tester, repo: repo, requestId: 'req-101');

      expect(
        find.text('No offers yet. This request expires according to the countdown above.'),
        findsOneWidget,
      );
    });

    testWidgets('open-connection button is hidden when connectionId is absent',
        (tester) async {
      final repo = _FakeRequestManageRepository(request: _testRequest());

      await _pump(tester, repo: repo, requestId: 'req-101');

      expect(find.text('Open connection'), findsNothing);
    });

    testWidgets('open-connection button is shown when connectionId is present',
        (tester) async {
      final repo = _FakeRequestManageRepository(
        request: _testRequest(connectionId: 'conn-9'),
      );

      await _pump(tester, repo: repo, requestId: 'req-101');

      expect(find.text('Open connection'), findsOneWidget);
    });

    testWidgets('cancel dialog: choosing a reason and confirming calls cancel(reason:)',
        (tester) async {
      final repo = _FakeRequestManageRepository(request: _testRequest());

      await _pump(tester, repo: repo, requestId: 'req-101');

      await tester.tap(find.text('Cancel request'));
      await tester.pumpAndSettle();

      expect(find.text('Pending offers will be withdrawn. This cannot be undone.'),
          findsOneWidget);

      await tester.tap(find.text('Changed my mind'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm-cancel-request')));
      await tester.pumpAndSettle();

      expect(repo.lastCancelReason, 'CHANGED_MIND');
    });

    testWidgets('server error on save (STRUCTURAL_FIELD_IMMUTABLE) shows an inline error banner',
        (tester) async {
      final repo = _FakeRequestManageRepository(request: _testRequest())
        ..patchError = const ValidationFailure(
          code: 'STRUCTURAL_FIELD_IMMUTABLE',
          message: 'This field cannot be changed after publish.',
        );

      await _pump(tester, repo: repo, requestId: 'req-101');

      await tester.tap(find.text('Save edits'));
      await tester.pumpAndSettle();

      expect(find.text('This field cannot be changed after publish.'), findsOneWidget);
    });

    testWidgets('server error on cancel (already accepted) shows an inline error banner',
        (tester) async {
      final repo = _FakeRequestManageRepository(request: _testRequest())
        ..cancelError = const ConflictFailure(
          code: 'REQUEST_NOT_CANCELLABLE',
          message: 'This Request already has an accepted Offer.',
        );

      await _pump(tester, repo: repo, requestId: 'req-101');

      await tester.tap(find.text('Cancel request'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-cancel-request')));
      await tester.pumpAndSettle();

      expect(find.text('This Request already has an accepted Offer.'), findsOneWidget);
    });

    testWidgets('shows Review & Publish and Edit Details buttons when state is DRAFT',
        (tester) async {
      final repo = _FakeRequestManageRepository(
        request: _testRequest(state: RequestState.draft),
      );

      await _pump(tester, repo: repo, requestId: 'req-101');

      expect(find.byKey(const Key('resume-publish-draft')), findsOneWidget);
      expect(find.byKey(const Key('edit-draft-details')), findsOneWidget);
      expect(find.text('View offers'), findsNothing);
    });
  });
}

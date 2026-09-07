import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_filters.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_item.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_page.dart';
import 'package:kh_admin/features/abuse/presentation/abuse_screen.dart';
import 'package:kh_admin/features/abuse/repository/abuse_repository.dart';

class _FakeAbuseRepository extends AbuseRepository {
  _FakeAbuseRepository() : super(ApiClient());

  bool empty = false;
  bool failNext = false;
  String? resolvedReportId;
  String? resolvedRationale;
  String? dismissedReportId;
  String? dismissedRationale;

  @override
  Future<AbuseReportPage> fetchAbuseReports({
    AbuseReportFilters filters = const AbuseReportFilters(),
    String? cursor,
    int limit = AbuseRepository.defaultLimit,
  }) async {
    if (failNext) throw Exception('Abuse queue unavailable');
    if (empty) return const AbuseReportPage(items: []);

    return AbuseReportPage(
      items: [
        AbuseReportItem(
          id: 'ab-1',
          reporterUserId: 'user-1',
          reportedUserId: 'user-2',
          entityType: AbuseEntityType.vendor,
          entityId: 'ven-1',
          category: 'INAPPROPRIATE_TERMS',
          description: 'Demanded off-platform cash advance payment',
          state: AbuseReportState.open,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          reporterName: 'Sara Al Maktoum',
          reportedName: 'Al Noor Jewellery',
        ),
      ],
    );
  }

  @override
  Future<void> resolveAbuseReport(String id, {required String resolution}) async {
    resolvedReportId = id;
    resolvedRationale = resolution;
  }

  @override
  Future<void> dismissAbuseReport(String id, {required String resolution}) async {
    dismissedReportId = id;
    dismissedRationale = resolution;
  }
}

void main() {
  Widget buildTestableScreen({required AbuseRepository repository}) {
    return ProviderScope(
      overrides: [
        abuseRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: buildKhAdminTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: const Scaffold(body: AbuseScreen()),
      ),
    );
  }

  group('AbuseScreen', () {
    testWidgets('renders header, metrics and reports list', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAbuseRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Abuse Report Queue'), findsOneWidget);
      expect(find.text('OPEN REPORTS'), findsOneWidget);
      expect(find.text('INAPPROPRIATE_TERMS'), findsOneWidget);
      expect(find.text('Al Noor Jewellery'), findsOneWidget);
    });

    testWidgets('opens detail dialog on row tap', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAbuseRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('INAPPROPRIATE_TERMS'));
      await tester.pumpAndSettle();

      expect(find.text('Abuse Report Detail #ab-1'), findsOneWidget);
      expect(find.text('Demanded off-platform cash advance payment'), findsOneWidget);
      expect(find.text('Reporter Info'), findsOneWidget);
      expect(find.text('Sara Al Maktoum'), findsOneWidget);
    });

    testWidgets('opens resolve dialog and submits resolution', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAbuseRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      final resolveIcon = find.byIcon(Icons.check_circle_outline);
      expect(resolveIcon, findsOneWidget);
      await tester.tap(resolveIcon);
      await tester.pumpAndSettle();

      expect(find.text('Resolve Abuse Report #ab-1'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('abuse-resolve-rationale-field')),
        'Issued official warning to vendor',
      );
      await tester.tap(find.byKey(const Key('abuse-confirm-resolve-button')));
      await tester.pumpAndSettle();

      expect(repo.resolvedReportId, 'ab-1');
      expect(repo.resolvedRationale, 'Issued official warning to vendor');
    });

    testWidgets('opens dismiss dialog and submits dismissal', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAbuseRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      final dismissIcon = find.byIcon(Icons.cancel_outlined);
      expect(dismissIcon, findsOneWidget);
      await tester.tap(dismissIcon);
      await tester.pumpAndSettle();

      expect(find.text('Dismiss Abuse Report #ab-1'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('abuse-dismiss-rationale-field')),
        'No rule violation found',
      );
      await tester.tap(find.byKey(const Key('abuse-confirm-dismiss-button')));
      await tester.pumpAndSettle();

      expect(repo.dismissedReportId, 'ab-1');
      expect(repo.dismissedRationale, 'No rule violation found');
    });

    testWidgets('shows empty state when no reports match', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAbuseRepository()..empty = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('abuse-list-empty')), findsOneWidget);
      expect(find.text('No abuse reports found'), findsOneWidget);
    });

    testWidgets('shows error state with retry on failure', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAbuseRepository()..failNext = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('abuse-list-error')), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

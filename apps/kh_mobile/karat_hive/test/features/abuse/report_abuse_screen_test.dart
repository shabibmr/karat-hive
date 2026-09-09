import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/abuse/presentation/report_abuse_screen.dart';
import 'package:karat_hive/features/abuse/repository/abuse_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

class _MockAbuseRepository implements AbuseRepository {
  AbuseEntityType? lastEntityType;
  String? lastEntityId;
  String? lastCategory;
  String? lastDescription;
  bool shouldFail = false;
  String? failMessage;

  @override
  Future<Result<AbuseReport>> submit({
    required AbuseEntityType entityType,
    required String entityId,
    required String category,
    required String description,
  }) async {
    lastEntityType = entityType;
    lastEntityId = entityId;
    lastCategory = category;
    lastDescription = description;

    if (shouldFail) {
      return Err(
        NetworkFailure(
          message: failMessage ?? 'Failed to submit report',
        ),
      );
    }

    return const Ok(
      AbuseReport(
        id: 'rep-001',
        state: AbuseReportState.open,
        acknowledged: true,
      ),
    );
  }
}

Widget _buildTestApp({
  required _MockAbuseRepository repository,
  required Widget child,
}) {
  return ProviderScope(
    overrides: [
      abuseRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: khTheme(),
      home: child,
    ),
  );
}

void main() {
  group('VEN-S21 ReportAbuseScreen', () {
    late _MockAbuseRepository mockRepo;

    setUp(() {
      mockRepo = _MockAbuseRepository();
    });

    testWidgets('renders AbuseReportForm with context and options', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          repository: mockRepo,
          child: const ReportAbuseScreen(
            entityType: 'REQUEST',
            entityId: 'req-101',
            entityReference: 'REQ-REF-001',
          ),
        ),
      );

      // Verify screen and form are rendered
      expect(find.byType(ReportAbuseScreen), findsOneWidget);
      expect(find.byType(AbuseReportForm), findsOneWidget);
      expect(find.byKey(const Key('abuse-report-form')), findsOneWidget);

      // Verify header and context
      expect(find.text('Report Abuse'), findsOneWidget);
      expect(find.text('Report request'), findsOneWidget);
      expect(find.text('Context: REQ-REF-001'), findsOneWidget);

      // Verify buttons
      expect(find.byKey(const Key('abuse-report-submit-button')), findsOneWidget);
      expect(find.byKey(const Key('abuse-report-cancel-button')), findsOneWidget);
    });

    testWidgets('submitting form invokes controller and displays confirmation snackbar',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          repository: mockRepo,
          child: const ScaffoldMessenger(
            child: ReportAbuseScreen(
              entityType: 'REQUEST',
              entityId: 'req-202',
              entityReference: 'REQ-REF-202',
            ),
          ),
        ),
      );

      // Enter description
      await tester.enterText(
        find.byKey(const Key('abuse-report-explanation-input')),
        'Fraudulent offer details submitted by party.',
      );

      // Tap submit button
      await tester.tap(find.byKey(const Key('abuse-report-submit-button')));
      await tester.pumpAndSettle();

      // Controller / repository invocation assertions
      expect(mockRepo.lastEntityType, AbuseEntityType.request);
      expect(mockRepo.lastEntityId, 'req-202');
      expect(mockRepo.lastCategory, 'FRAUDULENT_REQUEST');
      expect(mockRepo.lastDescription, 'Fraudulent offer details submitted by party.');

      // Confirmation snackbar assertion
      expect(find.text('Report submitted for admin moderation'), findsOneWidget);

      // Confirmation state card rendered
      expect(find.byKey(const Key('abuse-report-submitted')), findsOneWidget);
      expect(find.text('Report Submitted'), findsOneWidget);
      expect(find.byKey(const Key('abuse-report-done-button')), findsOneWidget);
    });

    testWidgets('error on submit shows failure in form', (tester) async {
      mockRepo.shouldFail = true;
      mockRepo.failMessage = 'Network error. Please try again.';

      await tester.pumpWidget(
        _buildTestApp(
          repository: mockRepo,
          child: const ScaffoldMessenger(
            child: ReportAbuseScreen(
              entityType: 'CONNECTION',
              entityId: 'conn-303',
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('abuse-report-explanation-input')),
        'Inappropriate messaging in connection.',
      );

      await tester.tap(find.byKey(const Key('abuse-report-submit-button')));
      await tester.pumpAndSettle();

      expect(mockRepo.lastEntityType, AbuseEntityType.connection);
      expect(mockRepo.lastEntityId, 'conn-303');
      expect(find.text('Report submitted for admin moderation'), findsNothing);
      expect(find.byKey(const Key('abuse-report-submitted')), findsNothing);
      expect(find.text('Failed to submit report. Please try again.'), findsOneWidget);
    });

    testWidgets('cancel button pops screen from navigation stack', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          repository: mockRepo,
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportAbuseScreen(
                        entityType: 'CONNECTION',
                        entityId: 'conn-404',
                      ),
                    ),
                  );
                },
                child: const Text('Open Screen'),
              ),
            ),
          ),
        ),
      );

      // Open the abuse report screen
      await tester.tap(find.text('Open Screen'));
      await tester.pumpAndSettle();
      expect(find.byType(ReportAbuseScreen), findsOneWidget);

      // Tap cancel
      await tester.tap(find.byKey(const Key('abuse-report-cancel-button')));
      await tester.pumpAndSettle();

      // Screen is popped
      expect(find.byType(ReportAbuseScreen), findsNothing);
      expect(find.text('Open Screen'), findsOneWidget);
    });

    testWidgets('done button after successful submit pops screen', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          repository: mockRepo,
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportAbuseScreen(
                        entityType: 'REQUEST',
                        entityId: 'req-505',
                      ),
                    ),
                  );
                },
                child: const Text('Open Screen'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Screen'));
      await tester.pumpAndSettle();
      expect(find.byType(ReportAbuseScreen), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('abuse-report-explanation-input')),
        'Test reason description.',
      );
      await tester.tap(find.byKey(const Key('abuse-report-submit-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('abuse-report-submitted')), findsOneWidget);

      // Tap Done button
      await tester.tap(find.byKey(const Key('abuse-report-done-button')));
      await tester.pumpAndSettle();

      expect(find.byType(ReportAbuseScreen), findsNothing);
      expect(find.text('Open Screen'), findsOneWidget);
    });

    testWidgets('VendorReportAbuseScreen alias behaves as ReportAbuseScreen', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          repository: mockRepo,
          child: const VendorReportAbuseScreen(
            entityType: 'REQUEST',
            entityId: 'req-606',
            entityReference: 'REQ-606-REF',
          ),
        ),
      );

      expect(find.byType(VendorReportAbuseScreen), findsOneWidget);
      expect(find.byType(ReportAbuseScreen), findsOneWidget);
      expect(find.byType(AbuseReportForm), findsOneWidget);
      expect(find.text('Context: REQ-606-REF'), findsOneWidget);
    });
  });
}

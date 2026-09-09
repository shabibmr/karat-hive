import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/src/abuse_report_form.dart';

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  group('SH-RPT-01 AbuseReportForm', () {
    testWidgets('renders context and default vendor category', (tester) async {
      await tester.pumpWidget(
        _host(
          const AbuseReportForm(
            entityType: AbuseEntityType.request,
            entityId: 'req-123',
            entityReference: 'REQ-1001',
            reporterRole: UserRole.vendor,
          ),
        ),
      );

      expect(find.byKey(const Key('abuse-report-form')), findsOneWidget);
      expect(find.text('Report request'), findsOneWidget);
      expect(find.text('Context: REQ-1001'), findsOneWidget);
      expect(find.text('Trust & Safety'), findsOneWidget);
      expect(
        find.textContaining('Confidential: Reporter identity is withheld'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('abuse-report-submit-button')), findsOneWidget);
    });

    testWidgets('adapts category options for Customer role', (tester) async {
      await tester.pumpWidget(
        _host(
          const AbuseReportForm(
            entityType: AbuseEntityType.offer,
            entityId: 'off-456',
            entityReference: 'OFF-2002',
            reporterRole: UserRole.customer,
          ),
        ),
      );

      expect(find.text('Report offer'), findsOneWidget);
      expect(find.text('Context: OFF-2002'), findsOneWidget);
      expect(find.text('Fraudulent Offer'), findsOneWidget);
    });

    testWidgets('submitting passes category and description, then shows acknowledgement',
        (tester) async {
      String? submittedCategory;
      String? submittedDescription;
      bool doneCalled = false;

      await tester.pumpWidget(
        _host(
          AbuseReportForm(
            entityType: AbuseEntityType.request,
            entityId: 'req-123',
            entityReference: 'REQ-1001',
            onSubmit: ({required category, required description}) async {
              submittedCategory = category;
              submittedDescription = description;
              return true;
            },
            onDone: () => doneCalled = true,
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('abuse-report-explanation-input')),
        'Suspected counterfeit purity description.',
      );

      await tester.tap(find.byKey(const Key('abuse-report-submit-button')));
      await tester.pumpAndSettle();

      expect(submittedCategory, 'FRAUDULENT_REQUEST');
      expect(submittedDescription, 'Suspected counterfeit purity description.');

      // Acknowledgement view
      expect(find.byKey(const Key('abuse-report-submitted')), findsOneWidget);
      expect(find.text('Report Submitted'), findsOneWidget);
      expect(
        find.text('Your identity is never disclosed to the reported party.'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('abuse-report-done-button')));
      expect(doneCalled, isTrue);
    });

    testWidgets('cancelling triggers onCancel callback', (tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(
        _host(
          AbuseReportForm(
            entityType: AbuseEntityType.connection,
            entityId: 'conn-789',
            onCancel: () => cancelCalled = true,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('abuse-report-cancel-button')));
      expect(cancelCalled, isTrue);
    });
  });
}

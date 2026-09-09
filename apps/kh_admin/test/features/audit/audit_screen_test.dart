import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/features/audit/model/audit_log_filters.dart';
import 'package:kh_admin/features/audit/model/audit_log_item.dart';
import 'package:kh_admin/features/audit/model/audit_log_page.dart';
import 'package:kh_admin/features/audit/presentation/audit_screen.dart';
import 'package:kh_admin/features/audit/repository/audit_repository.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

class _MockAuditRepository implements AuditRepository {
  _MockAuditRepository({
    List<AuditLogItem>? items,
    this.throwError = false,
    this.delay,
  }) : items = items ??
            [
              AuditLogItem(
                id: 'audit-001',
                actorUserId: 'admin-101',
                action: 'VENDOR_VERIFIED',
                entityType: 'vendor_profile',
                entityId: 'ven-555',
                beforeValue: {'verificationState': 'PENDING_VERIFICATION'},
                afterValue: {'verificationState': 'VERIFIED'},
                ip: '10.20.30.40',
                userAgent: 'AdminPortalClient/1.0',
                occurredAt: DateTime.parse('2026-08-10T05:30:00.000Z'), // 09:30 GST
              ),
              AuditLogItem(
                id: 'audit-002',
                actorUserId: 'admin-102',
                action: 'CUSTOMER_SUSPENDED',
                entityType: 'customer_profile',
                entityId: 'cust-999',
                beforeValue: {'accountState': 'ACTIVE'},
                afterValue: {
                  'accountState': 'SUSPENDED',
                  'reasonCode': 'FRAUD_SUSPICION',
                },
                ip: '10.20.30.41',
                userAgent: 'AdminPortalClient/1.0',
                occurredAt: DateTime.parse('2026-08-10T12:00:00.000Z'), // 16:00 GST
              ),
            ];

  final List<AuditLogItem> items;
  bool throwError;
  Completer<AuditLogPage>? delay;

  @override
  Future<AuditLogPage> fetchAuditLogs({
    AuditLogFilters filters = const AuditLogFilters(),
    String? cursor,
    int limit = 50,
  }) async {
    if (delay != null) {
      return delay!.future;
    }
    if (throwError) {
      throw Exception('Database query timeout');
    }
    return AuditLogPage(items: items);
  }
}

Widget createAuditWidget({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: buildKhAdminTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: AuditScreen()),
    ),
  );
}

void main() {
  Future<void> pumpDesktopAuditScreen(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final defaultOverrides = [
      auditRepositoryProvider.overrideWithValue(_MockAuditRepository()),
      ...overrides,
    ];

    await tester.pumpWidget(createAuditWidget(overrides: defaultOverrides));
    await tester.pumpAndSettle();
  }

  testWidgets('renders ADM-S22 header and self-view notice banner',
      (tester) async {
    await pumpDesktopAuditScreen(tester);

    expect(find.text('COMPLIANCE & SECURITY'), findsOneWidget);
    expect(find.text('Audit Log'), findsOneWidget);

    final banner = find.byKey(const Key('audit-self-view-notice'));
    expect(banner, findsOneWidget);
    expect(
      find.descendant(
        of: banner,
        matching: find.textContaining(
          'Audit access log: Viewing this log generates an immutable AUDIT_VIEWED entry.',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders filters toolbar elements', (tester) async {
    await pumpDesktopAuditScreen(tester);

    expect(
      find.byKey(const Key('audit-action-filter-dropdown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('audit-entity-filter-dropdown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('audit-actor-search-input')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('audit-date-range-button')),
      findsOneWidget,
    );
  });

  testWidgets('renders KhDataTable with GST formatted dates and actions',
      (tester) async {
    await pumpDesktopAuditScreen(tester);

    expect(find.byKey(const Key('audit-data-table')), findsOneWidget);
    expect(find.byType(KhDataTable), findsOneWidget);

    // GST formatted time checks (+4 hours)
    // 2026-08-10T05:30:00Z -> 09:30:00 GST
    expect(find.text('2026-08-10 09:30:00 GST'), findsOneWidget);
    // 2026-08-10T12:00:00Z -> 16:00:00 GST
    expect(find.text('2026-08-10 16:00:00 GST'), findsOneWidget);

    expect(find.text('VENDOR_VERIFIED'), findsOneWidget);
    expect(find.text('CUSTOMER_SUSPENDED'), findsOneWidget);
  });

  testWidgets(
      'inspecting a row opens detail modal with before/after state diff (SAM-GAP-12)',
      (tester) async {
    await pumpDesktopAuditScreen(tester);

    // Tap first row inspect button
    await tester.tap(find.text('Inspect').first);
    await tester.pumpAndSettle();

    expect(find.text('AUDIT ENTRY DETAIL'), findsOneWidget);
    expect(find.text('State Change Diff (SAM-GAP-12)'), findsOneWidget);
    expect(find.text('BEFORE VALUE'), findsOneWidget);
    expect(find.text('AFTER VALUE'), findsOneWidget);
    expect(find.textContaining('PENDING_VERIFICATION'), findsOneWidget);
    expect(find.textContaining('VERIFIED'), findsWidgets);
    expect(find.textContaining('verificationState'), findsWidgets);
    expect(find.text('10.20.30.40'), findsWidgets);
    expect(find.text('AdminPortalClient/1.0'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('AUDIT ENTRY DETAIL'), findsNothing);
  });

  testWidgets('shows loading indicator while the audit trail is in flight',
      (tester) async {
    final delay = Completer<AuditLogPage>();
    final mock = _MockAuditRepository(delay: delay);

    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      createAuditWidget(
        overrides: [
          auditRepositoryProvider.overrideWithValue(mock),
        ],
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('audit-loading-indicator')), findsOneWidget);

    delay.complete(const AuditLogPage(items: []));
    await tester.pumpAndSettle();
  });

  testWidgets('renders empty view when no audit records match', (tester) async {
    await pumpDesktopAuditScreen(
      tester,
      overrides: [
        auditRepositoryProvider.overrideWithValue(
          _MockAuditRepository(items: const []),
        ),
      ],
    );

    expect(find.byKey(const Key('audit-empty-view')), findsOneWidget);
    expect(find.text('No audit records found'), findsOneWidget);
  });

  testWidgets('renders error view with retry button on failure',
      (tester) async {
    final mock = _MockAuditRepository(throwError: true);

    await pumpDesktopAuditScreen(
      tester,
      overrides: [
        auditRepositoryProvider.overrideWithValue(mock),
      ],
    );

    expect(find.byKey(const Key('audit-error-view')), findsOneWidget);
    expect(find.textContaining('Failed to load audit trail'), findsOneWidget);

    // Fix error and retry
    mock.throwError = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audit-error-view')), findsNothing);
    expect(find.text('VENDOR_VERIFIED'), findsOneWidget);
  });
}

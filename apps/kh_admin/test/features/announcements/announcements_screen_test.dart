import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';
import 'package:kh_admin/features/announcements/model/announcement_item.dart';
import 'package:kh_admin/features/announcements/model/announcement_page.dart';
import 'package:kh_admin/features/announcements/model/create_announcement_dto.dart';
import 'package:kh_admin/features/announcements/presentation/announcements_screen.dart';
import 'package:kh_admin/features/announcements/repository/announcement_repository.dart';

class _FakeAnnouncementRepository extends AnnouncementRepository {
  _FakeAnnouncementRepository() : super(ApiClient());

  bool empty = false;
  bool failNext = false;
  Completer<AnnouncementPage>? delay;
  CreateAnnouncementDto? createdDto;
  String? cancelledAnnouncementId;

  @override
  Future<AnnouncementPage> fetchAnnouncements({
    AnnouncementFilters filters = const AnnouncementFilters(),
    String? cursor,
    int limit = AnnouncementRepository.defaultLimit,
  }) async {
    if (delay != null) return delay!.future;
    if (failNext) throw Exception('Announcements backend service unavailable');
    if (empty) return const AnnouncementPage(items: []);

    return AnnouncementPage(
      items: [
        AnnouncementItem(
          id: 'ann-1',
          titleEn: 'Eid Holiday Souk Hours',
          titleAr: 'مواعيد سوق الذهب في العيد',
          bodyEn: 'Souk stores will open from 4 PM until 11 PM during Eid holidays.',
          bodyAr: 'ستفتح متاجر السوق من الساعة الرابعة عصراً حتى الحادية عشرة مساءً.',
          audience: const {'userType': 'ALL'},
          channels: const AnnouncementChannels(inApp: true, push: true, email: false),
          critical: true,
          scheduledFor: DateTime.now().add(const Duration(days: 3)),
          createdByDisplayName: 'Admin Sarah',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        AnnouncementItem(
          id: 'ann-2',
          titleEn: 'Vendor Gold Rate Policy',
          titleAr: 'سياسة تسعير الذهب للتجار',
          bodyEn: 'New reference rate policies apply starting Monday.',
          bodyAr: 'تطبق سياسات أسعار الذهب المرجعية الجديدة ابتداءً من يوم الاثنين.',
          audience: const {'userType': 'VENDOR'},
          channels: const AnnouncementChannels(inApp: true, push: false, email: true),
          critical: false,
          dispatchStats: const DispatchStats(sent: 250, delivered: 245, opened: 180),
          createdByDisplayName: 'Admin Tariq',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }

  @override
  Future<AnnouncementItem> createAnnouncement(CreateAnnouncementDto dto) async {
    createdDto = dto;
    return AnnouncementItem(
      id: 'ann-created-1',
      titleEn: dto.titleEn,
      titleAr: dto.titleAr,
      bodyEn: dto.bodyEn,
      bodyAr: dto.bodyAr,
      audience: dto.audience,
      channels: AnnouncementChannels.fromJson(dto.channels),
      critical: dto.critical,
      scheduledFor: dto.scheduledFor,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AnnouncementItem> cancelAnnouncement(String id) async {
    cancelledAnnouncementId = id;
    return AnnouncementItem(
      id: id,
      titleEn: 'Eid Holiday Souk Hours',
      titleAr: 'مواعيد سوق الذهب في العيد',
      bodyEn: '',
      bodyAr: '',
      audience: const {},
      channels: const AnnouncementChannels(),
      critical: false,
      cancelledAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  Widget buildTestableScreen({required AnnouncementRepository repository}) {
    return ProviderScope(
      overrides: [
        announcementRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: buildKhAdminTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: const Scaffold(body: AnnouncementsScreen()),
      ),
    );
  }

  group('AnnouncementsScreen', () {
    testWidgets('renders header, metric cards and table rows', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAnnouncementRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      // Screen Header
      expect(find.text('Announcement Composer'), findsOneWidget);
      expect(find.text('BROADCAST COMMUNICATIONS'), findsOneWidget);

      // Metric Cards (label is rendered uppercase by KhMetricCard)
      expect(find.text('TOTAL ANNOUNCEMENTS'), findsOneWidget);
      expect(find.text('SCHEDULED'), findsOneWidget);
      expect(find.text('DISPATCHED'), findsOneWidget);
      expect(find.text('CANCELLED'), findsOneWidget);

      // Table columns & rows
      expect(find.text('Eid Holiday Souk Hours'), findsOneWidget);
      expect(find.text('Vendor Gold Rate Policy'), findsOneWidget);
      expect(find.text('All Users'), findsOneWidget);
      expect(find.text('Vendors Only'), findsOneWidget);
      expect(find.text('Pending dispatch'), findsOneWidget);
      expect(find.text('250 sent (245 deliv.)'), findsOneWidget);
    });

    testWidgets('opens detail dialog showing bilingual content and SAM-GAP-10 notice',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAnnouncementRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      // Tap on row to open detail dialog
      await tester.tap(find.text('Eid Holiday Souk Hours'));
      await tester.pumpAndSettle();

      expect(find.text('Announcement #ann-1'), findsOneWidget);
      expect(find.text('ENGLISH CONTENT'), findsOneWidget);
      expect(find.text('المحتوى باللغة العربية'), findsOneWidget);
      expect(find.text('Souk stores will open from 4 PM until 11 PM during Eid holidays.'),
          findsOneWidget);
      expect(find.text('ستفتح متاجر السوق من الساعة الرابعة عصراً حتى الحادية عشرة مساءً.'),
          findsOneWidget);
      // SAM-GAP-10 notice check
      expect(
          find.text(
              'SAM-GAP-10: Recipient counts are evaluated dynamically at scheduled dispatch.'),
          findsOneWidget);
    });

    testWidgets('detail dialog for dispatched item displays sent/delivered stats',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAnnouncementRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vendor Gold Rate Policy'));
      await tester.pumpAndSettle();

      expect(find.text('Announcement #ann-2'), findsOneWidget);
      expect(find.text('250'), findsOneWidget); // sent
      expect(find.text('245'), findsOneWidget); // delivered
      expect(find.text('180'), findsOneWidget); // opened
    });

    testWidgets('opens compose dialog, fills bilingual fields, and submits announcement',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAnnouncementRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      // Click Compose Announcement
      await tester.tap(find.byKey(const Key('compose-announcement-button')));
      await tester.pumpAndSettle();

      expect(find.text('Compose Announcement'), findsWidgets);
      // SAM-GAP-10 notice in compose dialog
      expect(
          find.text(
              'Dynamic Recipient Evaluation (SAM-GAP-10): Pre-send recipient counts are not previewed. The target audience is evaluated dynamically at the scheduled dispatch moment.'),
          findsOneWidget);

      // Fill English Fields
      await tester.enterText(
        find.byKey(const Key('announcement-title-en-field')),
        'Emergency Souk Notice',
      );
      await tester.enterText(
        find.byKey(const Key('announcement-body-en-field')),
        'Souk will be closed tomorrow for safety maintenance.',
      );

      // Switch to Arabic Tab
      await tester.tap(find.text('العربية (Arabic)'));
      await tester.pumpAndSettle();

      // Fill Arabic Fields
      await tester.enterText(
        find.byKey(const Key('announcement-title-ar-field')),
        'إشعار طارئ لسوق الذهب',
      );
      await tester.enterText(
        find.byKey(const Key('announcement-body-ar-field')),
        'سيتم إغلاق السوق غداً لأعمال الصيانة والسلامة.',
      );

      // Toggle Critical notice
      await tester.tap(find.byKey(const Key('announcement-critical-switch')));
      await tester.pumpAndSettle();

      // Submit Broadcast Now
      await tester.tap(find.byKey(const Key('announcement-submit-button')));
      await tester.pumpAndSettle();

      expect(repo.createdDto, isNotNull);
      expect(repo.createdDto!.titleEn, 'Emergency Souk Notice');
      expect(repo.createdDto!.titleAr, 'إشعار طارئ لسوق الذهب');
      expect(repo.createdDto!.critical, true);
      expect(repo.createdDto!.channels['inApp'], true);
    });

    testWidgets('cancels scheduled announcement via cancel action', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAnnouncementRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      // Row 1 (Eid Souk Hours) is scheduled and has cancel button
      final cancelIcon = find.byIcon(Icons.cancel_outlined);
      expect(cancelIcon, findsOneWidget); // only 1 is cancellable

      await tester.tap(cancelIcon);
      await tester.pumpAndSettle();

      expect(find.text('Cancel Announcement #ann-1'), findsOneWidget);
      await tester.tap(find.byKey(const Key('announcement-confirm-cancel-button')));
      await tester.pumpAndSettle();

      expect(repo.cancelledAnnouncementId, 'ann-1');
    });

    testWidgets('shows empty state when no announcements match', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAnnouncementRepository()..empty = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('announcement-list-empty')), findsOneWidget);
      expect(find.text('No announcements found'), findsOneWidget);
    });

    testWidgets('shows loading indicator while announcements are in flight',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAnnouncementRepository()
        ..delay = Completer<AnnouncementPage>();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pump();

      expect(find.byKey(const Key('announcement-list-loading')), findsOneWidget);

      repo.delay!.complete(const AnnouncementPage(items: []));
      await tester.pumpAndSettle();
    });

    testWidgets('shows error state and retries on failure', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAnnouncementRepository()..failNext = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('announcement-list-error')), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

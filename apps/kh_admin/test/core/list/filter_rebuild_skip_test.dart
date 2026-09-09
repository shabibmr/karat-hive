import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_filters.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';
import 'package:kh_admin/features/customers/model/customer_list_filters.dart';
import 'package:kh_admin/features/moderation/model/moderation_enums.dart';
import 'package:kh_admin/features/moderation/model/moderation_filters.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';

class _TestNotifier<TFilters>
    extends CursorPaginatedNotifier<String, TFilters> {
  _TestNotifier({
    required this.initialFilters,
    required this.onFetch,
  });

  @override
  final TFilters initialFilters;

  final Future<Paginated<String>> Function(TFilters filters, String? cursor)
      onFetch;

  int fetchCount = 0;

  @override
  Future<Paginated<String>> fetchPage({
    required TFilters filters,
    String? cursor,
    int limit = 50,
  }) {
    fetchCount++;
    return onFetch(filters, cursor);
  }
}

void main() {
  group('Filter Rebuild Skip (TR-S1-20)', () {
    test('CustomerListFilters: identical filter is a no-op', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      late _TestNotifier<CustomerListFilters> notifier;
      final provider = NotifierProvider<
          _TestNotifier<CustomerListFilters>,
          CursorListState<String, CustomerListFilters>>(() {
        notifier = _TestNotifier<CustomerListFilters>(
          initialFilters: const CustomerListFilters(
            query: 'alice',
            accountState: CustomerAccountState.active,
          ),
          onFetch: (filters, cursor) async => const Paginated(
            items: ['customer-1'],
            nextCursor: null,
          ),
        );
        return notifier;
      });

      container.read(provider);
      await pumpEventQueue();
      expect(notifier.fetchCount, 1);

      // Re-apply identical filter (by value)
      await notifier.applyFilters(
        const CustomerListFilters(
          query: 'alice',
          accountState: CustomerAccountState.active,
        ),
      );
      await pumpEventQueue();
      expect(notifier.fetchCount, 1,
          reason: 'Identical filter must skip re-fetch');

      // Apply modified filter
      await notifier.applyFilters(
        const CustomerListFilters(
          query: 'bob',
          accountState: CustomerAccountState.active,
        ),
      );
      await pumpEventQueue();
      expect(notifier.fetchCount, 2,
          reason: 'Different filter must trigger re-fetch');
    });

    test('AbuseReportFilters: value equality and rebuild skip', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const f1 = AbuseReportFilters(
        state: AbuseReportState.underReview,
        entityType: AbuseEntityType.vendor,
        query: 'fraud',
      );
      const f2 = AbuseReportFilters(
        state: AbuseReportState.underReview,
        entityType: AbuseEntityType.vendor,
        query: 'fraud',
      );
      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));

      late _TestNotifier<AbuseReportFilters> notifier;
      final provider = NotifierProvider<
          _TestNotifier<AbuseReportFilters>,
          CursorListState<String, AbuseReportFilters>>(() {
        notifier = _TestNotifier<AbuseReportFilters>(
          initialFilters: f1,
          onFetch: (filters, cursor) async => const Paginated(
            items: ['abuse-1'],
            nextCursor: null,
          ),
        );
        return notifier;
      });

      container.read(provider);
      await pumpEventQueue();
      expect(notifier.fetchCount, 1);

      await notifier.applyFilters(f2);
      await pumpEventQueue();
      expect(notifier.fetchCount, 1);

      await notifier.applyFilters(f1.copyWith(clearState: true));
      await pumpEventQueue();
      expect(notifier.fetchCount, 2);
    });

    test('ModerationFilters: value equality and rebuild skip', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const f1 = ModerationFilters(
        state: ReviewState.pendingModeration,
        authorType: AuthorType.vendor,
        query: 'test',
      );
      const f2 = ModerationFilters(
        state: ReviewState.pendingModeration,
        authorType: AuthorType.vendor,
        query: 'test',
      );
      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));

      late _TestNotifier<ModerationFilters> notifier;
      final provider = NotifierProvider<
          _TestNotifier<ModerationFilters>,
          CursorListState<String, ModerationFilters>>(() {
        notifier = _TestNotifier<ModerationFilters>(
          initialFilters: f1,
          onFetch: (filters, cursor) async => const Paginated(
            items: ['mod-1'],
            nextCursor: null,
          ),
        );
        return notifier;
      });

      container.read(provider);
      await pumpEventQueue();
      expect(notifier.fetchCount, 1);

      await notifier.applyFilters(f2);
      await pumpEventQueue();
      expect(notifier.fetchCount, 1);
    });

    test('AnnouncementFilters: value equality and rebuild skip', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const f1 = AnnouncementFilters(
        status: AnnouncementStatus.scheduled,
        audienceType: AudienceType.vendors,
        query: 'promo',
      );
      const f2 = AnnouncementFilters(
        status: AnnouncementStatus.scheduled,
        audienceType: AudienceType.vendors,
        query: 'promo',
      );
      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));

      late _TestNotifier<AnnouncementFilters> notifier;
      final provider = NotifierProvider<
          _TestNotifier<AnnouncementFilters>,
          CursorListState<String, AnnouncementFilters>>(() {
        notifier = _TestNotifier<AnnouncementFilters>(
          initialFilters: f1,
          onFetch: (filters, cursor) async => const Paginated(
            items: ['ann-1'],
            nextCursor: null,
          ),
        );
        return notifier;
      });

      container.read(provider);
      await pumpEventQueue();
      expect(notifier.fetchCount, 1);

      await notifier.applyFilters(f2);
      await pumpEventQueue();
      expect(notifier.fetchCount, 1);
    });

    test('ReportFilters: value equality and rebuild skip', () async {
      final now = DateTime.utc(2026, 9, 9);
      final f1 = ReportFilters(
        from: DateTime.utc(2026, 9, 1),
        to: now,
        regionId: 'reg-1',
        categoryId: 'cat-1',
      );
      final f2 = ReportFilters(
        from: DateTime.utc(2026, 9, 1),
        to: now,
        regionId: 'reg-1',
        categoryId: 'cat-1',
      );
      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
    });
  });
}

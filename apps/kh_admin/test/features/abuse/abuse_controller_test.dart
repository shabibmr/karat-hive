import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/abuse/controller/abuse_controller.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_filters.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_item.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_page.dart';
import 'package:kh_admin/features/abuse/repository/abuse_repository.dart';

class _MockAbuseRepository extends AbuseRepository {
  _MockAbuseRepository() : super(ApiClient());

  AbuseReportFilters? lastFilters;
  String? lastCursor;
  int fetchCount = 0;
  String? resolvedId;
  String? resolvedRationale;
  String? dismissedId;
  String? dismissedRationale;

  @override
  Future<AbuseReportPage> fetchAbuseReports({
    AbuseReportFilters filters = const AbuseReportFilters(),
    String? cursor,
    int limit = AbuseRepository.defaultLimit,
  }) async {
    fetchCount++;
    lastFilters = filters;
    lastCursor = cursor;

    return AbuseReportPage(
      items: [
        AbuseReportItem(
          id: 'ab-1',
          reporterUserId: 'user-1',
          reportedUserId: 'user-2',
          entityType: AbuseEntityType.vendor,
          entityId: 'ven-1',
          category: 'SCAM',
          description: 'Off-platform deal request',
          state: AbuseReportState.open,
          createdAt: DateTime(2026, 9, 1, 10, 0),
        ),
      ],
      nextCursor: null,
      hasMore: false,
    );
  }

  @override
  Future<void> resolveAbuseReport(String id, {required String resolution}) async {
    resolvedId = id;
    resolvedRationale = resolution;
  }

  @override
  Future<void> dismissAbuseReport(String id, {required String resolution}) async {
    dismissedId = id;
    dismissedRationale = resolution;
  }
}

Future<void> _settle(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!container.read(abuseListControllerProvider).isLoading) return;
  }
  fail('AbuseListController did not finish loading');
}

void main() {
  late ProviderContainer container;
  late _MockAbuseRepository mockRepository;

  setUp(() {
    mockRepository = _MockAbuseRepository();
    container = ProviderContainer(
      overrides: [
        abuseRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AbuseListController', () {
    test('initializes and loads items', () async {
      await _settle(container);

      final state = container.read(abuseListControllerProvider);
      expect(state.isLoading, false);
      expect(state.items.length, 1);
      expect(state.items.first.id, 'ab-1');
    });

    test('updates state filter and triggers reload', () async {
      await _settle(container);

      final controller = container.read(abuseListControllerProvider.notifier);
      controller.setStateFilter(AbuseReportState.resolved);
      await _settle(container);

      expect(mockRepository.lastFilters?.state, AbuseReportState.resolved);
      expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
    });

    test('resolves report successfully', () async {
      await _settle(container);

      final controller = container.read(abuseListControllerProvider.notifier);
      final success = await controller.resolveReport('ab-1', 'Vendor suspended');
      await _settle(container);

      expect(success, true);
      expect(mockRepository.resolvedId, 'ab-1');
      expect(mockRepository.resolvedRationale, 'Vendor suspended');
    });

    test('dismisses report successfully', () async {
      await _settle(container);

      final controller = container.read(abuseListControllerProvider.notifier);
      final success = await controller.dismissReport('ab-1', 'Invalid report');
      await _settle(container);

      expect(success, true);
      expect(mockRepository.dismissedId, 'ab-1');
      expect(mockRepository.dismissedRationale, 'Invalid report');
    });
  });
}

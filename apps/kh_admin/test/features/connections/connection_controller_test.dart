import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/connections/controller/connection_detail_controller.dart';
import 'package:kh_admin/features/connections/controller/connection_list_controller.dart';
import 'package:kh_admin/features/connections/model/connection_detail.dart';
import 'package:kh_admin/features/connections/model/connection_enums.dart';
import 'package:kh_admin/features/connections/model/connection_list_filters.dart';
import 'package:kh_admin/features/connections/model/connection_list_item.dart';
import 'package:kh_admin/features/connections/model/connection_list_page.dart';
import 'package:kh_admin/features/connections/repository/connection_repository.dart';

class _MockConnectionRepository extends ConnectionRepository {
  _MockConnectionRepository() : super(ApiClient());

  ConnectionListFilters? lastFilters;
  String? lastCursor;
  bool shouldFail = false;
  int fetchCount = 0;
  String? closedConnectionId;
  String? closedReason;
  String? createdNoteText;

  ConnectionListItem _item(String id, ConnectionState state) => ConnectionListItem(
        id: id,
        requestId: 'req-$id',
        offerId: 'off-$id',
        requestType: 'FIND_ORNAMENT',
        customerName: 'Customer $id',
        vendorName: 'Vendor $id',
        agreedPriceAed: 15000.0,
        state: state,
        createdAt: DateTime(2026, 9, 1, 10, 0),
        contactEventsCount: 1,
        lastContactAt: DateTime(2026, 9, 1, 12, 0),
      );

  @override
  Future<ConnectionListPage> fetchConnections({
    ConnectionListFilters filters = const ConnectionListFilters(),
    String? cursor,
    int limit = ConnectionRepository.defaultPageSize,
  }) async {
    fetchCount++;
    lastFilters = filters;
    lastCursor = cursor;

    if (shouldFail) {
      throw Exception('Connections service unavailable');
    }

    if (cursor == 'cursor-2') {
      return ConnectionListPage(
        items: [_item('conn-3', ConnectionState.closed)],
        nextCursor: null,
        hasMore: false,
      );
    }

    return ConnectionListPage(
      items: [
        _item('conn-1', ConnectionState.active),
        _item('conn-2', ConnectionState.active),
      ],
      nextCursor: 'cursor-2',
      hasMore: true,
    );
  }

  @override
  Future<ConnectionDetail> fetchConnectionDetail(String connectionId) async {
    if (shouldFail) {
      throw Exception('Failed to load connection detail');
    }

    return ConnectionDetail(
      id: connectionId,
      state: closedConnectionId == connectionId ? ConnectionState.closed : ConnectionState.active,
      createdAt: DateTime(2026, 9, 1, 10, 0),
      customer: const ConnectionCustomerInfo(
        id: 'cust-1',
        displayName: 'Amina Al Qasimi',
        email: 'amina@example.ae',
      ),
      vendor: const ConnectionVendorInfo(
        id: 'ven-1',
        legalBusinessName: 'Malabar Gold LLC',
      ),
      offer: const ConnectionOfferSummary(
        id: 'off-1',
        agreedPriceAed: 15000.0,
      ),
      request: const ConnectionRequestSummary(
        id: 'req-1',
        requestType: 'FIND_ORNAMENT',
      ),
      contactEvents: [
        ConnectionContactEvent(
          id: 'ce-1',
          channel: 'WHATSAPP',
          initiatedBy: 'CUSTOMER',
          occurredAt: DateTime(2026, 9, 1, 12, 0),
        ),
      ],
      adminNotes: [
        ConnectionAdminNote(
          id: 'note-1',
          author: 'Admin',
          text: 'Initial review complete',
          createdAt: DateTime(2026, 9, 1, 14, 0),
        ),
      ],
    );
  }

  @override
  Future<void> closeConnection(String connectionId, {required String reasonText}) async {
    closedConnectionId = connectionId;
    closedReason = reasonText;
  }

  @override
  Future<ConnectionAdminNote> createAdminNote(String connectionId, String text) async {
    createdNoteText = text;
    return ConnectionAdminNote(
      id: 'note-new',
      author: 'Admin',
      text: text,
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  late ProviderContainer container;
  late _MockConnectionRepository mockRepository;

  setUp(() {
    mockRepository = _MockConnectionRepository();
    container = ProviderContainer(
      overrides: [
        connectionRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('ConnectionListController', () {
    test('loads the first page on build', () async {
      await _settle(container);

      final state = container.read(connectionListControllerProvider);
      expect(state.items, hasLength(2));
      expect(state.items.first.id, 'conn-1');
      expect(state.canLoadMore, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.page, 1);
    });

    test('setStateFilter re-fetches with the new state filter', () async {
      await _settle(container);

      final controller = container.read(connectionListControllerProvider.notifier);
      await controller.setStateFilter(ConnectionState.closed);

      expect(mockRepository.lastFilters?.state, ConnectionState.closed);
      expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
    });

    test('nextPage advances cursor and updates page number', () async {
      await _settle(container);

      final controller = container.read(connectionListControllerProvider.notifier);
      await controller.nextPage();

      final state = container.read(connectionListControllerProvider);
      expect(mockRepository.lastCursor, 'cursor-2');
      expect(state.items.map((e) => e.id), ['conn-3']);
      expect(state.page, 2);
      expect(state.canGoPrevious, isTrue);
    });

    test('previousPage navigates back to previous page in history', () async {
      await _settle(container);

      final controller = container.read(connectionListControllerProvider.notifier);
      await controller.nextPage();
      expect(container.read(connectionListControllerProvider).page, 2);

      await controller.previousPage();
      final state = container.read(connectionListControllerProvider);
      expect(state.page, 1);
      expect(mockRepository.lastCursor, isNull);
    });

    test('surfaces fetch errors cleanly', () async {
      mockRepository.shouldFail = true;

      await _settle(container);

      final state = container.read(connectionListControllerProvider);
      expect(state.items, isEmpty);
      expect(state.error, contains('Connections service unavailable'));
    });
  });

  group('ConnectionDetailController', () {
    test('loads connection detail with parties, request, offer, and notes', () async {
      final detail = await container.read(connectionDetailControllerProvider('conn-100').future);

      expect(detail.id, 'conn-100');
      expect(detail.customer?.displayName, 'Amina Al Qasimi');
      expect(detail.vendor?.legalBusinessName, 'Malabar Gold LLC');
      expect(detail.state, ConnectionState.active);
      expect(detail.contactEvents, hasLength(1));
      expect(detail.adminNotes, hasLength(1));
    });

    test('addAdminNote calls repo and updates state with new note', () async {
      final controller = container.read(connectionDetailControllerProvider('conn-100').notifier);
      await container.read(connectionDetailControllerProvider('conn-100').future);

      await controller.addAdminNote('Followed up with vendor regarding SLA.');

      expect(mockRepository.createdNoteText, 'Followed up with vendor regarding SLA.');
      final currentDetail = container.read(connectionDetailControllerProvider('conn-100')).value;
      expect(currentDetail?.adminNotes, hasLength(2));
      expect(currentDetail?.adminNotes.last.text, 'Followed up with vendor regarding SLA.');
    });

    test('closeConnection calls repo and updates state to closed', () async {
      final controller = container.read(connectionDetailControllerProvider('conn-100').notifier);
      await container.read(connectionDetailControllerProvider('conn-100').future);

      await controller.closeConnection(reasonText: 'Customer unresponsive for 7 days');

      expect(mockRepository.closedConnectionId, 'conn-100');
      expect(mockRepository.closedReason, 'Customer unresponsive for 7 days');

      final currentDetail = container.read(connectionDetailControllerProvider('conn-100')).value;
      expect(currentDetail?.state, ConnectionState.closed);
    });
  });
}

Future<void> _settle(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!container.read(connectionListControllerProvider).isLoading) return;
  }
  fail('ConnectionListController did not finish loading');
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/requests/controller/request_list_controller.dart';
import 'package:kh_admin/features/requests/model/request_enums.dart';
import 'package:kh_admin/features/requests/model/request_list_filters.dart';
import 'package:kh_admin/features/requests/model/request_list_item.dart';
import 'package:kh_admin/features/requests/model/request_list_page.dart';
import 'package:kh_admin/features/requests/repository/request_repository.dart';

class _MockRequestRepository extends RequestRepository {
  _MockRequestRepository() : super(ApiClient());

  RequestListFilters? lastFilters;
  String? lastCursor;
  bool shouldFail = false;
  int fetchCount = 0;

  final List<RequestListItem> pageOne = const [
    RequestListItem(
      id: 'req-1',
      reference: 'KH-REQ-1001',
      requestType: RequestType.findOrnament,
      direction: Direction.buy,
      state: RequestState.published,
      customerName: 'Aisha Rahman',
      customerPhone: '+971501234567',
      offerCount: 0,
    ),
    RequestListItem(
      id: 'req-2',
      reference: 'KH-REQ-1002',
      requestType: RequestType.sellOldGold,
      direction: Direction.sell,
      state: RequestState.offersReceived,
      customerName: 'Omar Farouk',
      offerCount: 3,
    ),
  ];

  final List<RequestListItem> pageTwo = const [
    RequestListItem(
      id: 'req-3',
      reference: 'KH-REQ-1003',
      requestType: RequestType.goldCoin,
      direction: Direction.buy,
      state: RequestState.published,
      customerName: 'Layla Hassan',
      offerCount: 0,
    ),
  ];

  @override
  Future<RequestListPage> fetchRequests({
    RequestListFilters filters = const RequestListFilters(),
    String? cursor,
    int limit = RequestRepository.defaultPageSize,
  }) async {
    fetchCount++;
    lastFilters = filters;
    lastCursor = cursor;

    if (shouldFail) {
      throw Exception('Request service unavailable');
    }

    if (cursor == 'cursor-2') {
      return RequestListPage(items: pageTwo);
    }

    return RequestListPage(
      items: pageOne,
      nextCursor: 'cursor-2',
    );
  }
}

void main() {
  late ProviderContainer container;
  late _MockRequestRepository repository;

  setUp(() {
    repository = _MockRequestRepository();
    container = ProviderContainer(
      overrides: [
        requestRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('loads the first page on build', () async {
    await _settle(container);

    final state = container.read(requestListControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.items.length, 2);
    expect(state.items.first.customerName, 'Aisha Rahman');
    expect(state.items.first.customerPhone, '+971501234567');
    expect(state.canLoadMore, isTrue);
  });

  test('paginates with the next cursor', () async {
    await _settle(container);

    await container.read(requestListControllerProvider.notifier).nextPage();

    expect(repository.lastCursor, 'cursor-2');
    final state = container.read(requestListControllerProvider);
    expect(state.page, 2);
    expect(state.canLoadMore, isFalse);
  });

  test('applyFilters forwards the state filter and refetches', () async {
    await _settle(container);

    await container.read(requestListControllerProvider.notifier).applyFilters(
          const RequestListFilters(state: RequestState.published),
        );

    expect(repository.lastFilters?.state, RequestState.published);
    expect(repository.fetchCount, greaterThanOrEqualTo(2));
  });

  test('toggleZeroOffers stores the client-side filter flag', () async {
    await _settle(container);

    await container
        .read(requestListControllerProvider.notifier)
        .toggleZeroOffers(true);

    expect(repository.lastFilters?.zeroOffersOnly, isTrue);
  });

  test('surfaces fetch errors', () async {
    repository.shouldFail = true;

    await _settle(container);

    final state = container.read(requestListControllerProvider);
    expect(state.items, isEmpty);
    expect(state.error, contains('Request service unavailable'));
  });
}

Future<void> _settle(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!container.read(requestListControllerProvider).isLoading) return;
  }
  fail('RequestListController did not finish loading');
}

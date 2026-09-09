import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/offers/controller/offer_list_controller.dart';
import 'package:kh_admin/features/offers/model/offer_enums.dart';
import 'package:kh_admin/features/offers/model/offer_list_filters.dart';
import 'package:kh_admin/features/offers/model/offer_list_item.dart';
import 'package:kh_admin/features/offers/model/offer_list_page.dart';
import 'package:kh_admin/features/offers/repository/offer_repository.dart';

class _MockOfferRepository extends OfferRepository {
  _MockOfferRepository() : super(ApiClient());

  OfferListFilters? lastFilters;
  String? lastCursor;
  bool shouldFail = false;
  int fetchCount = 0;

  OfferListItem _item(String id, OfferState state) => OfferListItem(
        id: id,
        reference: 'OFF-$id',
        requestId: 'req-$id',
        requestReference: 'KH-RQ-$id',
        requestType: RequestType.findOrnament,
        vendorId: 'ven-$id',
        vendorName: 'Al Noor Jewellery LLC',
        offeredPrice: 14850.0,
        state: state,
        submittedAt: DateTime(2026, 8, 10, 5, 12),
      );

  @override
  Future<OfferListPage> fetchOffers({
    OfferListFilters filters = const OfferListFilters(),
    String? cursor,
    int limit = OfferRepository.defaultPageSize,
  }) async {
    fetchCount++;
    lastFilters = filters;
    lastCursor = cursor;

    if (shouldFail) {
      throw Exception('Offers service unavailable');
    }

    if (cursor == 'cursor-2') {
      return OfferListPage(
        items: [_item('off-3', OfferState.expired)],
      );
    }

    return OfferListPage(
      items: [
        _item('off-1', OfferState.pending),
        _item('off-2', OfferState.accepted),
      ],
      nextCursor: 'cursor-2',
    );
  }
}

void main() {
  late ProviderContainer container;
  late _MockOfferRepository mockRepository;

  setUp(() {
    mockRepository = _MockOfferRepository();
    container = ProviderContainer(
      overrides: [
        offerRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('loads the first page on build', () async {
    await _settle(container);

    final state = container.read(offerListControllerProvider);
    expect(state.items, hasLength(2));
    expect(state.items.first.id, 'off-1');
    expect(state.canLoadMore, isTrue);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
  });

  test('applyFilters re-fetches with the new state filter', () async {
    await _settle(container);

    final controller = container.read(offerListControllerProvider.notifier);
    await controller.applyFilters(
      const OfferListFilters(state: OfferState.accepted),
    );

    expect(mockRepository.lastFilters?.state, OfferState.accepted);
    expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
  });

  test('nextPage advances using the lifted cursor', () async {
    await _settle(container);

    final controller = container.read(offerListControllerProvider.notifier);
    await controller.nextPage();

    final state = container.read(offerListControllerProvider);
    expect(mockRepository.lastCursor, 'cursor-2');
    expect(state.items.map((e) => e.id), ['off-3']);
    expect(state.page, 2);
    expect(state.canGoPrevious, isTrue);
  });

  test('surfaces fetch errors', () async {
    mockRepository.shouldFail = true;

    await _settle(container);

    final state = container.read(offerListControllerProvider);
    expect(state.items, isEmpty);
    expect(state.error, contains('Offers service unavailable'));
  });
}

Future<void> _settle(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!container.read(offerListControllerProvider).isLoading) return;
  }
  fail('OfferListController did not finish loading');
}

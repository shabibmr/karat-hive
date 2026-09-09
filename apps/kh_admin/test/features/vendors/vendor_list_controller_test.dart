import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/vendors/controller/vendor_list_controller.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_filters.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_item.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_page.dart';
import 'package:kh_admin/features/vendors/repository/vendor_repository.dart';

class _MockVendorRepository extends VendorRepository {
  _MockVendorRepository() : super(ApiClient());

  VendorListFilters? lastFilters;
  String? lastCursor;
  bool shouldFail = false;
  int fetchCount = 0;

  final List<VendorListItem> pageOne = [
    const VendorListItem(
      id: 'vendor-1',
      legalBusinessName: 'Al Noor Jewellery LLC',
      tradingName: 'Al Noor',
      verificationState: VendorVerificationState.verified,
      accountState: VendorAccountState.active,
    ),
    const VendorListItem(
      id: 'vendor-2',
      legalBusinessName: 'Sharjah Heritage Gold',
      tradingName: 'Heritage',
      verificationState: VendorVerificationState.pendingVerification,
      accountState: VendorAccountState.active,
      waitingHours: 36,
    ),
  ];

  final List<VendorListItem> pageTwo = [
    const VendorListItem(
      id: 'vendor-3',
      legalBusinessName: 'Dubai Gold Crafts',
      tradingName: 'DGC',
      verificationState: VendorVerificationState.verified,
      accountState: VendorAccountState.suspended,
    ),
  ];

  @override
  Future<VendorListPage> fetchVendors({
    VendorListFilters filters = const VendorListFilters(),
    String? cursor,
    int limit = VendorRepository.defaultPageSize,
  }) async {
    fetchCount++;
    lastFilters = filters;
    lastCursor = cursor;

    if (shouldFail) {
      throw Exception('Vendor service unavailable');
    }

    if (cursor == 'page-2') {
      return VendorListPage(items: pageTwo);
    }

    return VendorListPage(
      items: pageOne,
      nextCursor: 'page-2',
    );
  }
}

void main() {
  late ProviderContainer container;
  late _MockVendorRepository mockRepository;

  setUp(() {
    mockRepository = _MockVendorRepository();
    container = ProviderContainer(
      overrides: [
        vendorRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('VendorListController loads first page on build', () async {
    await pumpUntilSettled(container);

    final state = container.read(vendorListControllerProvider);
    expect(state.items.length, 2);
    expect(state.items.first.legalBusinessName, 'Al Noor Jewellery LLC');
    expect(state.canLoadMore, isTrue);
    expect(state.isLoading, isFalse);
  });

  test('VendorListController applies verification filter', () async {
    await pumpUntilSettled(container);

    final controller = container.read(vendorListControllerProvider.notifier);
    await controller.applyFilters(
      const VendorListFilters(
        verificationState: VendorVerificationState.pendingVerification,
      ),
    );

    expect(
      mockRepository.lastFilters?.verificationState,
      VendorVerificationState.pendingVerification,
    );
    expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
  });

  test('VendorListController loads next page with cursor', () async {
    await pumpUntilSettled(container);

    final controller = container.read(vendorListControllerProvider.notifier);
    await controller.loadMore();

    final state = container.read(vendorListControllerProvider);
    expect(state.items.length, 3);
    expect(mockRepository.lastCursor, 'page-2');
    expect(state.canLoadMore, isFalse);
  });

  test('VendorListController surfaces fetch errors', () async {
    mockRepository.shouldFail = true;

    await pumpUntilSettled(container);

    final state = container.read(vendorListControllerProvider);
    expect(state.items, isEmpty);
    expect(state.error, contains('Vendor service unavailable'));
  });
}

Future<void> pumpUntilSettled(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final state = container.read(vendorListControllerProvider);
    if (!state.isLoading) return;
  }
  fail('VendorListController did not finish loading');
}

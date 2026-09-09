import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/customers/controller/customer_detail_controller.dart';
import 'package:kh_admin/features/customers/controller/customer_list_controller.dart';
import 'package:kh_admin/features/customers/model/customer_detail.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';
import 'package:kh_admin/features/customers/model/customer_list_filters.dart';
import 'package:kh_admin/features/customers/model/customer_list_item.dart';
import 'package:kh_admin/features/customers/model/customer_list_page.dart';
import 'package:kh_admin/features/customers/repository/customer_repository.dart';

class _MockCustomerRepository extends CustomerRepository {
  _MockCustomerRepository() : super(ApiClient());

  CustomerListFilters? lastFilters;
  String? lastCursor;
  int fetchCount = 0;
  bool shouldFailList = false;
  bool shouldFailDetail = false;

  String? lastSuspendedId;
  String? lastSuspendReasonCode;
  String? lastSuspendReasonText;

  String? lastReactivatedId;
  String? lastReactivateReasonText;

  String? lastErasureId;
  String? lastErasureReasonText;

  String? lastNoteCustomerId;
  String? lastNoteText;

  CustomerAccountState currentCustomerState = CustomerAccountState.active;

  final List<CustomerListItem> pageOne = [
    const CustomerListItem(
      id: 'cust-1',
      userId: 'user-1',
      displayName: 'Fatima Al Mansoori',
      email: 'fatima@example.ae',
      mobileNumber: '+971501111111',
      accountState: CustomerAccountState.active,
      requestCount: 4,
    ),
    const CustomerListItem(
      id: 'cust-2',
      userId: 'user-2',
      displayName: 'Rashid Bin Saeed',
      email: 'rashid@example.ae',
      mobileNumber: '+971502222222',
      accountState: CustomerAccountState.suspended,
      requestCount: 1,
    ),
  ];

  final List<CustomerListItem> pageTwo = [
    const CustomerListItem(
      id: 'cust-3',
      userId: 'user-3',
      displayName: 'Zayed Al Nahyan',
      email: 'zayed@example.ae',
      accountState: CustomerAccountState.active,
      requestCount: 0,
    ),
  ];

  @override
  Future<CustomerListPage> fetchCustomers({
    CustomerListFilters filters = const CustomerListFilters(),
    String? cursor,
    int limit = CustomerRepository.defaultPageSize,
  }) async {
    fetchCount++;
    lastFilters = filters;
    lastCursor = cursor;

    if (shouldFailList) {
      throw Exception('Customer service unavailable');
    }

    if (cursor == 'page-2') {
      return CustomerListPage(items: pageTwo, nextCursor: null);
    }

    return CustomerListPage(
      items: pageOne,
      nextCursor: 'page-2',
    );
  }

  @override
  Future<CustomerDetail> fetchCustomerDetail(String customerId) async {
    if (shouldFailDetail) {
      throw Exception('Customer not found');
    }

    return CustomerDetail(
      id: customerId,
      userId: 'user-$customerId',
      displayName: 'Test Customer',
      email: 'test@example.ae',
      mobileNumber: '+971500000000',
      accountState: currentCustomerState,
      defaultRegion: 'Dubai',
      requests: const [
        CustomerRequestSummary(
          id: 'req-1',
          reference: 'KH-101',
          state: 'PUBLISHED',
          requestType: 'FIND_ORNAMENT',
        ),
      ],
      adminNotes: [
        CustomerAdminNote(
          id: 'note-1',
          text: 'Initial KYC completed',
          authorName: 'Admin Omar',
          createdAt: CustomDateHelper.mockDate,
        ),
      ],
    );
  }

  @override
  Future<void> suspendCustomer(
    String customerId, {
    required String reasonCode,
    required String reasonText,
  }) async {
    lastSuspendedId = customerId;
    lastSuspendReasonCode = reasonCode;
    lastSuspendReasonText = reasonText;
    currentCustomerState = CustomerAccountState.suspended;
  }

  @override
  Future<void> reactivateCustomer(
    String customerId, {
    required String reasonText,
  }) async {
    lastReactivatedId = customerId;
    lastReactivateReasonText = reasonText;
    currentCustomerState = CustomerAccountState.active;
  }

  @override
  Future<void> erasureCustomer(
    String customerId, {
    required String reasonText,
  }) async {
    lastErasureId = customerId;
    lastErasureReasonText = reasonText;
    currentCustomerState = CustomerAccountState.deactivated;
  }

  @override
  Future<CustomerAdminNote> createAdminNote(
    String customerId,
    String text,
  ) async {
    lastNoteCustomerId = customerId;
    lastNoteText = text;
    return CustomerAdminNote(
      id: 'note-new',
      text: text,
      authorName: 'Admin Me',
      createdAt: DateTime.now(),
    );
  }
}

class CustomDateHelper {
  static final DateTime mockDate = DateTime.parse('2026-09-01T12:00:00.000Z');
}

Future<void> _pumpUntilSettled(ProviderContainer container) async {
  for (var i = 0; i < 25; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final state = container.read(customerListControllerProvider);
    if (!state.isLoading) return;
  }
  fail('CustomerListController did not settle loading');
}

void main() {
  late ProviderContainer container;
  late _MockCustomerRepository mockRepository;

  setUp(() {
    mockRepository = _MockCustomerRepository();
    container = ProviderContainer(
      overrides: [
        customerRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CustomerListController', () {
    test('loads first page on build', () async {
      await _pumpUntilSettled(container);

      final state = container.read(customerListControllerProvider);
      expect(state.items.length, 2);
      expect(state.items.first.displayName, 'Fatima Al Mansoori');
      expect(state.canLoadMore, isTrue);
      expect(state.canGoNext, isTrue);
      expect(state.canGoPrevious, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.page, 1);
    });

    test('applies account state filter and resets to page 1', () async {
      await _pumpUntilSettled(container);

      final controller = container.read(customerListControllerProvider.notifier);
      await controller.setAccountStateFilter(CustomerAccountState.suspended);

      expect(mockRepository.lastFilters?.accountState, CustomerAccountState.suspended);
      expect(mockRepository.fetchCount, greaterThanOrEqualTo(2));
      final state = container.read(customerListControllerProvider);
      expect(state.page, 1);
    });

    test('updates search query and submits search', () async {
      await _pumpUntilSettled(container);

      final controller = container.read(customerListControllerProvider.notifier);
      controller.setSearchQuery('Fatima');

      final state = container.read(customerListControllerProvider);
      expect(state.filters.query, 'Fatima');

      await controller.submitSearch();
      expect(mockRepository.lastFilters?.query, 'Fatima');
    });

    test('loadMore appends records and updates nextCursor', () async {
      await _pumpUntilSettled(container);

      final controller = container.read(customerListControllerProvider.notifier);
      await controller.loadMore();

      final state = container.read(customerListControllerProvider);
      expect(state.items.length, 3);
      expect(mockRepository.lastCursor, 'page-2');
      expect(state.canLoadMore, isFalse);
    });

    test('nextPage and previousPage navigate pagination correctly', () async {
      await _pumpUntilSettled(container);

      final controller = container.read(customerListControllerProvider.notifier);
      await controller.nextPage();

      var state = container.read(customerListControllerProvider);
      expect(state.page, 2);
      expect(state.items.length, 1);
      expect(state.items.first.displayName, 'Zayed Al Nahyan');
      expect(state.canGoPrevious, isTrue);
      expect(state.canGoNext, isFalse);

      await controller.previousPage();

      state = container.read(customerListControllerProvider);
      expect(state.page, 1);
      expect(state.items.length, 2);
      expect(state.items.first.displayName, 'Fatima Al Mansoori');
      expect(state.canGoPrevious, isFalse);
      expect(state.canGoNext, isTrue);
    });

    test('surfaces fetch errors and handles retry', () async {
      mockRepository.shouldFailList = true;
      await _pumpUntilSettled(container);

      var state = container.read(customerListControllerProvider);
      expect(state.items, isEmpty);
      expect(state.error, contains('Customer service unavailable'));

      mockRepository.shouldFailList = false;
      await container.read(customerListControllerProvider.notifier).refresh();

      state = container.read(customerListControllerProvider);
      expect(state.items.length, 2);
      expect(state.error, isNull);
    });
  });

  group('CustomerDetailController', () {
    test('loads customer detail on build', () async {
      final detail = await container.read(customerDetailControllerProvider('cust-1').future);

      expect(detail.id, 'cust-1');
      expect(detail.displayName, 'Test Customer');
      expect(detail.accountState, CustomerAccountState.active);
      expect(detail.requests.length, 1);
      expect(detail.adminNotes.length, 1);
    });

    test('suspendCustomer calls repo and updates state to suspended', () async {
      final notifier = container.read(customerDetailControllerProvider('cust-1').notifier);
      await container.read(customerDetailControllerProvider('cust-1').future);

      await notifier.suspendCustomer(
        reasonCode: 'ABUSE_SUSPICION',
        reasonText: 'Fraud suspicion verified',
      );

      expect(mockRepository.lastSuspendedId, 'cust-1');
      expect(mockRepository.lastSuspendReasonCode, 'ABUSE_SUSPICION');
      expect(mockRepository.lastSuspendReasonText, 'Fraud suspicion verified');

      final updatedState = container.read(customerDetailControllerProvider('cust-1')).value;
      expect(updatedState?.accountState, CustomerAccountState.suspended);
    });

    test('reactivateCustomer calls repo and restores state to active', () async {
      mockRepository.currentCustomerState = CustomerAccountState.suspended;
      final notifier = container.read(customerDetailControllerProvider('cust-1').notifier);
      await container.read(customerDetailControllerProvider('cust-1').future);

      await notifier.reactivateCustomer(
        reasonText: 'Customer ID verification completed in branch',
      );

      expect(mockRepository.lastReactivatedId, 'cust-1');
      expect(mockRepository.lastReactivateReasonText, 'Customer ID verification completed in branch');

      final updatedState = container.read(customerDetailControllerProvider('cust-1')).value;
      expect(updatedState?.accountState, CustomerAccountState.active);
    });

    test('erasureCustomer calls repo and sets state to deactivated', () async {
      final notifier = container.read(customerDetailControllerProvider('cust-1').notifier);
      await container.read(customerDetailControllerProvider('cust-1').future);

      await notifier.erasureCustomer(
        reasonText: 'Customer requested PDPL erasure',
      );

      expect(mockRepository.lastErasureId, 'cust-1');
      expect(mockRepository.lastErasureReasonText, 'Customer requested PDPL erasure');
      final updatedState = container.read(customerDetailControllerProvider('cust-1')).value;
      expect(updatedState?.accountState, CustomerAccountState.deactivated);
    });

    test('addAdminNote calls repo and prepends new note to state', () async {
      final notifier = container.read(customerDetailControllerProvider('cust-1').notifier);
      await container.read(customerDetailControllerProvider('cust-1').future);

      await notifier.addAdminNote('Called customer regarding request #101');

      expect(mockRepository.lastNoteCustomerId, 'cust-1');
      expect(mockRepository.lastNoteText, 'Called customer regarding request #101');

      final updatedState = container.read(customerDetailControllerProvider('cust-1')).value;
      expect(updatedState?.adminNotes.length, 2);
      expect(updatedState?.adminNotes.first.id, 'note-new');
      expect(updatedState?.adminNotes.first.text, 'Called customer regarding request #101');
    });
  });
}

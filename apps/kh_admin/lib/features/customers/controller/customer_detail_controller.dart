import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/customer_detail.dart';
import '../repository/customer_repository.dart';

/// Riverpod family notifier managing Customer Detail view and actions (ADM-S04).
class CustomerDetailController
    extends FamilyAsyncNotifier<CustomerDetail, String> {
  @override
  Future<CustomerDetail> build(String arg) async {
    final repository = ref.watch(customerRepositoryProvider);
    return repository.fetchCustomerDetail(arg);
  }

  /// Reloads the customer record from the backend.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(customerRepositoryProvider);
      return repository.fetchCustomerDetail(arg);
    });
  }

  /// Suspends the customer account with an audited reason code and text.
  Future<void> suspendCustomer({
    required String reasonCode,
    required String reasonText,
  }) async {
    final repository = ref.read(customerRepositoryProvider);
    await repository.suspendCustomer(
      arg,
      reasonCode: reasonCode,
      reasonText: reasonText,
    );
    await reload();
  }

  /// Reactivates a suspended customer account with an explanation.
  Future<void> reactivateCustomer({
    required String reasonText,
  }) async {
    final repository = ref.read(customerRepositoryProvider);
    await repository.reactivateCustomer(
      arg,
      reasonText: reasonText,
    );
    await reload();
  }

  /// Triggers permanent PII erasure for this customer (FR-CUS-004).
  Future<void> erasureCustomer({required String reasonText}) async {
    final repository = ref.read(customerRepositoryProvider);
    await repository.erasureCustomer(arg, reasonText: reasonText);
    await reload();
  }

  /// Appends an admin internal note to this customer record.
  Future<void> addAdminNote(String text) async {
    final repository = ref.read(customerRepositoryProvider);
    final newNote = await repository.createAdminNote(arg, text);
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(adminNotes: [newNote, ...current.adminNotes]),
      );
    } else {
      await reload();
    }
  }
}

/// Provider family for [CustomerDetailController] indexed by customerId.
final customerDetailControllerProvider =
    AsyncNotifierProvider.family<CustomerDetailController, CustomerDetail, String>(
  CustomerDetailController.new,
);

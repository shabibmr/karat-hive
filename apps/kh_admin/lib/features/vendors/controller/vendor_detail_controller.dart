import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/vendor_detail.dart';
import '../repository/vendor_repository.dart';

/// Riverpod family notifier managing full vendor profile inspection and admin lifecycle actions (ADM-S06).
class VendorDetailController
    extends FamilyAsyncNotifier<VendorDetail, String> {
  @override
  Future<VendorDetail> build(String arg) async {
    final repository = ref.watch(vendorRepositoryProvider);
    return repository.fetchVendorDetail(arg);
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(vendorRepositoryProvider);
      return repository.fetchVendorDetail(arg);
    });
  }

  Future<void> suspendVendor({
    required String reasonCode,
    required String reasonText,
  }) async {
    final repository = ref.read(vendorRepositoryProvider);
    await repository.suspendVendor(
      arg,
      reasonCode: reasonCode,
      reasonText: reasonText,
    );
    await reload();
  }

  Future<void> reactivateVendor({
    String reasonCode = 'ADMIN_REACTIVATED',
    String reasonText = 'KYC verified',
  }) async {
    final repository = ref.read(vendorRepositoryProvider);
    await repository.reactivateVendor(
      arg,
      reasonCode: reasonCode,
      reasonText: reasonText,
    );
    await reload();
  }

  Future<void> deactivateVendor({
    required String reasonCode,
    required String reasonText,
  }) async {
    final repository = ref.read(vendorRepositoryProvider);
    await repository.deactivateVendor(
      arg,
      reasonCode: reasonCode,
      reasonText: reasonText,
    );
    await reload();
  }
}

final vendorDetailControllerProvider =
    AsyncNotifierProvider.family<VendorDetailController, VendorDetail, String>(
  VendorDetailController.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/features/verification/model/verification_decision_dto.dart';
import 'package:kh_admin/features/verification/model/verification_queue_item.dart';
import 'package:kh_admin/features/verification/model/vendor_verification_detail.dart';
import 'package:kh_admin/features/verification/repository/verification_repository.dart';

/// Riverpod [AsyncNotifier] managing the verification queue list (ADM-S07).
class VerificationQueueController extends AsyncNotifier<List<VerificationQueueItem>> {
  @override
  Future<List<VerificationQueueItem>> build() async {
    final repository = ref.watch(verificationRepositoryProvider);
    return repository.fetchQueue();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(verificationRepositoryProvider);
      return repository.fetchQueue();
    });
  }

  Future<void> verifyVendor(String vendorId, String rationale) async {
    final repository = ref.read(verificationRepositoryProvider);
    await repository.verifyVendor(
      vendorId,
      VerifyDecisionDto(rationale: rationale),
    );
    await reload();
  }

  Future<void> rejectVendor(String vendorId, String rationale) async {
    final repository = ref.read(verificationRepositoryProvider);
    await repository.rejectVendor(
      vendorId,
      RejectDecisionDto(rationale: rationale),
    );
    await reload();
  }

  Future<void> requestInfo(String vendorId, String message) async {
    final repository = ref.read(verificationRepositoryProvider);
    await repository.requestInfo(
      vendorId,
      RequestInfoDto(message: message),
    );
    await reload();
  }
}

final verificationQueueControllerProvider =
    AsyncNotifierProvider<VerificationQueueController, List<VerificationQueueItem>>(
  VerificationQueueController.new,
);

/// Riverpod family notifier for the selected vendor's review detail.
class VerificationDetailController
    extends FamilyAsyncNotifier<VendorVerificationDetail, String> {
  @override
  Future<VendorVerificationDetail> build(String arg) async {
    final repository = ref.watch(verificationRepositoryProvider);
    return repository.fetchVendorDetail(arg);
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(verificationRepositoryProvider);
      return repository.fetchVendorDetail(arg);
    });
  }
}

final verificationDetailControllerProvider = AsyncNotifierProvider.family<
    VerificationDetailController,
    VendorVerificationDetail,
    String>(
  VerificationDetailController.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/request_detail.dart';
import '../repository/request_repository.dart';

/// Riverpod family async notifier managing request inspection and admin actions (ADM-S09).
class RequestDetailController extends FamilyAsyncNotifier<RequestDetail, String> {
  @override
  Future<RequestDetail> build(String arg) async {
    final repository = ref.watch(requestRepositoryProvider);
    return repository.fetchRequestDetail(arg);
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(requestRepositoryProvider);
      return repository.fetchRequestDetail(arg);
    });
  }

  /// Administratively removes the request for a policy violation (FR-ADM-019).
  Future<void> removeRequest({
    required String reasonCode,
    required String reasonText,
    String? policyClause,
  }) async {
    final repository = ref.read(requestRepositoryProvider);
    await repository.removeRequest(
      arg,
      reasonCode: reasonCode,
      reasonText: reasonText,
      policyClause: policyClause,
    );
    await reload();
  }

  /// Appends an admin internal note.
  Future<void> addNote({required String text}) async {
    final repository = ref.read(requestRepositoryProvider);
    await repository.addNote(arg, text: text);
    await reload();
  }
}

final requestDetailControllerProvider =
    AsyncNotifierProvider.family<RequestDetailController, RequestDetail, String>(
  RequestDetailController.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/features/connections/model/connection_detail.dart';
import 'package:kh_admin/features/connections/repository/connection_repository.dart';

/// Riverpod family notifier managing connection inspection, closing, and admin notes (ADM-S13).
class ConnectionDetailController
    extends FamilyAsyncNotifier<ConnectionDetail, String> {
  @override
  Future<ConnectionDetail> build(String arg) async {
    final repository = ref.watch(connectionRepositoryProvider);
    return repository.fetchConnectionDetail(arg);
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(connectionRepositoryProvider);
      return repository.fetchConnectionDetail(arg);
    });
  }

  Future<void> closeConnection({required String reasonText}) async {
    final repository = ref.read(connectionRepositoryProvider);
    await repository.closeConnection(arg, reasonText: reasonText);
    await reload();
  }

  Future<void> addAdminNote(String text) async {
    final repository = ref.read(connectionRepositoryProvider);
    final newNote = await repository.createAdminNote(arg, text);

    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(
          adminNotes: [...current.adminNotes, newNote],
        ),
      );
    } else {
      await reload();
    }
  }
}

final connectionDetailControllerProvider =
    AsyncNotifierProvider.family<ConnectionDetailController, ConnectionDetail, String>(
  ConnectionDetailController.new,
);

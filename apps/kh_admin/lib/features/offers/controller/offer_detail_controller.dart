import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/repository/offer_repository.dart';

/// Riverpod family notifier managing offer inspection and adding admin notes (ADM-S11).
class OfferDetailController
    extends FamilyAsyncNotifier<OfferDetail, String> {
  @override
  Future<OfferDetail> build(String arg) async {
    final repository = ref.watch(offerRepositoryProvider);
    return repository.fetchOfferDetail(arg);
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(offerRepositoryProvider);
      return repository.fetchOfferDetail(arg);
    });
  }

  Future<void> addInternalNote(String text) async {
    final repository = ref.read(offerRepositoryProvider);
    final newNote = await repository.addNote(arg, note: text);

    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(
          internalNotes: [...current.internalNotes, newNote],
        ),
      );
    } else {
      await reload();
    }
  }
}

final offerDetailControllerProvider =
    AsyncNotifierProvider.family<OfferDetailController, OfferDetail, String>(
  OfferDetailController.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/offers_customer_repository.dart';

class OfferDetailBundle {
  const OfferDetailBundle({required this.offer, this.rating});

  final OfferForCustomer offer;
  final VendorRatingDetail? rating;
}

class OfferDetailController
    extends AutoDisposeFamilyAsyncNotifier<OfferDetailBundle, String> {
  @override
  Future<OfferDetailBundle> build(String arg) async {
    final repo = ref.watch(offersCustomerRepositoryProvider);
    final offerRes = await repo.get(arg);
    final offer = offerRes.when(ok: (o) => o, err: (f) => throw f);
    final ratingRes = await repo.vendorRating(arg);
    final rating = ratingRes.when(ok: (r) => r, err: (_) => null);
    return OfferDetailBundle(offer: offer, rating: rating);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }

  Future<Result<OfferForCustomer>> decline({String? reason, String? note}) {
    return ref.read(offersCustomerRepositoryProvider).decline(
          arg,
          reason: reason,
          note: note,
        );
  }
}

final offerDetailProvider = AsyncNotifierProvider.autoDispose
    .family<OfferDetailController, OfferDetailBundle, String>(
  OfferDetailController.new,
);

enum AcceptPhase { idle, submitting, succeeded, timedOut, failed }

class AcceptOfferUiState {
  const AcceptOfferUiState({
    this.phase = AcceptPhase.idle,
    this.failure,
    this.connectionId,
  });

  final AcceptPhase phase;
  final Failure? failure;
  final String? connectionId;

  bool get confirmLocked =>
      phase == AcceptPhase.submitting || phase == AcceptPhase.succeeded;
}

class AcceptOfferController extends AutoDisposeFamilyNotifier<AcceptOfferUiState, String> {
  @override
  AcceptOfferUiState build(String arg) => const AcceptOfferUiState();

  Future<void> confirm() async {
    if (state.confirmLocked) return;
    state = const AcceptOfferUiState(phase: AcceptPhase.submitting);
    final repo = ref.read(offersCustomerRepositoryProvider);
    final res = await repo.accept(arg);
    res.when(
      ok: (result) {
        state = AcceptOfferUiState(
          phase: AcceptPhase.succeeded,
          connectionId: result.connection.id,
        );
      },
      err: (f) {
        if (f is TimeoutFailure) {
          state = AcceptOfferUiState(phase: AcceptPhase.timedOut, failure: f);
        } else {
          state = AcceptOfferUiState(phase: AcceptPhase.failed, failure: f);
        }
      },
    );
  }
}

final acceptOfferProvider = AutoDisposeNotifierProvider.family<
    AcceptOfferController, AcceptOfferUiState, String>(
  AcceptOfferController.new,
);

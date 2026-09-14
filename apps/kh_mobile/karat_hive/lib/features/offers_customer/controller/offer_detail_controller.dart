import 'dart:math';

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
    this.idempotencyKey,
  });

  final AcceptPhase phase;
  final Failure? failure;
  final String? connectionId;
  final String? idempotencyKey;

  /// Locked while in-flight, after success, or after timeout (check status).
  bool get confirmLocked =>
      phase == AcceptPhase.submitting ||
      phase == AcceptPhase.succeeded ||
      phase == AcceptPhase.timedOut;
}

class AcceptOfferController
    extends AutoDisposeFamilyNotifier<AcceptOfferUiState, String> {
  @override
  AcceptOfferUiState build(String arg) => const AcceptOfferUiState();

  String _ensureKey() {
    final existing = state.idempotencyKey;
    if (existing != null && existing.isNotEmpty) return existing;
    final key = _uuid();
    state = AcceptOfferUiState(
      phase: state.phase,
      failure: state.failure,
      connectionId: state.connectionId,
      idempotencyKey: key,
    );
    return key;
  }

  Future<void> confirm() async {
    if (state.confirmLocked) return;
    final key = _ensureKey();
    state = AcceptOfferUiState(
      phase: AcceptPhase.submitting,
      idempotencyKey: key,
    );
    final repo = ref.read(offersCustomerRepositoryProvider);
    final res = await repo.accept(arg, idempotencyKey: key);
    res.when(
      ok: (result) {
        state = AcceptOfferUiState(
          phase: AcceptPhase.succeeded,
          connectionId: result.connection.id,
          idempotencyKey: key,
        );
      },
      err: (f) {
        if (f is TimeoutFailure) {
          state = AcceptOfferUiState(
            phase: AcceptPhase.timedOut,
            failure: f,
            idempotencyKey: key,
          );
        } else {
          state = AcceptOfferUiState(
            phase: AcceptPhase.failed,
            failure: f,
            idempotencyKey: key,
          );
        }
      },
    );
  }

  static String _uuid() {
    final rand = Random();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}

final acceptOfferProvider = AutoDisposeNotifierProvider.family<
    AcceptOfferController, AcceptOfferUiState, String>(
  AcceptOfferController.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../repository/offers_vendor_repository.dart';

sealed class ReviseOfferState {
  const ReviseOfferState();
}

class ReviseOfferLoading extends ReviseOfferState {
  const ReviseOfferLoading();
}

class ReviseOfferReady extends ReviseOfferState {
  const ReviseOfferReady({
    required this.offer,
    required this.config,
    required this.draft,
    this.submitting = false,
    this.withdrawing = false,
    this.failure,
  });

  final OfferForVendor offer;
  final PlatformConfig config;
  final OfferTermsDraft draft;
  final bool submitting;
  final bool withdrawing;
  final Failure? failure;

  ReviseOfferReady copyWith({
    OfferForVendor? offer,
    PlatformConfig? config,
    OfferTermsDraft? draft,
    bool? submitting,
    bool? withdrawing,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ReviseOfferReady(
      offer: offer ?? this.offer,
      config: config ?? this.config,
      draft: draft ?? this.draft,
      submitting: submitting ?? this.submitting,
      withdrawing: withdrawing ?? this.withdrawing,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class ReviseOfferFailed extends ReviseOfferState {
  const ReviseOfferFailed(this.failure);
  final Failure failure;
}

class ReviseOfferSucceeded extends ReviseOfferState {
  const ReviseOfferSucceeded(this.offer, {this.withdrawn = false});
  final OfferForVendor offer;
  final bool withdrawn;
}

class ReviseOfferController
    extends AutoDisposeFamilyNotifier<ReviseOfferState, String> {
  @override
  ReviseOfferState build(String offerId) {
    Future.microtask(_load);
    return const ReviseOfferLoading();
  }

  OffersVendorRepository get _repo =>
      ref.read(offersVendorRepositoryProvider);

  Future<void> _load() async {
    final offerResult = await _repo.getOffer(arg);
    final configResult = await _repo.getPlatformConfig();

    final offerFail = offerResult.failureOrNull;
    if (offerFail != null) {
      state = ReviseOfferFailed(offerFail);
      return;
    }
    final configFail = configResult.failureOrNull;
    if (configFail != null) {
      state = ReviseOfferFailed(configFail);
      return;
    }

    final offer = offerResult.valueOrNull!;
    state = ReviseOfferReady(
      offer: offer,
      config: configResult.valueOrNull!,
      draft: OfferTermsDraft.fromTerms(offer.terms),
    );
  }

  void touch() {
    final current = state;
    if (current is ReviseOfferReady) {
      state = current.copyWith(clearFailure: true);
    }
  }

  Future<void> revise() async {
    final current = state;
    if (current is! ReviseOfferReady ||
        current.submitting ||
        current.withdrawing) {
      return;
    }
    if (!current.offer.canRevise) {
      state = current.copyWith(
        failure: const ConflictFailure(
          code: 'OFFER_REVISION_LIMIT',
          message: 'No revisions remaining for this Offer.',
        ),
      );
      return;
    }

    final price = double.tryParse(current.draft.offeredPrice);
    if (price == null || price <= 0) {
      state = current.copyWith(
        failure: const ValidationFailure(message: 'Enter a valid offered price.'),
      );
      return;
    }

    state = current.copyWith(submitting: true, clearFailure: true);
    final result = await _repo.reviseOffer(
      offerId: arg,
      terms: current.draft.toInput(),
    );
    result.when(
      ok: (offer) => state = ReviseOfferSucceeded(offer),
      err: (f) => state = current.copyWith(submitting: false, failure: f),
    );
  }

  Future<void> withdraw() async {
    final current = state;
    if (current is! ReviseOfferReady ||
        current.submitting ||
        current.withdrawing) {
      return;
    }
    if (!current.offer.canWithdraw) {
      state = current.copyWith(
        failure: const ConflictFailure(
          code: 'OFFER_NOT_PENDING',
          message: 'Only a pending Offer can be withdrawn.',
        ),
      );
      return;
    }

    state = current.copyWith(withdrawing: true, clearFailure: true);
    final result = await _repo.withdrawOffer(arg);
    result.when(
      ok: (offer) => state = ReviseOfferSucceeded(offer, withdrawn: true),
      err: (f) => state = current.copyWith(withdrawing: false, failure: f),
    );
  }
}

final reviseOfferControllerProvider = AutoDisposeNotifierProvider.family<
    ReviseOfferController, ReviseOfferState, String>(
  ReviseOfferController.new,
);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/offers_vendor/controller/revise_offer_controller.dart';
import 'package:karat_hive/features/offers_vendor/repository/offers_vendor_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

PlatformConfig _testConfig({
  List<int> offerValidityHours = const [12, 24, 48],
}) =>
    PlatformConfig(offerValidityHours: offerValidityHours);

OfferForVendor _testOffer({
  String id = 'off-1',
  String requestId = 'req-offer-1',
  OfferState state = OfferState.pending,
  int revisionCount = 0,
  String offeredPrice = '5200.00',
  int validityHours = 24,
}) {
  return OfferForVendor(
    id: id,
    requestId: requestId,
    state: state,
    terms: OfferTerms(
      offeredPrice: offeredPrice,
      validityHours: validityHours,
      vendorNote: 'Original note',
    ),
    submittedAt: DateTime.utc(2026, 9, 7, 12, 0),
    expiresAt: DateTime.utc(2026, 9, 8, 12, 0),
    revisionCount: revisionCount,
  );
}

class FakeOffersVendorRepository implements OffersVendorRepository {
  FakeOffersVendorRepository({
    this.offer,
    this.config,
    this.offerError,
    this.configError,
    this.reviseError,
    this.reviseResult,
    this.withdrawError,
    this.withdrawResult,
    this.hangOffer = false,
  });

  final OfferForVendor? offer;
  final PlatformConfig? config;
  final Failure? offerError;
  final Failure? configError;
  final Failure? reviseError;
  final OfferForVendor? reviseResult;
  final Failure? withdrawError;
  final OfferForVendor? withdrawResult;
  final bool hangOffer;

  int getOfferCalls = 0;
  int getConfigCalls = 0;
  int reviseCalls = 0;
  int withdrawCalls = 0;
  OfferTermsInput? lastTerms;
  String? lastReviseOfferId;
  String? lastWithdrawOfferId;

  @override
  Future<Result<PlatformConfig>> getPlatformConfig() async {
    getConfigCalls++;
    if (configError != null) return Err(configError!);
    return Ok(config ?? _testConfig());
  }

  @override
  Future<Result<VendorRequestItem>> getRequest(String requestId) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> getOffer(String offerId) async {
    getOfferCalls++;
    if (hangOffer) await Completer<void>().future;
    if (offerError != null) return Err(offerError!);
    return Ok(offer ?? _testOffer(id: offerId));
  }

  @override
  Future<Result<OfferForVendor>> submitOffer({
    required String requestId,
    required OfferTermsInput terms,
  }) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> reviseOffer({
    required String offerId,
    required OfferTermsInput terms,
  }) async {
    reviseCalls++;
    lastReviseOfferId = offerId;
    lastTerms = terms;
    if (reviseError != null) return Err(reviseError!);
    return Ok(
      reviseResult ??
          _testOffer(id: offerId, revisionCount: 1, offeredPrice: terms.offeredPrice),
    );
  }

  @override
  Future<Result<OfferForVendor>> withdrawOffer(String offerId) async {
    withdrawCalls++;
    lastWithdrawOfferId = offerId;
    if (withdrawError != null) return Err(withdrawError!);
    return Ok(
      withdrawResult ??
          _testOffer(id: offerId, state: OfferState.withdrawn),
    );
  }

  @override
  Future<Result<PagedResult<OfferForVendor>>> listMyOffers({
    required String tab,
    String? requestType,
    DateTime? from,
    DateTime? to,
    String? q,
    String? cursor,
  }) async =>
      const Ok(PagedResult(items: []));
}

Future<ReviseOfferState> _waitUntilSettled(
  ProviderContainer container,
  String offerId,
) async {
  for (var i = 0; i < 50; i++) {
    final state = container.read(reviseOfferControllerProvider(offerId));
    if (state is! ReviseOfferLoading) return state;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  return container.read(reviseOfferControllerProvider(offerId));
}

void main() {
  const offerId = 'off-1';

  ProviderContainer containerWith(FakeOffersVendorRepository repo) {
    final container = ProviderContainer(
      overrides: [
        offersVendorRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(
      reviseOfferControllerProvider(offerId),
      (_, __) {},
    );
    addTearDown(sub.close);
    return container;
  }

  group('ReviseOfferController (VEN-S10)', () {
    test('starts loading then reaches ready with draft from terms (data)',
        () async {
      final repo = FakeOffersVendorRepository(
        offer: _testOffer(),
        config: _testConfig(),
      );
      final container = containerWith(repo);

      expect(
        container.read(reviseOfferControllerProvider(offerId)),
        isA<ReviseOfferLoading>(),
      );

      final state = await _waitUntilSettled(container, offerId);
      expect(state, isA<ReviseOfferReady>());
      final ready = state as ReviseOfferReady;
      expect(ready.offer.id, offerId);
      expect(ready.config.offerValidityHours, [12, 24, 48]);
      expect(ready.draft.offeredPrice, '5200.00');
      expect(ready.draft.validityHours, 24);
      expect(ready.draft.vendorNote, 'Original note');
      expect(ready.submitting, isFalse);
      expect(ready.withdrawing, isFalse);
      expect(ready.failure, isNull);
      expect(repo.getOfferCalls, 1);
      expect(repo.getConfigCalls, 1);
    });

    test('surfaces offer load failure as ReviseOfferFailed (error)', () async {
      final repo = FakeOffersVendorRepository(
        offerError: const NetworkFailure(message: 'offline'),
      );
      final container = containerWith(repo);

      final state = await _waitUntilSettled(container, offerId);
      expect(state, isA<ReviseOfferFailed>());
      expect((state as ReviseOfferFailed).failure.message, 'offline');
    });

    test('surfaces config load failure as ReviseOfferFailed (error)', () async {
      final repo = FakeOffersVendorRepository(
        configError: const ServerFailure(message: 'config unavailable'),
      );
      final container = containerWith(repo);

      final state = await _waitUntilSettled(container, offerId);
      expect(state, isA<ReviseOfferFailed>());
      expect(
        (state as ReviseOfferFailed).failure.message,
        'config unavailable',
      );
    });

    test('revise with empty price keeps ready and sets validation failure',
        () async {
      final repo = FakeOffersVendorRepository();
      final container = containerWith(repo);
      final loaded = await _waitUntilSettled(container, offerId);
      (loaded as ReviseOfferReady).draft.offeredPrice = '';

      await container
          .read(reviseOfferControllerProvider(offerId).notifier)
          .revise();

      final state = container.read(reviseOfferControllerProvider(offerId));
      expect(state, isA<ReviseOfferReady>());
      final ready = state as ReviseOfferReady;
      expect(ready.failure, isA<ValidationFailure>());
      expect(ready.failure!.message, 'Enter a valid offered price.');
      expect(repo.reviseCalls, 0);
    });

    test('revise when revisions exhausted sets conflict without API call (empty)',
        () async {
      final repo = FakeOffersVendorRepository(
        offer: _testOffer(revisionCount: kMaxOfferRevisions),
      );
      final container = containerWith(repo);
      await _waitUntilSettled(container, offerId);

      await container
          .read(reviseOfferControllerProvider(offerId).notifier)
          .revise();

      final state = container.read(reviseOfferControllerProvider(offerId));
      expect(state, isA<ReviseOfferReady>());
      final ready = state as ReviseOfferReady;
      expect(ready.offer.canRevise, isFalse);
      expect(ready.failure, isA<ConflictFailure>());
      expect(ready.failure!.code, 'OFFER_REVISION_LIMIT');
      expect(repo.reviseCalls, 0);
    });

    test('revise with valid price succeeds', () async {
      final repo = FakeOffersVendorRepository(
        reviseResult: _testOffer(id: 'off-1', revisionCount: 1),
      );
      final container = containerWith(repo);
      final loaded = await _waitUntilSettled(container, offerId);
      final ready = loaded as ReviseOfferReady;
      ready.draft.offeredPrice = '5300.00';
      ready.draft.vendorNote = 'Updated';

      await container
          .read(reviseOfferControllerProvider(offerId).notifier)
          .revise();

      final state = container.read(reviseOfferControllerProvider(offerId));
      expect(state, isA<ReviseOfferSucceeded>());
      expect((state as ReviseOfferSucceeded).withdrawn, isFalse);
      expect(state.offer.revisionCount, 1);
      expect(repo.reviseCalls, 1);
      expect(repo.lastReviseOfferId, offerId);
      expect(repo.lastTerms!.offeredPrice, '5300.00');
      expect(repo.lastTerms!.vendorNote, 'Updated');
    });

    test('revise API failure returns to ready with inline failure', () async {
      final repo = FakeOffersVendorRepository(
        reviseError: const ConflictFailure(
          code: 'OFFER_NOT_PENDING',
          message: 'Only a pending Offer can be revised.',
        ),
      );
      final container = containerWith(repo);
      final loaded = await _waitUntilSettled(container, offerId);
      (loaded as ReviseOfferReady).draft.offeredPrice = '5100';

      await container
          .read(reviseOfferControllerProvider(offerId).notifier)
          .revise();

      final state = container.read(reviseOfferControllerProvider(offerId));
      expect(state, isA<ReviseOfferReady>());
      final ready = state as ReviseOfferReady;
      expect(ready.submitting, isFalse);
      expect(ready.failure?.code, 'OFFER_NOT_PENDING');
      expect(ready.failure?.message, 'Only a pending Offer can be revised.');
    });

    test('withdraw succeeds', () async {
      final repo = FakeOffersVendorRepository();
      final container = containerWith(repo);
      await _waitUntilSettled(container, offerId);

      await container
          .read(reviseOfferControllerProvider(offerId).notifier)
          .withdraw();

      final state = container.read(reviseOfferControllerProvider(offerId));
      expect(state, isA<ReviseOfferSucceeded>());
      expect((state as ReviseOfferSucceeded).withdrawn, isTrue);
      expect(repo.withdrawCalls, 1);
      expect(repo.lastWithdrawOfferId, offerId);
    });

    test('withdraw when not pending sets conflict without API call', () async {
      final repo = FakeOffersVendorRepository(
        offer: _testOffer(state: OfferState.accepted),
      );
      final container = containerWith(repo);
      await _waitUntilSettled(container, offerId);

      await container
          .read(reviseOfferControllerProvider(offerId).notifier)
          .withdraw();

      final state = container.read(reviseOfferControllerProvider(offerId));
      expect(state, isA<ReviseOfferReady>());
      final ready = state as ReviseOfferReady;
      expect(ready.offer.canWithdraw, isFalse);
      expect(ready.failure, isA<ConflictFailure>());
      expect(ready.failure!.code, 'OFFER_NOT_PENDING');
      expect(repo.withdrawCalls, 0);
    });

    test('touch clears inline failure on ready state', () async {
      final repo = FakeOffersVendorRepository();
      final container = containerWith(repo);
      final loaded = await _waitUntilSettled(container, offerId);
      (loaded as ReviseOfferReady).draft.offeredPrice = '';

      await container
          .read(reviseOfferControllerProvider(offerId).notifier)
          .revise();
      expect(
        (container.read(reviseOfferControllerProvider(offerId))
                as ReviseOfferReady)
            .failure,
        isNotNull,
      );

      container.read(reviseOfferControllerProvider(offerId).notifier).touch();

      expect(
        (container.read(reviseOfferControllerProvider(offerId))
                as ReviseOfferReady)
            .failure,
        isNull,
      );
    });
  });
}

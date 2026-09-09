import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/offers_vendor/controller/submit_offer_controller.dart';
import 'package:karat_hive/features/offers_vendor/repository/offers_vendor_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

VendorRequestItem _testRequest({
  String id = 'req-offer-1',
  String? reference = 'REQ-2026-0099',
}) {
  return VendorRequestItem(
    id: id,
    reference: reference,
    requestType: 'FIND_ORNAMENT',
    direction: 'BUY',
    state: 'PUBLISHED',
    categoryId: 'cat-ring',
    categoryName: 'Rings',
    regionId: 'reg-dxb',
    regionName: 'Dubai',
    purityKarat: '22',
    weightGrams: 15.0,
    budgetMin: 4000.0,
    budgetMax: 5500.0,
    offerCount: 2,
    customer: const MaskedParty(
      role: UserRole.customer,
      region: 'Dubai',
      dealCount: 5,
    ),
    publishedAt: DateTime.utc(2026, 9, 7, 0, 0),
    expiresAt: DateTime.utc(2026, 9, 9, 0, 0),
  );
}

PlatformConfig _testConfig({
  List<int> offerValidityHours = const [12, 24, 48],
}) =>
    PlatformConfig(offerValidityHours: offerValidityHours);

OfferForVendor _testOffer({
  String id = 'off-1',
  String requestId = 'req-offer-1',
}) {
  return OfferForVendor(
    id: id,
    requestId: requestId,
    state: OfferState.pending,
    terms: const OfferTerms(offeredPrice: '5200.00', validityHours: 24),
    submittedAt: DateTime.utc(2026, 9, 7, 12, 0),
    expiresAt: DateTime.utc(2026, 9, 8, 12, 0),
    revisionCount: 0,
  );
}

class FakeOffersVendorRepository implements OffersVendorRepository {
  FakeOffersVendorRepository({
    this.request,
    this.config,
    this.requestError,
    this.configError,
    this.submitError,
    this.submitResult,
    this.hangRequest = false,
    this.hangConfig = false,
  });

  final VendorRequestItem? request;
  final PlatformConfig? config;
  final Failure? requestError;
  final Failure? configError;
  final Failure? submitError;
  final OfferForVendor? submitResult;
  final bool hangRequest;
  final bool hangConfig;

  int getRequestCalls = 0;
  int getConfigCalls = 0;
  int submitCalls = 0;
  OfferTermsInput? lastTerms;
  String? lastSubmitRequestId;

  @override
  Future<Result<PlatformConfig>> getPlatformConfig() async {
    getConfigCalls++;
    if (hangConfig) await Completer<void>().future;
    if (configError != null) return Err(configError!);
    return Ok(config ?? _testConfig());
  }

  @override
  Future<Result<VendorRequestItem>> getRequest(String requestId) async {
    getRequestCalls++;
    if (hangRequest) await Completer<void>().future;
    if (requestError != null) return Err(requestError!);
    return Ok(request ?? _testRequest(id: requestId));
  }

  @override
  Future<Result<OfferForVendor>> getOffer(String offerId) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> submitOffer({
    required String requestId,
    required OfferTermsInput terms,
  }) async {
    submitCalls++;
    lastSubmitRequestId = requestId;
    lastTerms = terms;
    if (submitError != null) return Err(submitError!);
    return Ok(
      submitResult ??
          _testOffer(
            requestId: requestId,
          ),
    );
  }

  @override
  Future<Result<OfferForVendor>> reviseOffer({
    required String offerId,
    required OfferTermsInput terms,
  }) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<OfferForVendor>> withdrawOffer(String offerId) async =>
      Err(const ServerFailure(message: 'unused'));

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

Future<SubmitOfferState> _waitUntilSettled(
  ProviderContainer container,
  String requestId,
) async {
  for (var i = 0; i < 50; i++) {
    final state = container.read(submitOfferControllerProvider(requestId));
    if (state is! SubmitOfferLoading) return state;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  return container.read(submitOfferControllerProvider(requestId));
}

void main() {
  const requestId = 'req-offer-1';

  ProviderContainer containerWith(FakeOffersVendorRepository repo) {
    final container = ProviderContainer(
      overrides: [
        offersVendorRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(
      submitOfferControllerProvider(requestId),
      (_, __) {},
    );
    addTearDown(sub.close);
    return container;
  }

  group('SubmitOfferController (VEN-S09)', () {
    test('starts loading then reaches ready with empty draft (data/empty)',
        () async {
      final repo = FakeOffersVendorRepository(
        request: _testRequest(),
        config: _testConfig(),
      );
      final container = containerWith(repo);

      expect(
        container.read(submitOfferControllerProvider(requestId)),
        isA<SubmitOfferLoading>(),
      );

      final state = await _waitUntilSettled(container, requestId);
      expect(state, isA<SubmitOfferReady>());
      final ready = state as SubmitOfferReady;
      expect(ready.request.reference, 'REQ-2026-0099');
      expect(ready.config.offerValidityHours, [12, 24, 48]);
      expect(ready.draft.offeredPrice, isEmpty);
      expect(ready.draft.validityHours, 24);
      expect(ready.submitting, isFalse);
      expect(ready.failure, isNull);
      expect(repo.getRequestCalls, 1);
      expect(repo.getConfigCalls, 1);
    });

    test('defaults validityHours to first option when 24 is absent', () async {
      final repo = FakeOffersVendorRepository(
        config: _testConfig(offerValidityHours: const [12, 48]),
      );
      final container = containerWith(repo);

      final state = await _waitUntilSettled(container, requestId);
      expect(state, isA<SubmitOfferReady>());
      expect((state as SubmitOfferReady).draft.validityHours, 12);
    });

    test('surfaces request load failure as SubmitOfferFailed (error)', () async {
      final repo = FakeOffersVendorRepository(
        requestError: const NetworkFailure(message: 'offline'),
      );
      final container = containerWith(repo);

      final state = await _waitUntilSettled(container, requestId);
      expect(state, isA<SubmitOfferFailed>());
      expect((state as SubmitOfferFailed).failure.message, 'offline');
    });

    test('surfaces config load failure as SubmitOfferFailed (error)', () async {
      final repo = FakeOffersVendorRepository(
        configError: const ServerFailure(message: 'config unavailable'),
      );
      final container = containerWith(repo);

      final state = await _waitUntilSettled(container, requestId);
      expect(state, isA<SubmitOfferFailed>());
      expect(
        (state as SubmitOfferFailed).failure.message,
        'config unavailable',
      );
    });

    test('submit with empty price keeps ready and sets validation failure',
        () async {
      final repo = FakeOffersVendorRepository();
      final container = containerWith(repo);
      await _waitUntilSettled(container, requestId);

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();

      final state = container.read(submitOfferControllerProvider(requestId));
      expect(state, isA<SubmitOfferReady>());
      final ready = state as SubmitOfferReady;
      expect(ready.failure, isA<ValidationFailure>());
      expect(ready.failure!.message, 'Enter a valid offered price.');
      expect(repo.submitCalls, 0);
    });

    test('submit with valid price succeeds', () async {
      final repo = FakeOffersVendorRepository(
        submitResult: _testOffer(id: 'off-new'),
      );
      final container = containerWith(repo);
      final loaded = await _waitUntilSettled(container, requestId);
      final ready = loaded as SubmitOfferReady;
      ready.draft.offeredPrice = '5200.50';
      ready.draft.vendorNote = 'Ready in 2 days';

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();

      final state = container.read(submitOfferControllerProvider(requestId));
      expect(state, isA<SubmitOfferSucceeded>());
      expect((state as SubmitOfferSucceeded).offer.id, 'off-new');
      expect(repo.submitCalls, 1);
      expect(repo.lastSubmitRequestId, requestId);
      expect(repo.lastTerms!.offeredPrice, '5200.50');
      expect(repo.lastTerms!.vendorNote, 'Ready in 2 days');
      expect(repo.lastTerms!.validityHours, 24);
    });

    test('submit API failure returns to ready with inline failure', () async {
      final repo = FakeOffersVendorRepository(
        submitError: const ConflictFailure(
          code: 'OFFER_ALREADY_PENDING',
          message: 'You already have a pending Offer.',
        ),
      );
      final container = containerWith(repo);
      final loaded = await _waitUntilSettled(container, requestId);
      (loaded as SubmitOfferReady).draft.offeredPrice = '5000';

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();

      final state = container.read(submitOfferControllerProvider(requestId));
      expect(state, isA<SubmitOfferReady>());
      final ready = state as SubmitOfferReady;
      expect(ready.submitting, isFalse);
      expect(ready.failure?.code, 'OFFER_ALREADY_PENDING');
      expect(ready.failure?.message, 'You already have a pending Offer.');
    });

    test('touch clears inline failure on ready state', () async {
      final repo = FakeOffersVendorRepository();
      final container = containerWith(repo);
      await _waitUntilSettled(container, requestId);

      await container
          .read(submitOfferControllerProvider(requestId).notifier)
          .submit();
      expect(
        (container.read(submitOfferControllerProvider(requestId))
                as SubmitOfferReady)
            .failure,
        isNotNull,
      );

      container
          .read(submitOfferControllerProvider(requestId).notifier)
          .touch();

      expect(
        (container.read(submitOfferControllerProvider(requestId))
                as SubmitOfferReady)
            .failure,
        isNull,
      );
    });
  });
}

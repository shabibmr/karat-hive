import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/request_manage/controller/owner_request_detail_controller.dart';
import 'package:karat_hive/features/request_manage/repository/request_manage_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class _FakeRequestManageRepository implements RequestManageRepository {
  _FakeRequestManageRepository({required this.request});

  RequestForCustomer request;
  Failure? patchError;
  Failure? cancelError;
  int patchCallCount = 0;
  int cancelCallCount = 0;
  String? lastCancelReason;

  @override
  Future<Result<PagedResult<RequestForCustomer>>> listMine({
    String? cursor,
    int limit = 20,
    List<String>? state,
    String? requestType,
    String? direction,
    String? q,
    String? from,
    String? to,
  }) async =>
      Ok(PagedResult(items: [request]));

  @override
  Future<Result<RequestForCustomer>> getMine(String id) async => Ok(request);

  @override
  Future<Result<RequestForCustomer>> patchMine(
    String id, {
    String? notes,
    String? budgetMin,
    String? budgetMax,
    bool? budgetIsFlexible,
    List<String>? mediaKeys,
  }) async {
    patchCallCount++;
    if (patchError != null) return Err(patchError!);
    request = _withEdits(
      request,
      notes: notes,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      budgetIsFlexible: budgetIsFlexible,
    );
    return Ok(request);
  }

  @override
  Future<Result<RequestForCustomer>> cancel(String id, {String? reason}) async {
    cancelCallCount++;
    lastCancelReason = reason;
    if (cancelError != null) return Err(cancelError!);
    request = _withState(request, RequestState.cancelled);
    return Ok(request);
  }
}

RequestForCustomer _testRequest({
  String id = 'req-101',
  String reference = 'REQ-2026-0101',
  RequestState state = RequestState.published,
  int offerCount = 0,
  String? connectionId,
}) {
  return RequestForCustomer(
    id: id,
    reference: reference,
    requestType: RequestType.findOrnament,
    direction: Direction.buy,
    state: state,
    region: const RegionSummary(id: 'reg-dxb', nameEn: 'Dubai', nameAr: 'دبي'),
    weightIsApproximate: false,
    budgetIsFlexible: false,
    offerCount: offerCount,
    media: const [],
    createdAt: DateTime.utc(2026, 9, 1),
    updatedAt: DateTime.utc(2026, 9, 1),
    notes: 'Looking for a simple band ring',
    budgetMin: '2000',
    budgetMax: '3000',
    expiresAt: DateTime.utc(2026, 9, 12),
    connectionId: connectionId,
  );
}

RequestForCustomer _withEdits(
  RequestForCustomer req, {
  String? notes,
  String? budgetMin,
  String? budgetMax,
  bool? budgetIsFlexible,
}) {
  return RequestForCustomer(
    id: req.id,
    reference: req.reference,
    requestType: req.requestType,
    direction: req.direction,
    state: req.state,
    region: req.region,
    weightIsApproximate: req.weightIsApproximate,
    budgetIsFlexible: budgetIsFlexible ?? req.budgetIsFlexible,
    offerCount: req.offerCount,
    media: req.media,
    createdAt: req.createdAt,
    updatedAt: req.updatedAt,
    notes: notes ?? req.notes,
    budgetMin: budgetMin ?? req.budgetMin,
    budgetMax: budgetMax ?? req.budgetMax,
    expiresAt: req.expiresAt,
    connectionId: req.connectionId,
  );
}

RequestForCustomer _withState(RequestForCustomer req, RequestState state) {
  return RequestForCustomer(
    id: req.id,
    reference: req.reference,
    requestType: req.requestType,
    direction: req.direction,
    state: state,
    region: req.region,
    weightIsApproximate: req.weightIsApproximate,
    budgetIsFlexible: req.budgetIsFlexible,
    offerCount: req.offerCount,
    media: req.media,
    createdAt: req.createdAt,
    updatedAt: req.updatedAt,
    notes: req.notes,
    budgetMin: req.budgetMin,
    budgetMax: req.budgetMax,
    expiresAt: req.expiresAt,
    connectionId: req.connectionId,
  );
}

void main() {
  group('OwnerRequestDetailController (CUS-S10)', () {
    test('initial build loads the request', () async {
      final repo = _FakeRequestManageRepository(request: _testRequest());
      final container = ProviderContainer(
        overrides: [requestManageRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        ownerRequestDetailProvider('req-101').future,
      );

      expect(state.request.id, 'req-101');
      expect(state.actionError, isNull);
      expect(state.saving, isFalse);
      expect(state.cancelling, isFalse);
    });

    test('save() success replaces the request and clears error', () async {
      final repo = _FakeRequestManageRepository(request: _testRequest());
      final container = ProviderContainer(
        overrides: [requestManageRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(ownerRequestDetailProvider('req-101').future);
      final notifier =
          container.read(ownerRequestDetailProvider('req-101').notifier);

      final ok = await notifier.save(notes: 'Updated notes', budgetMin: '2500');
      expect(ok, isTrue);
      expect(repo.patchCallCount, 1);

      final state = container.read(ownerRequestDetailProvider('req-101')).value!;
      expect(state.request.notes, 'Updated notes');
      expect(state.request.budgetMin, '2500');
      expect(state.actionError, isNull);
      expect(state.saving, isFalse);
    });

    test('save() failure (STRUCTURAL_FIELD_IMMUTABLE) surfaces the server Failure', () async {
      final repo = _FakeRequestManageRepository(request: _testRequest())
        ..patchError = const ValidationFailure(
          code: 'STRUCTURAL_FIELD_IMMUTABLE',
          message: 'This field cannot be changed after publish.',
        );
      final container = ProviderContainer(
        overrides: [requestManageRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(ownerRequestDetailProvider('req-101').future);
      final notifier =
          container.read(ownerRequestDetailProvider('req-101').notifier);

      final ok = await notifier.save(notes: 'Attempted edit');
      expect(ok, isFalse);

      final state = container.read(ownerRequestDetailProvider('req-101')).value!;
      expect(state.actionError, isA<ValidationFailure>());
      expect(state.actionError!.code, 'STRUCTURAL_FIELD_IMMUTABLE');
      expect(state.saving, isFalse);
      // Request must be untouched on failure.
      expect(state.request.notes, 'Looking for a simple band ring');
    });

    test('cancel() success updates state to CANCELLED and clears error', () async {
      final repo = _FakeRequestManageRepository(request: _testRequest());
      final container = ProviderContainer(
        overrides: [requestManageRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(ownerRequestDetailProvider('req-101').future);
      final notifier =
          container.read(ownerRequestDetailProvider('req-101').notifier);

      final ok = await notifier.cancel(reason: 'CHANGED_MIND');
      expect(ok, isTrue);
      expect(repo.cancelCallCount, 1);
      expect(repo.lastCancelReason, 'CHANGED_MIND');

      final state = container.read(ownerRequestDetailProvider('req-101')).value!;
      expect(state.request.state, RequestState.cancelled);
      expect(state.actionError, isNull);
      expect(state.cancelling, isFalse);
    });

    test('cancel() failure (accept already in progress) surfaces the server Failure', () async {
      final repo = _FakeRequestManageRepository(
        request: _testRequest(state: RequestState.accepted),
      )..cancelError = const ConflictFailure(
          code: 'REQUEST_NOT_CANCELLABLE',
          message: 'This Request already has an accepted Offer.',
        );
      final container = ProviderContainer(
        overrides: [requestManageRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(ownerRequestDetailProvider('req-101').future);
      final notifier =
          container.read(ownerRequestDetailProvider('req-101').notifier);

      final ok = await notifier.cancel(reason: 'CHANGED_MIND');
      expect(ok, isFalse);

      final state = container.read(ownerRequestDetailProvider('req-101')).value!;
      expect(state.actionError, isA<ConflictFailure>());
      expect(state.actionError!.code, 'REQUEST_NOT_CANCELLABLE');
      expect(state.cancelling, isFalse);
      expect(state.request.state, RequestState.accepted);
    });

    test('reload() re-fetches the request from the repository', () async {
      final repo = _FakeRequestManageRepository(request: _testRequest());
      final container = ProviderContainer(
        overrides: [requestManageRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(ownerRequestDetailProvider('req-101').future);
      repo.request = _testRequest(offerCount: 3);

      final notifier =
          container.read(ownerRequestDetailProvider('req-101').notifier);
      await notifier.reload();

      final state = container.read(ownerRequestDetailProvider('req-101')).value!;
      expect(state.request.offerCount, 3);
    });
  });
}

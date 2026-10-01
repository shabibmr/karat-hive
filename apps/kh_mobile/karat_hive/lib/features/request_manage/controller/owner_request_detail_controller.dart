import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../core/firebase/perf_log_sink.dart';
import '../repository/request_manage_repository.dart';

class OwnerRequestDetailState {
  const OwnerRequestDetailState({
    required this.request,
    this.actionError,
    this.saving = false,
    this.cancelling = false,
  });

  final RequestForCustomer request;
  final Failure? actionError;
  final bool saving;
  final bool cancelling;

  OwnerRequestDetailState copyWith({
    RequestForCustomer? request,
    Failure? actionError,
    bool clearError = false,
    bool? saving,
    bool? cancelling,
  }) =>
      OwnerRequestDetailState(
        request: request ?? this.request,
        actionError: clearError ? null : (actionError ?? this.actionError),
        saving: saving ?? this.saving,
        cancelling: cancelling ?? this.cancelling,
      );
}

class OwnerRequestDetailController
    extends AsyncNotifier<OwnerRequestDetailState> {
  OwnerRequestDetailController(this.arg);

  final String arg;

  /// Started in [build], ended by [markImagesLoaded] once the detail screen's
  /// gallery has finished loading (or immediately if there are no photos).
  /// `request.open_draft` / `request.open_published` — flow chosen once the
  /// Request's state is known (docs/Request-Perf-Logging-Plan.md).
  PerfLog? _openPerf;

  @override
  Future<OwnerRequestDetailState> build() async {
    final perf = PerfLog('request.open', context: {'requestId': arg});
    final repo = ref.watch(requestManageRepositoryProvider);
    final res = await repo.getMine(arg);
    perf.lap('getMine');
    return res.when(
      ok: (req) {
        perf.flow = req.state == RequestState.published
            ? 'request.open_published'
            : 'request.open_draft';
        _openPerf = perf;
        return OwnerRequestDetailState(request: req);
      },
      err: (f) {
        _finish(perf, arg, extra: {'outcome': 'error'});
        throw f;
      },
    );
  }

  /// Called by the detail screen once every gallery photo has finished
  /// loading (or immediately when the Request has none), closing out the
  /// `request.open_draft` / `request.open_published` flow started in [build].
  void markImagesLoaded(int count) {
    final perf = _openPerf;
    _openPerf = null;
    if (perf != null) _finish(perf, arg, extra: {'imagesLoaded': count});
  }

  void _finish(
    PerfLog perf,
    String requestId, {
    Map<String, Object?> extra = const {},
  }) {
    final result = perf.done(extra: extra);
    ref.read(perfLogSinkProvider).record(result, requestId: requestId);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<bool> save({
    String? notes,
    String? budgetMin,
    String? budgetMax,
    bool? budgetIsFlexible,
  }) async {
    final current = state.value;
    if (current == null) return false;
    state = AsyncData(current.copyWith(saving: true, clearError: true));
    final repo = ref.read(requestManageRepositoryProvider);
    final res = await repo.patchMine(
      arg,
      notes: notes,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      budgetIsFlexible: budgetIsFlexible,
    );
    return res.when(
      ok: (req) {
        state = AsyncData(OwnerRequestDetailState(request: req));
        return true;
      },
      err: (f) {
        state = AsyncData(current.copyWith(saving: false, actionError: f));
        return false;
      },
    );
  }

  Future<bool> cancel({String? reason}) async {
    final current = state.value;
    if (current == null) return false;
    state = AsyncData(current.copyWith(cancelling: true, clearError: true));
    final repo = ref.read(requestManageRepositoryProvider);
    final res = await repo.cancel(arg, reason: reason);
    return res.when(
      ok: (req) {
        state = AsyncData(OwnerRequestDetailState(request: req));
        return true;
      },
      err: (f) {
        state = AsyncData(current.copyWith(cancelling: false, actionError: f));
        return false;
      },
    );
  }
}

final ownerRequestDetailProvider = AsyncNotifierProvider.autoDispose
    .family<OwnerRequestDetailController, OwnerRequestDetailState, String>(
  OwnerRequestDetailController.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

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
    extends AutoDisposeFamilyAsyncNotifier<OwnerRequestDetailState, String> {
  @override
  Future<OwnerRequestDetailState> build(String arg) async {
    final repo = ref.watch(requestManageRepositoryProvider);
    final res = await repo.getMine(arg);
    return res.when(
      ok: (req) => OwnerRequestDetailState(request: req),
      err: (f) => throw f,
    );
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }

  Future<bool> save({
    String? notes,
    String? budgetMin,
    String? budgetMax,
    bool? budgetIsFlexible,
  }) async {
    final current = state.valueOrNull;
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
    final current = state.valueOrNull;
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

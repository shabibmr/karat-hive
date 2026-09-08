import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/session/session_controller.dart';
import '../repository/request_create_repository.dart';
import 'request_create_state.dart';

Direction? directionForType(RequestType type) => switch (type) {
      RequestType.findOrnament => Direction.buy,
      RequestType.sellOldGold => Direction.sell,
      _ => null,
    };

String ornamentWire(OrnamentType t) => switch (t) {
      OrnamentType.ring => 'RING',
      OrnamentType.chain => 'CHAIN',
      OrnamentType.bangle => 'BANGLE',
      OrnamentType.necklace => 'NECKLACE',
      OrnamentType.earring => 'EARRING',
      OrnamentType.bracelet => 'BRACELET',
      OrnamentType.pendant => 'PENDANT',
      OrnamentType.other => 'OTHER',
      OrnamentType.unknown => 'UNKNOWN',
    };

String conditionWire(ItemCondition t) => switch (t) {
      ItemCondition.brandNew => 'NEW',
      ItemCondition.likeNew => 'LIKE_NEW',
      ItemCondition.used => 'USED',
      ItemCondition.damaged => 'DAMAGED',
      ItemCondition.unknown => 'UNKNOWN',
    };

Karat karatFromConfig(String raw) {
  final n = raw.replaceAll('K', '').replaceAll('k', '');
  return Karat.parse('${n}K');
}

/// Flow-scoped wizard (CUS-S03…S09). Keep-alive so disposing a step widget
/// does not drop fields (Architecture-Frontend §6.2).
class RequestCreateController extends Notifier<RequestCreateState> {
  RequestCreateRepository get _repo =>
      ref.read(requestCreateRepositoryProvider);

  @override
  RequestCreateState build() {
    final session = ref.read(sessionProvider);
    var canCreate = true;
    var oauthBound = false;
    String? defaultRegion;
    if (session is SignedIn) {
      canCreate = session.user.canCreateRequest ?? true;
      oauthBound = session.user.oauthBound;
      defaultRegion = session.user.customer?.defaultRegion?.id;
    }
    return RequestCreateState(
      canCreateRequest: canCreate,
      oauthBound: oauthBound,
      regionId: defaultRegion,
    );
  }

  Future<void> ensureLoaded() async {
    if (state.lookupsReady || state.lookupsLoading) return;
    await loadLookups();
  }

  Future<void> loadLookups() async {
    state = state.copyWith(lookupsLoading: true, clearFailure: true);
    final configR = await _repo.platformConfig();
    final ratesR = await _repo.goldRates();
    final catR = await _repo.categories();
    final regR = await _repo.regions();
    final meR = await _repo.me();

    final fail = configR.failureOrNull ??
        catR.failureOrNull ??
        regR.failureOrNull ??
        meR.failureOrNull;
    // Gold rates may be unavailable; compose still allowed except bullion publish.
    final rates = ratesR.valueOrNull ??
        const GoldRateSnapshot(available: false, stale: false);

    final me = meR.valueOrNull;
    state = state.copyWith(
      lookupsLoading: false,
      lookupsReady: fail == null,
      failure: fail,
      config: configR.valueOrNull,
      rates: rates,
      categories: catR.valueOrNull ?? const [],
      regions: regR.valueOrNull ?? const [],
      canCreateRequest: me?.canCreateRequest ?? state.canCreateRequest,
      oauthBound: me?.oauthBound ?? state.oauthBound,
      regionId: state.regionId ?? me?.customer?.defaultRegion?.id,
    );
  }

  void selectType(RequestType type) {
    final prev = state.requestType;
    final reset = prev != null && prev != type;
    final fixed = directionForType(type);
    state = state.copyWith(
      requestType: type,
      direction: fixed ?? (reset ? null : state.direction),
      clearDirection: reset && fixed == null,
      clearWeight: reset,
      clearPurity: reset,
      clearOrnament: reset,
      clearCondition: reset,
      clearDenomination: reset,
      clearQuantity: reset,
      clearMint: reset,
      clearBudgetMin: reset,
      clearBudgetMax: reset,
      gemstonesPresent: reset ? false : state.gemstonesPresent,
      clearGemstoneType: reset,
      gemstoneCount: reset ? null : state.gemstoneCount,
      purityKarat: type == RequestType.goldBullion && (reset || state.purityKarat == null)
          ? Karat.k24
          : (reset ? null : state.purityKarat),
      step: RequestCreateStep.compose,
      clearFailure: true,
      fieldErrors: const {},
    );
  }

  void setDirection(Direction value) {
    if (state.requestType == RequestType.findOrnament ||
        state.requestType == RequestType.sellOldGold) {
      return;
    }
    state = state.copyWith(direction: value, clearFailure: true);
  }

  void setCategory(String id) =>
      state = state.copyWith(categoryId: id, clearFailure: true);

  void setRegion(String id) =>
      state = state.copyWith(regionId: id, clearFailure: true);

  void setNotes(String value) => state = state.copyWith(notes: value);

  void setWeightGrams(String? value) =>
      state = state.copyWith(weightGrams: value, clearWeight: value == null);

  void setWeightApproximate(bool value) =>
      state = state.copyWith(weightIsApproximate: value);

  void setPurity(Karat value) => state = state.copyWith(purityKarat: value);

  void setOrnamentType(OrnamentType value) =>
      state = state.copyWith(ornamentType: value);

  void setCondition(ItemCondition value) =>
      state = state.copyWith(condition: value);

  void setDenomination(String value) =>
      state = state.copyWith(denominationGrams: value);

  void setQuantity(int? value) =>
      state = state.copyWith(quantity: value, clearQuantity: value == null);

  void setMint(String value) => state = state.copyWith(mintOrRefiner: value);

  void setBudgetMode(BudgetMode mode) => state = state.copyWith(
        budgetMode: mode,
        clearBudgetMin: mode == BudgetMode.maxOnly,
      );

  void setBudgetMin(String? value) =>
      state = state.copyWith(budgetMin: value, clearBudgetMin: value == null);

  void setBudgetMax(String? value) =>
      state = state.copyWith(budgetMax: value, clearBudgetMax: value == null);

  void setBudgetFlexible(bool value) =>
      state = state.copyWith(budgetIsFlexible: value);

  void setGemstonesPresent(bool value) => state = state.copyWith(
        gemstonesPresent: value,
        clearGemstoneType: !value,
        gemstoneCount: value ? state.gemstoneCount : null,
      );

  void setGemstoneType(String value) =>
      state = state.copyWith(gemstoneType: value);

  void setGemstoneCount(int? value) =>
      state = state.copyWith(gemstoneCount: value);

  void setHasInvoice(bool value) => state = state.copyWith(hasInvoice: value);

  void setPackagingSealed(bool value) =>
      state = state.copyWith(packagingSealed: value);

  void setHasAssayCertificate(bool value) =>
      state = state.copyWith(hasAssayCertificate: value);

  void goTo(RequestCreateStep step) => state = state.copyWith(step: step);

  /// Draft PATCH/POST — no mandatory-field validation (FR-CUS-015).
  Future<bool> saveDraft() async {
    if (state.requestType == null) return false;
    state = state.copyWith(busy: true, clearFailure: true, fieldErrors: const {});
    final body = draftBody();
    final Result<DraftSaveResult> result;
    final id = state.draftId;
    if (id == null) {
      result = await _repo.createDraft(body);
    } else {
      result = await _repo.patchDraft(id, body);
    }
    return result.when(
      ok: (saved) {
        state = state.copyWith(
          busy: false,
          draftId: saved.request.id,
          warnings: saved.warnings,
        );
        return true;
      },
      err: (f) {
        state = state.copyWith(
          busy: false,
          failure: f,
          fieldErrors: f.fieldErrors,
        );
        return false;
      },
    );
  }

  Future<bool> persistAndGo(RequestCreateStep next) async {
    final ok = await saveDraft();
    if (ok) goTo(next);
    return ok;
  }

  Future<void> addImage(File file, String contentType) async {
    if (state.mediaKeys.length >= state.maxImages) return;
    final placeholder = MediaSlot(
      key: 'pending-${file.path.hashCode}',
      localLabel: file.path.split(Platform.pathSeparator).last,
      progress: 0,
      uploading: true,
    );
    state = state.copyWith(
      media: [...state.media, placeholder],
      uploading: true,
      clearFailure: true,
    );
    final result = await _repo.uploadRequestImage(
      file,
      contentType,
      onProgress: (p) {
        state = state.copyWith(
          media: [
            for (final m in state.media)
              if (m.key == placeholder.key) m.copyWith(progress: p) else m,
          ],
        );
      },
    );
    result.when(
      ok: (key) {
        state = state.copyWith(
          uploading: false,
          media: [
            for (final m in state.media)
              if (m.key == placeholder.key)
                MediaSlot(key: key, localLabel: placeholder.localLabel)
              else
                m,
          ],
        );
      },
      err: (f) {
        state = state.copyWith(
          uploading: false,
          media: [
            for (final m in state.media)
              if (m.key == placeholder.key)
                m.copyWith(uploading: false, failure: f)
              else
                m,
          ],
        );
      },
    );
  }

  Future<void> retryImage(MediaSlot slot, File file, String contentType) async {
    state = state.copyWith(
      media: [
        for (final m in state.media)
          if (m.key == slot.key)
            m.copyWith(uploading: true, progress: 0, clearFailure: true)
          else
            m,
      ],
    );
    await addImage(file, contentType);
    state = state.copyWith(
      media: [
        for (final m in state.media)
          if (m.key == slot.key) ...[] else m,
      ],
    );
  }

  Future<void> removeMediaAt(int index) async {
    if (index < 0 || index >= state.media.length) return;
    final slot = state.media[index];
    if (slot.key.isNotEmpty && !slot.key.startsWith('pending-')) {
      await _repo.deleteMedia(slot.key);
    }
    final next = [...state.media]..removeAt(index);
    state = state.copyWith(media: next);
    if (state.draftId != null) await saveDraft();
  }

  Future<void> reorderMedia(int from, int to) async {
    if (from == to) return;
    final next = [...state.media];
    final item = next.removeAt(from);
    next.insert(to, item);
    state = state.copyWith(media: next);
    if (state.draftId != null) await saveDraft();
  }

  String _ensurePublishKey() {
    final existing = state.publishIdempotencyKey;
    if (existing != null) return existing;
    final key = _uuid();
    state = state.copyWith(publishIdempotencyKey: key);
    return key;
  }

  Future<bool> publish() async {
    if (state.draftId == null) {
      final created = await saveDraft();
      if (!created) return false;
    }
    final id = state.draftId;
    if (id == null) return false;
    state = state.copyWith(busy: true, clearFailure: true, fieldErrors: const {});
    final key = _ensurePublishKey();
    final result = await _repo.publish(id, idempotencyKey: key);
    return result.when(
      ok: (req) {
        state = state.copyWith(
          busy: false,
          published: req,
          step: RequestCreateStep.success,
        );
        return true;
      },
      err: (f) {
        state = state.copyWith(
          busy: false,
          failure: f,
          fieldErrors: f.fieldErrors,
        );
        return false;
      },
    );
  }

  /// Bind OAuth then retry publish with the **same** idempotency key.
  Future<bool> bindThenPublish(String identityToken) async {
    state = state.copyWith(busy: true, clearFailure: true);
    final bind = await _repo.bindOAuth(identityToken: identityToken);
    final bindFail = bind.failureOrNull;
    if (bindFail != null) {
      state = state.copyWith(busy: false, failure: bindFail);
      return false;
    }
    state = state.copyWith(oauthBound: true);
    return publish();
  }

  void resetFlow() {
    final keep = state;
    state = RequestCreateState(
      canCreateRequest: keep.canCreateRequest,
      oauthBound: keep.oauthBound,
      config: keep.config,
      rates: keep.rates,
      categories: keep.categories,
      regions: keep.regions,
      lookupsReady: keep.lookupsReady,
      regionId: keep.regionId,
    );
  }

  Map<String, dynamic> draftBody() {
    final type = state.requestType!;
    final dir = directionForType(type) ?? state.direction;
    return {
      'requestType': type.wire,
      if (dir != null) 'direction': dir.wire,
      if (state.categoryId != null) 'categoryId': state.categoryId,
      if (state.regionId != null) 'regionId': state.regionId,
      if (state.notes.trim().isNotEmpty) 'notes': state.notes.trim(),
      if (state.weightGrams != null && state.weightGrams!.isNotEmpty)
        'weightGrams': state.weightGrams,
      'weightIsApproximate': state.weightIsApproximate,
      if (state.purityKarat != null) 'purityKarat': state.purityKarat!.wire,
      if (state.ornamentType != null)
        'ornamentType': ornamentWire(state.ornamentType!),
      if (state.condition != null) 'condition': conditionWire(state.condition!),
      if (state.denominationGrams != null &&
          state.denominationGrams!.isNotEmpty)
        'denominationGrams': state.denominationGrams,
      if (state.quantity != null) 'quantity': state.quantity,
      if (state.mintOrRefiner != null && state.mintOrRefiner!.isNotEmpty)
        'mintOrRefiner': state.mintOrRefiner,
      if (state.budgetMode == BudgetMode.range &&
          state.budgetMin != null &&
          state.budgetMin!.isNotEmpty)
        'budgetMin': state.budgetMin,
      if (state.budgetMax != null && state.budgetMax!.isNotEmpty)
        'budgetMax': state.budgetMax,
      'budgetIsFlexible': state.budgetIsFlexible,
      if (type == RequestType.findOrnament)
        'gemstones': {
          'present': state.gemstonesPresent,
          if (state.gemstonesPresent &&
              state.gemstoneType != null &&
              state.gemstoneType!.isNotEmpty)
            'type': state.gemstoneType,
          if (state.gemstonesPresent && state.gemstoneCount != null)
            'count': state.gemstoneCount,
        },
      if (state.mediaKeys.isNotEmpty) 'mediaKeys': state.mediaKeys,
    };
  }

  double? indicativeValueAed() {
    final rates = state.rates;
    if (rates == null || !rates.available) return null;
    final karat = state.purityKarat ?? Karat.k24;
    GoldRateRow? row;
    for (final r in rates.rates) {
      if (r.karat == karat) row = r;
    }
    row ??= rates.rates.isEmpty ? null : rates.rates.first;
    if (row == null) return null;
    final rate = double.tryParse(row.ratePerGramAed);
    if (rate == null) return null;
    final grams = totalWeightGrams();
    if (grams == null) return null;
    return grams * rate;
  }

  double? totalWeightGrams() {
    final type = state.requestType;
    if (type == RequestType.goldCoin) {
      final d = double.tryParse(state.denominationGrams ?? '');
      final q = state.quantity;
      if (d == null || q == null) return null;
      return d * q;
    }
    if (type == RequestType.goldBullion) {
      final d = double.tryParse(state.weightGrams ?? '');
      final q = state.quantity ?? 1;
      if (d == null) return null;
      return d * q;
    }
    return double.tryParse(state.weightGrams ?? '');
  }

  double? bullionFloorAed() =>
      double.tryParse(state.config?.bullionMinimumAed ?? '500');

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

final requestCreateControllerProvider =
    NotifierProvider<RequestCreateController, RequestCreateState>(
  RequestCreateController.new,
);

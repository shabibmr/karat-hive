import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/session/session_controller.dart';
import '../pending_publish_intent.dart';
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

  /// One-shot guard for GL-57 (SignedIn Customer + pending → pipeline once).
  bool _pendingAutoPublishConsumed = false;
  Future<void>? _reconcileInFlight;
  bool _disposed = false;

  @override
  RequestCreateState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    ref.listen<SessionState>(sessionProvider, (_, __) {
      unawaited(reconcilePendingPublish());
    });
    ref.listen<bool>(pendingPublishIntentProvider, (_, pending) {
      if (pending) {
        unawaited(reconcilePendingPublish());
      } else {
        _pendingAutoPublishConsumed = false;
      }
    });

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

  /// GL-57…GL-61: Customer + pending → upload/save/publish once;
  /// Vendor + pending → reset draft and clear intent (no API).
  ///
  /// Callers wait out any in-flight run, then re-evaluate with the latest
  /// session/pending. Joining a SignedOut no-op must not swallow a later
  /// SignedIn transition (setPending then setSession in the same turn).
  Future<void> reconcilePendingPublish() async {
    while (true) {
      final existing = _reconcileInFlight;
      if (existing != null) {
        await existing;
        continue;
      }
      if (_disposed) return;

      // Claim synchronously before the body can await, so waiters join us
      // instead of starting a parallel publish.
      final done = Completer<void>();
      _reconcileInFlight = done.future;
      try {
        await _reconcilePendingPublishBody();
        if (!done.isCompleted) done.complete();
      } catch (e, st) {
        if (!done.isCompleted) done.completeError(e, st);
        rethrow;
      } finally {
        if (identical(_reconcileInFlight, done.future)) {
          _reconcileInFlight = null;
        }
      }
      // Waiters that joined this run loop and re-evaluate with fresh session.
      return;
    }
  }

  Future<void> _reconcilePendingPublishBody() async {
    if (_disposed) return;

    final pending = ref.read(pendingPublishIntentProvider);
    if (!pending) {
      _pendingAutoPublishConsumed = false;
      return;
    }

    // Always read latest session (ignore caller snapshots).
    final current = ref.read(sessionProvider);
    if (current is! SignedIn) return;

    if (current.isVendor) {
      resetFlow();
      if (!_disposed) {
        ref.read(pendingPublishIntentProvider.notifier).clearPending();
      }
      _pendingAutoPublishConsumed = false;
      return;
    }

    if (!current.isCustomer) return;
    if (_pendingAutoPublishConsumed) return;
    if (state.step == RequestCreateStep.success) {
      if (!_disposed) {
        ref.read(pendingPublishIntentProvider.notifier).clearPending();
      }
      return;
    }

    _pendingAutoPublishConsumed = true;
    final ok = await publish();
    if (_disposed) return;
    if (ok) {
      // publish() already clearPending (GL-60); allow a future guest cycle.
      _pendingAutoPublishConsumed = false;
    }
    // GL-59: stay SignedIn, surface form error; consumed blocks auto re-entry.
    // Manual Publish on the review screen retries without the overlay.
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

    // Guest compose must not call authenticated me() (GL-50).
    final signedIn = ref.read(sessionProvider) is SignedIn;
    final Result<MeUser>? meR = signedIn ? await _repo.me() : null;

    final fail =
        configR.failureOrNull ??
        catR.failureOrNull ??
        regR.failureOrNull ??
        meR?.failureOrNull;
    // Gold rates may be unavailable; compose still allowed except bullion publish.
    final rates =
        ratesR.valueOrNull ??
        const GoldRateSnapshot(available: false, stale: false);

    final me = meR?.valueOrNull;
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
      purityKarat:
          type == RequestType.goldBullion &&
              (reset || state.purityKarat == null)
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
  /// Guest must not hit the API (GL-56); Publish uses pending intent instead.
  Future<bool> saveDraft() async {
    if (ref.read(sessionProvider) is! SignedIn) return false;
    if (state.requestType == null) return false;
    state = state.copyWith(
      busy: true,
      clearFailure: true,
      fieldErrors: const {},
    );
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
    if (state.media.length >= state.maxImages) return;
    final label = file.path.split(Platform.pathSeparator).last;
    final placeholderKey =
        'pending-${file.path.hashCode}-${state.media.length}';

    // Guest: keep the File locally; upload only after SignedIn (GL-53 / GL-55).
    if (ref.read(sessionProvider) is! SignedIn) {
      state = state.copyWith(
        media: [
          ...state.media,
          MediaSlot(
            key: placeholderKey,
            localLabel: label,
            localFile: file,
            contentType: contentType,
          ),
        ],
        clearFailure: true,
      );
      return;
    }

    final placeholder = MediaSlot(
      key: placeholderKey,
      localLabel: label,
      localFile: file,
      contentType: contentType,
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
    final signedIn = ref.read(sessionProvider) is SignedIn;
    if (signedIn && slot.key.isNotEmpty && !slot.key.startsWith('pending-')) {
      await _repo.deleteMedia(slot.key);
    }
    final next = [...state.media]..removeAt(index);
    state = state.copyWith(media: next);
    if (signedIn && state.draftId != null) await saveDraft();
  }

  /// Upload guest-held local files once SignedIn, before draft (GL-55).
  Future<bool> uploadPendingLocalMedia() async {
    if (ref.read(sessionProvider) is! SignedIn) return false;
    final pending = state.media
        .where((m) => m.isLocalPending)
        .toList(growable: false);
    if (pending.isEmpty) return true;

    state = state.copyWith(uploading: true, clearFailure: true);
    for (final slot in pending) {
      final file = slot.localFile;
      final contentType = slot.contentType;
      if (file == null || contentType == null) continue;

      state = state.copyWith(
        media: [
          for (final m in state.media)
            if (m.key == slot.key)
              m.copyWith(uploading: true, progress: 0, clearFailure: true)
            else
              m,
        ],
      );

      final result = await _repo.uploadRequestImage(
        file,
        contentType,
        onProgress: (p) {
          state = state.copyWith(
            media: [
              for (final m in state.media)
                if (m.key == slot.key) m.copyWith(progress: p) else m,
            ],
          );
        },
      );

      final failed = result.when(
        ok: (key) {
          state = state.copyWith(
            media: [
              for (final m in state.media)
                if (m.key == slot.key)
                  MediaSlot(key: key, localLabel: slot.localLabel)
                else
                  m,
            ],
          );
          return false;
        },
        err: (f) {
          state = state.copyWith(
            uploading: false,
            failure: f,
            media: [
              for (final m in state.media)
                if (m.key == slot.key)
                  m.copyWith(uploading: false, failure: f)
                else
                  m,
            ],
          );
          return true;
        },
      );
      if (failed) return false;
    }

    state = state.copyWith(uploading: false);
    return true;
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
    // Guest Publish uses pending intent + Login overlay (GL-46), not the API.
    if (ref.read(sessionProvider) is! SignedIn) return false;

    // GL-58: upload local guest media → persist draft → publish.
    final uploaded = await uploadPendingLocalMedia();
    if (!uploaded) return false;

    final saved = await saveDraft();
    if (!saved) return false;

    final id = state.draftId;
    if (id == null) return false;
    state = state.copyWith(
      busy: true,
      clearFailure: true,
      fieldErrors: const {},
    );
    final key = _ensurePublishKey();
    final result = await _repo.publish(id, idempotencyKey: key);
    return result.when(
      ok: (req) {
        if (_disposed) return true;
        state = state.copyWith(
          busy: false,
          published: req,
          step: RequestCreateStep.success,
        );
        // GL-60 — drop intent once the Request is live.
        ref.read(pendingPublishIntentProvider.notifier).clearPending();
        return true;
      },
      err: (f) {
        if (_disposed) return false;
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

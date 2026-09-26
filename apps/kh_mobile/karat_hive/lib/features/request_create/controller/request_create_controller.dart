import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_media/kh_media.dart';

import '../../../app/di.dart';
import '../../../app/session/session_controller.dart';
import '../pending_publish_intent.dart';
import '../repository/request_create_repository.dart';
import 'request_create_state.dart';

final requestImageConverterProvider = Provider<ImageConverter>(
  (ref) => const AvifImageConverter(),
);

/// Overridable so tests can exercise the web upload branch without the web
/// test runner — `kIsWeb` is a compile-time constant on the VM.
final isWebPlatformProvider = Provider<bool>((ref) => kIsWeb);

/// Wait between publish retries while photos finish server-side processing.
/// Overridable so tests don't sleep.
final mediaReadyRetryDelayProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

/// ~60 s at the default delay — the same budget the uploader used to spend
/// polling each photo for `READY` before this moved to publish time.
const _mediaReadyMaxRetries = 30;

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

  /// One-shot guard for [reconcilePendingPublish] — a manual [publish] retry
  /// after a failed auto-publish attempt is unaffected by this.
  bool _reconcileAttempted = false;

  /// Shared so sign-in flush and [publish] cannot double-upload the same slot.
  Future<bool>? _flushInFlight;

  /// Shared so [build] and tests cannot overlap cold-boot restore.
  Future<void>? _restoreInFlight;

  @override
  RequestCreateState build() {
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next is! SignedIn || !next.isCustomer) return;
      final wasCustomer = prev is SignedIn && prev.isCustomer;
      if (wasCustomer) return;
      if (!state.media.any((m) => m.isLocalOnly)) return;
      unawaited(_uploadPendingLocalMedia());
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
    final initial = RequestCreateState(
      canCreateRequest: canCreate,
      oauthBound: oauthBound,
      regionId: defaultRegion,
    );
    unawaited(_restorePendingDraft());
    return initial;
  }

  /// Completes when the fire-and-forget restore from [build] finishes.
  Future<void> waitForPendingDraftRestore() async {
    final inFlight = _restoreInFlight;
    if (inFlight != null) await inFlight;
  }

  /// Cold-boot restore (GL-59): if a Guest force-quit mid-draft, rehydrate
  /// the wizard from the on-disk snapshot so a still-pending publish intent
  /// can complete once the user signs in. Best-effort only — any platform
  /// or IO error (e.g. no `path_provider` plugin in a plain unit test)
  /// leaves the fresh in-memory state untouched.
  Future<void> _restorePendingDraft() {
    return _restoreInFlight ??= _runPendingDraftRestore();
  }

  Future<void> _runPendingDraftRestore() async {
    try {
      final store = ref.read(pendingPublishDraftStoreProvider);
      final snapshot = await store.load();
      if (snapshot == null) return;
      if (snapshot.isExpired) {
        await store.clear();
        return;
      }
      if (state.requestType != null) return;
      state = _applyPersistedFields(state, snapshot.fields, snapshot.mediaKeys);
      ref.read(pendingPublishIntentProvider.notifier).setPending();
    } catch (_) {
      // Best-effort restore only.
    }
  }

  /// Persist the current draft locally (GL-57): called when a Guest reaches
  /// review, and again right before the sign-in overlay opens, so the draft
  /// survives a cold app restart while auth is pending.
  Future<void> persistPendingDraft() async {
    if (state.requestType == null) return;
    try {
      await ref.read(pendingPublishDraftStoreProvider).save(
            PendingPublishDraftSnapshot(
              fields: _persistedFields(),
              mediaKeys: state.mediaKeys,
              expiresAt: DateTime.now().toUtc().add(const Duration(days: 7)),
            ),
          );
    } catch (_) {
      // Best-effort only.
    }
  }

  Future<void> _clearPersistedDraft() async {
    try {
      await ref.read(pendingPublishDraftStoreProvider).clear();
    } catch (_) {
      // Best-effort only.
    }
  }

  Map<String, dynamic> _persistedFields() => {
        if (state.requestType != null) 'requestType': state.requestType!.wire,
        if (state.direction != null) 'direction': state.direction!.wire,
        if (state.regionId != null) 'regionId': state.regionId,
        'notes': state.notes,
        if (state.weightGrams != null) 'weightGrams': state.weightGrams,
        'weightIsApproximate': state.weightIsApproximate,
        if (state.purityKarat != null) 'purityKarat': state.purityKarat!.wire,
        if (state.ornamentType != null)
          'ornamentType': state.ornamentType!.wire,
        if (state.condition != null) 'condition': state.condition!.wire,
        if (state.denominationGrams != null)
          'denominationGrams': state.denominationGrams,
        if (state.quantity != null) 'quantity': state.quantity,
        if (state.mintOrRefiner != null) 'mintOrRefiner': state.mintOrRefiner,
        'budgetMode': state.budgetMode.name,
        if (state.budgetMin != null) 'budgetMin': state.budgetMin,
        if (state.budgetMax != null) 'budgetMax': state.budgetMax,
        'budgetIsFlexible': state.budgetIsFlexible,
        'gemstonesPresent': state.gemstonesPresent,
        if (state.gemstoneType != null) 'gemstoneType': state.gemstoneType,
        if (state.gemstoneCount != null) 'gemstoneCount': state.gemstoneCount,
        'hasInvoice': state.hasInvoice,
        if (state.packagingSealed != null)
          'packagingSealed': state.packagingSealed,
        'hasAssayCertificate': state.hasAssayCertificate,
        if (state.draftId != null) 'draftId': state.draftId,
        if (state.publishIdempotencyKey != null)
          'publishIdempotencyKey': state.publishIdempotencyKey,
      };

  RequestCreateState _applyPersistedFields(
    RequestCreateState base,
    Map<String, dynamic> f,
    List<String> mediaKeys,
  ) {
    return base.copyWith(
      requestType: f['requestType'] == null
          ? null
          : RequestType.parse(f['requestType'] as String?),
      direction: f['direction'] == null
          ? null
          : Direction.parse(f['direction'] as String?),
      regionId: f['regionId'] as String?,
      notes: f['notes'] as String? ?? '',
      weightGrams: f['weightGrams'] as String?,
      weightIsApproximate: f['weightIsApproximate'] as bool? ?? false,
      purityKarat:
          f['purityKarat'] == null ? null : Karat.parse(f['purityKarat'] as String?),
      ornamentType: f['ornamentType'] == null
          ? null
          : OrnamentType.parse(f['ornamentType'] as String?),
      condition: f['condition'] == null
          ? null
          : ItemCondition.parse(f['condition'] as String?),
      denominationGrams: f['denominationGrams'] as String?,
      quantity: f['quantity'] as int?,
      mintOrRefiner: f['mintOrRefiner'] as String?,
      budgetMode:
          BudgetMode.values.byName(f['budgetMode'] as String? ?? 'maxOnly'),
      budgetMin: f['budgetMin'] as String?,
      budgetMax: f['budgetMax'] as String?,
      budgetIsFlexible: f['budgetIsFlexible'] as bool? ?? false,
      gemstonesPresent: f['gemstonesPresent'] as bool? ?? false,
      gemstoneType: f['gemstoneType'] as String?,
      gemstoneCount: f['gemstoneCount'] as int?,
      hasInvoice: f['hasInvoice'] as bool? ?? false,
      packagingSealed: f['packagingSealed'] as bool?,
      hasAssayCertificate: f['hasAssayCertificate'] as bool? ?? false,
      draftId: f['draftId'] as String?,
      publishIdempotencyKey: f['publishIdempotencyKey'] as String?,
      media: [for (final k in mediaKeys) MediaSlot(key: k)],
    );
  }

  /// Opportunistic reconciliation for the Guest → Login → auto-publish
  /// pipeline (GL-57…GL-63). Safe to call on every session-state change: a
  /// no-op unless [pendingPublishIntentProvider] is set, and it only
  /// attempts the publish pipeline once per pending intent — a manual retry
  /// via [publish] after a failure still works.
  Future<bool> reconcilePendingPublish() async {
    final pending = ref.read(pendingPublishIntentProvider);
    if (!pending) return false;
    final session = ref.read(sessionProvider);
    if (session is! SignedIn) return false;

    if (session.isVendor) {
      ref.read(pendingPublishIntentProvider.notifier).clearPending();
      resetFlow();
      _reconcileAttempted = false;
      unawaited(_clearPersistedDraft());
      return false;
    }
    if (!session.isCustomer) return false;
    if (_reconcileAttempted) return false;
    _reconcileAttempted = true;

    await _refreshMeState();
    final ok = await publish();
    if (ok) {
      ref.read(pendingPublishIntentProvider.notifier).clearPending();
      unawaited(_clearPersistedDraft());
    }
    return ok;
  }

  Future<void> _refreshMeState() async {
    try {
      final meR = await _repo.me();
      final me = meR.valueOrNull;
      if (me != null) {
        state = state.copyWith(
          oauthBound: me.oauthBound,
          canCreateRequest: me.canCreateRequest ?? true,
        );
      }
    } catch (_) {
      // Best-effort profile refresh; proceed with existing state if offline.
    }
  }

  Future<void> ensureLoaded() async {
    if (state.lookupsReady || state.lookupsLoading) return;
    await loadLookups();
  }

  bool get _isGuest => ref.read(sessionProvider) is! SignedIn;

  /// Guest: local AVIF is enough. Signed-in: every slot must have a READY key.
  bool get canContinuePhotos {
    if (!state.photosAttachedReady) return false;
    if (_isGuest) return true;
    return state.mediaKeysReady;
  }

  Future<void> loadLookups() async {
    state = state.copyWith(lookupsLoading: true, clearFailure: true);
    final configR = await _repo.platformConfig();
    final regR = await _repo.regions();

    // Guest has no token — do not require GET /v1/me (`adr/0011`).
    Result<MeUser>? meR;
    if (!_isGuest) {
      meR = await _repo.me();
    }

    final fail = configR.failureOrNull ??
        regR.failureOrNull ??
        meR?.failureOrNull;

    final me = meR?.valueOrNull;
    state = state.copyWith(
      lookupsLoading: false,
      lookupsReady: fail == null,
      failure: fail,
      config: configR.valueOrNull,
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
    final combinedDetailsAndImages = type == RequestType.findOrnament ||
        type == RequestType.sellOldGold;
    final buySellChoice = type == RequestType.goldCoin ||
        type == RequestType.goldBullion;

    final Direction? resolvedDirection;
    if (fixed != null) {
      resolvedDirection = fixed;
    } else if (buySellChoice) {
      resolvedDirection = reset ? Direction.buy : (state.direction ?? Direction.buy);
    } else {
      resolvedDirection = reset ? null : state.direction;
    }

    final Karat? resolvedPurity;
    if (type == RequestType.goldBullion && (reset || state.purityKarat == null)) {
      resolvedPurity = Karat.k24;
    } else {
      resolvedPurity = reset ? null : state.purityKarat;
    }

    final bool resolvedWeightApproximate = combinedDetailsAndImages
        ? true
        : (reset ? false : state.weightIsApproximate);

    final bool resolvedBudgetFlexible = combinedDetailsAndImages
        ? true
        : (reset ? false : state.budgetIsFlexible);

    state = state.copyWith(
      requestType: type,
      direction: resolvedDirection,
      clearDirection: reset && fixed == null && !buySellChoice,
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
      purityKarat: resolvedPurity,
      weightIsApproximate: resolvedWeightApproximate,
      budgetIsFlexible: resolvedBudgetFlexible,
      step: RequestCreateStep.compose,
      clearFailure: true,
      fieldErrors: const {},
    );
  }

  /// Loads an existing saved draft into the creation flow so the customer
  /// can review, complete missing fields, and publish it.
  void loadFromRequest(RequestForCustomer req) {
    final env = ref.read(envProvider);
    state = state.copyWith(
      draftId: req.id,
      requestType: req.requestType,
      direction: req.direction,
      regionId: req.region.id,
      notes: req.notes ?? '',
      weightGrams: req.weightGrams,
      weightIsApproximate: req.weightIsApproximate,
      purityKarat: req.purityKarat,
      ornamentType: req.ornamentType,
      condition: req.condition,
      denominationGrams: req.denominationGrams,
      quantity: req.quantity,
      mintOrRefiner: req.mintOrRefiner,
      budgetMin: req.budgetMin,
      budgetMax: req.budgetMax,
      budgetIsFlexible: req.budgetIsFlexible,
      media: [
        for (final m in req.media)
          MediaSlot(
            key: m.key,
            contentType: m.contentType,
            remoteUrl: env.resolveUrl(m.displayUrl ?? m.thumbnailUrl),
          ),
      ],
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
  /// Guest: in-memory only — no HTTP (`adr/0011`).
  Future<bool> saveDraft() async {
    if (state.requestType == null) return false;
    if (_isGuest) {
      state = state.copyWith(busy: false, clearFailure: true);
      return true;
    }
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

  /// IO helper for tests / native callers that already have a [File].
  Future<void> addImage(File file, String contentType) async {
    final bytes = await file.readAsBytes();
    final label = file.path.split(RegExp(r'[/\\]')).last;
    await addPickedImage(
      bytes: Uint8List.fromList(bytes),
      filename: label,
      contentType: contentType,
      path: file.path,
    );
  }

  /// Prefer this from pickers — works on web where [PlatformFile.path] is null.
  Future<void> addPickedImage({
    required Uint8List bytes,
    required String filename,
    required String contentType,
    String? path,
  }) async {
    if (state.media.length >= state.maxImages) return;
    if (bytes.isEmpty) return;
    final label = filename.trim().isEmpty ? 'photo.jpg' : filename;
    final token = Object.hash(path ?? label, bytes.length);
    final key = _isGuest ? 'local:$token' : 'pending:$token';

    // Show the picked photo immediately; conversion + upload continue below.
    final placeholder = MediaSlot(
      key: key,
      localLabel: label,
      localPath: path,
      localBytes: bytes,
      contentType: contentType,
      progress: 0,
      uploading: true,
    );
    state = state.copyWith(
      media: [...state.media, placeholder],
      uploading: true,
      clearFailure: true,
    );

    final prepared = await _prepareForUpload(bytes, contentType);
    if (prepared == null) {
      state = state.copyWith(
        uploading: state.media.any((m) => m.key != key && m.uploading),
        media: [
          for (final m in state.media)
            if (m.key == key)
              m.copyWith(
                uploading: false,
                failure: const ServerFailure(
                  message: 'Could not convert that photo. Try another.',
                ),
              )
            else
              m,
        ],
      );
      return;
    }

    // Guest: keep converted bytes until after bind (`adr/0011`).
    if (_isGuest) {
      state = state.copyWith(
        uploading: state.media.any((m) => m.key != key && m.uploading),
        media: [
          for (final m in state.media)
            if (m.key == key)
              m.copyWith(
                uploadBytes: prepared.bytes,
                contentType: prepared.contentType,
                uploading: false,
              )
            else
              m,
        ],
      );
      return;
    }

    state = state.copyWith(
      media: [
        for (final m in state.media)
          if (m.key == key)
            m.copyWith(uploadBytes: prepared.bytes, contentType: prepared.contentType)
          else
            m,
      ],
    );
    await _uploadConvertedSlot(key);
  }

  Future<void> retryFailedMediaAt(int index) async {
    if (index < 0 || index >= state.media.length) return;
    final slot = state.media[index];
    if (slot.failure == null) return;
    final source = slot.localBytes;
    if (source == null || source.isEmpty) return;

    Uint8List? uploadBytes = slot.uploadBytes;
    var contentType = slot.contentType ?? 'image/jpeg';
    if (uploadBytes == null || uploadBytes.isEmpty) {
      final prepared = await _prepareForUpload(source, contentType);
      if (prepared == null) {
        state = state.copyWith(
          media: [
            for (var i = 0; i < state.media.length; i++)
              if (i == index)
                slot.copyWith(
                  failure: const ServerFailure(
                    message: 'Could not convert that photo. Try another.',
                  ),
                )
              else
                state.media[i],
          ],
        );
        return;
      }
      uploadBytes = prepared.bytes;
      contentType = prepared.contentType;
    }

    final retryKey = slot.key.startsWith('pending:') || slot.key.startsWith('local:')
        ? slot.key
        : 'pending:${Object.hash(slot.key, uploadBytes.length)}';
    final next = MediaSlot(
      key: _isGuest ? (slot.key.startsWith('local:') ? slot.key : 'local:$retryKey') : retryKey,
      localLabel: slot.localLabel,
      localPath: slot.localPath,
      localBytes: slot.localBytes,
      uploadBytes: uploadBytes,
      contentType: contentType,
      progress: 0,
      uploading: !_isGuest,
    );
    state = state.copyWith(
      media: [
        for (var i = 0; i < state.media.length; i++)
          if (i == index) next else state.media[i],
      ],
      uploading: !_isGuest,
      clearFailure: true,
    );
    if (_isGuest) return;
    await _uploadConvertedSlot(next.key);
  }

  Future<void> removeMediaAt(int index) async {
    if (index < 0 || index >= state.media.length) return;
    final slot = state.media[index];
    if (slot.key.isNotEmpty &&
        !slot.key.startsWith('pending-') &&
        !slot.key.startsWith('pending:') &&
        !slot.isLocalOnly &&
        !_isGuest) {
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

  void markAwaitingLoginToPublish() {
    state = state.copyWith(awaitingLoginToPublish: true);
  }

  void clearAwaitingLoginToPublish() {
    state = state.copyWith(awaitingLoginToPublish: false);
  }

  /// Create/patch draft + publish. Upload only leftover local slots.
  Future<bool> publish() async {
    state = state.copyWith(busy: true, clearFailure: true, fieldErrors: const {});

    if (state.media.any((m) => m.uploading)) {
      state = state.copyWith(
        busy: false,
        failure: const ValidationFailure(
          message: 'Wait for photos to finish uploading.',
        ),
      );
      return false;
    }

    if (state.media.any((m) => m.isLocalOnly)) {
      final uploaded = await _uploadPendingLocalMedia();
      if (!uploaded) {
        state = state.copyWith(busy: false);
        return false;
      }
    }

    final saved = await saveDraft();
    if (!saved) {
      state = state.copyWith(busy: false);
      return false;
    }
    final id = state.draftId;
    if (id == null) {
      state = state.copyWith(busy: false);
      return false;
    }
    state = state.copyWith(busy: true);
    final key = _ensurePublishKey();
    final result = await _publishWhenMediaReady(id, key);
    return result.when(
      ok: (req) {
        state = state.copyWith(
          busy: false,
          published: req,
          step: RequestCreateStep.success,
          awaitingLoginToPublish: false,
        );
        unawaited(_clearPersistedDraft());
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

  /// Photos upload without waiting for server processing (`READY`), so a
  /// fast publish can see `MEDIA_NOT_READY`; retry with the same idempotency
  /// key — failed attempts are not cached against it.
  Future<Result<RequestForCustomer>> _publishWhenMediaReady(
    String id,
    String idempotencyKey,
  ) async {
    final delay = ref.read(mediaReadyRetryDelayProvider);
    var result = await _repo.publish(id, idempotencyKey: idempotencyKey);
    for (var n = 0;
        n < _mediaReadyMaxRetries &&
            result.failureOrNull?.code == 'MEDIA_NOT_READY';
        n++) {
      await Future<void>.delayed(delay);
      result = await _repo.publish(id, idempotencyKey: idempotencyKey);
    }
    return result;
  }

  /// Flush guest-local AVIF slots (also used after sign-in). Safe to call twice.
  Future<bool> flushPendingLocalMedia() => _uploadPendingLocalMedia();

  Future<bool> _uploadPendingLocalMedia() async {
    final inFlight = _flushInFlight;
    if (inFlight != null) return inFlight;
    final future = _flushLocalMedia();
    _flushInFlight = future;
    try {
      return await future;
    } finally {
      _flushInFlight = null;
    }
  }

  Future<bool> _flushLocalMedia() async {
    if (!state.media.any((m) => m.isLocalOnly)) return true;
    state = state.copyWith(uploading: true);
    for (var i = 0; i < state.media.length; i++) {
      final slot = state.media[i];
      if (!slot.isLocalOnly) continue;
      final key = slot.key;
      Uint8List? avif = slot.uploadBytes;
      if (avif == null || avif.isEmpty) {
        Uint8List? source = slot.localBytes;
        if (source == null && !kIsWeb && slot.localPath != null) {
          try {
            source = Uint8List.fromList(await File(slot.localPath!).readAsBytes());
          } catch (_) {
            source = null;
          }
        }
        if (source == null || source.isEmpty) continue;
        final prepared = await _prepareForUpload(source, slot.contentType ?? 'image/jpeg');
        if (prepared == null) {
          state = state.copyWith(
            uploading: false,
            failure: const ServerFailure(
              message: 'Could not convert that photo. Try another.',
            ),
            media: [
              for (final m in state.media)
                if (m.key == key)
                  m.copyWith(
                    uploading: false,
                    failure: const ServerFailure(
                      message: 'Could not convert that photo. Try another.',
                    ),
                  )
                else
                  m,
            ],
          );
          return false;
        }
        avif = prepared.bytes;
        state = state.copyWith(
          media: [
            for (final m in state.media)
              if (m.key == key)
                m.copyWith(uploadBytes: prepared.bytes, contentType: prepared.contentType)
              else
                m,
          ],
        );
      }
      final ok = await _uploadConvertedSlot(key);
      if (!ok) return false;
    }
    state = state.copyWith(uploading: false);
    return true;
  }

  Future<Uint8List?> _convertToAvif(Uint8List bytes) async {
    try {
      final asset =
          await ref.read(requestImageConverterProvider).convertBytesToAvif(bytes);
      return asset.readBytes();
    } catch (_) {
      return null;
    }
  }

  /// Native: converts to AVIF on-device. Web: the WASM AVIF encoder is the
  /// slowest step in the picker flow, so web uploads the original bytes
  /// as-is and skips it — `REQUEST_IMAGE` already accepts JPEG/PNG/WebP.
  Future<({Uint8List bytes, String contentType})?> _prepareForUpload(
    Uint8List bytes,
    String contentType,
  ) async {
    if (ref.read(isWebPlatformProvider)) {
      return (bytes: bytes, contentType: contentType);
    }
    final converted = await _convertToAvif(bytes);
    if (converted == null) return null;
    return (bytes: converted, contentType: 'image/avif');
  }

  Future<bool> _uploadConvertedSlot(String placeholderKey) async {
    MediaSlot? slot;
    for (final m in state.media) {
      if (m.key == placeholderKey) {
        slot = m;
        break;
      }
    }
    if (slot == null) return false;
    final uploadSlot = slot;
    final avif = uploadSlot.uploadBytes;
    if (avif == null || avif.isEmpty) return false;
    final uploadContentType = uploadSlot.contentType ?? 'image/avif';
    final result = await _repo.uploadRequestImageBytes(
      avif,
      uploadContentType,
      onProgress: (p) {
        state = state.copyWith(
          media: [
            for (final m in state.media)
              if (m.key == placeholderKey) m.copyWith(progress: p) else m,
          ],
        );
      },
    );
    final fail = result.failureOrNull;
    if (fail != null) {
      state = state.copyWith(
        uploading: false,
        failure: fail,
        media: [
          for (final m in state.media)
            if (m.key == placeholderKey)
              m.copyWith(uploading: false, failure: fail)
            else
              m,
        ],
      );
      return false;
    }
    state = state.copyWith(
      uploading: state.media.any((m) => m.key != placeholderKey && m.uploading),
      media: [
        for (final m in state.media)
          if (m.key == placeholderKey)
            MediaSlot(
              key: result.valueOrNull!,
              localLabel: uploadSlot.localLabel,
              localPath: uploadSlot.localPath,
              localBytes: uploadSlot.localBytes,
              uploadBytes: avif,
              contentType: uploadContentType,
            )
          else
            m,
      ],
    );
    await _syncDraftMediaKeys();
    return true;
  }

  Future<void> _syncDraftMediaKeys() async {
    final id = state.draftId;
    if (id == null || _isGuest) return;
    if (state.mediaKeys.isEmpty) return;
    final result = await _repo.patchDraft(id, draftBody());
    result.when(
      ok: (saved) {
        state = state.copyWith(warnings: saved.warnings);
      },
      err: (_) {},
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

  /// After Guest → Login: Customer auto-publishes; Vendor drops the draft.
  Future<bool> onSessionReadyForPublish() async {
    final session = ref.read(sessionProvider);
    if (session is! SignedIn) return false;
    if (!state.awaitingLoginToPublish) return false;
    if (session.isVendor) {
      resetFlow();
      return false;
    }
    if (!session.isCustomer) return false;
    await _refreshMeState();
    return publish();
  }

  void resetFlow() {
    final keep = state;
    state = RequestCreateState(
      canCreateRequest: keep.canCreateRequest,
      oauthBound: keep.oauthBound,
      config: keep.config,
      rates: keep.rates,
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
      final q = state.quantity ?? 1;
      if (d == null) return null;
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


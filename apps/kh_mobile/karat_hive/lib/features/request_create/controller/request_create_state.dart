import 'dart:typed_data';

import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

enum RequestCreateStep { type, compose, images, review, success }

enum BudgetMode { maxOnly, range }

class MediaSlot {
  const MediaSlot({
    required this.key,
    this.localLabel,
    this.localPath,
    this.localBytes,
    this.uploadBytes,
    this.contentType,
    this.remoteUrl,
    this.progress = 1,
    this.uploading = false,
    this.failure,
  });

  final String key;
  final String? localLabel;
  /// Absolute path for Guest-deferred upload on IO platforms (`adr/0011`).
  final String? localPath;
  /// Original pick bytes for thumbnails (`Image.memory` cannot decode AVIF).
  final Uint8List? localBytes;
  /// Converted AVIF bytes ready to upload.
  final Uint8List? uploadBytes;
  final String? contentType;
  /// Resolved URL for a slot loaded from an already-uploaded Request (e.g.
  /// resuming a saved draft) — no local bytes/path exist for these.
  final String? remoteUrl;
  final double progress;
  final bool uploading;
  final Failure? failure;

  bool get isLocalOnly =>
      (localPath != null || localBytes != null) &&
      (key.startsWith('local:') ||
          key.startsWith('pending:') ||
          key.startsWith('pending-'));

  MediaSlot copyWith({
    String? key,
    String? localLabel,
    String? localPath,
    Uint8List? localBytes,
    Uint8List? uploadBytes,
    String? contentType,
    String? remoteUrl,
    double? progress,
    bool? uploading,
    Failure? failure,
    bool clearFailure = false,
    bool clearLocal = false,
  }) =>
      MediaSlot(
        key: key ?? this.key,
        localLabel: localLabel ?? this.localLabel,
        localPath: clearLocal ? null : (localPath ?? this.localPath),
        localBytes: clearLocal ? null : (localBytes ?? this.localBytes),
        uploadBytes: clearLocal ? null : (uploadBytes ?? this.uploadBytes),
        contentType: clearLocal ? null : (contentType ?? this.contentType),
        remoteUrl: remoteUrl ?? this.remoteUrl,
        progress: progress ?? this.progress,
        uploading: uploading ?? this.uploading,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}

class RequestCreateState {
  const RequestCreateState({
    this.step = RequestCreateStep.type,
    this.requestType,
    this.direction,
    this.draftId,
    this.categoryId,
    this.regionId,
    this.notes = '',
    this.weightGrams,
    this.weightIsApproximate = false,
    this.purityKarat,
    this.ornamentType,
    this.condition,
    this.denominationGrams,
    this.quantity,
    this.mintOrRefiner,
    this.budgetMode = BudgetMode.maxOnly,
    this.budgetMin,
    this.budgetMax,
    this.budgetIsFlexible = false,
    this.gemstonesPresent = false,
    this.gemstoneType,
    this.gemstoneCount,
    this.hasInvoice = false,
    this.packagingSealed,
    this.hasAssayCertificate = false,
    this.media = const [],
    this.warnings = const [],
    this.fieldErrors = const {},
    this.failure,
    this.busy = false,
    this.lookupsLoading = false,
    this.lookupsReady = false,
    this.config,
    this.rates,
    this.categories = const [],
    this.regions = const [],
    this.canCreateRequest = true,
    this.oauthBound = false,
    this.publishIdempotencyKey,
    this.published,
    this.uploading = false,
    this.awaitingLoginToPublish = false,
  });

  final RequestCreateStep step;
  final RequestType? requestType;
  final Direction? direction;
  final String? draftId;
  final String? categoryId;
  final String? regionId;
  final String notes;
  final String? weightGrams;
  final bool weightIsApproximate;
  final Karat? purityKarat;
  final OrnamentType? ornamentType;
  final ItemCondition? condition;
  final String? denominationGrams;
  final int? quantity;
  final String? mintOrRefiner;
  final BudgetMode budgetMode;
  final String? budgetMin;
  final String? budgetMax;
  final bool budgetIsFlexible;
  final bool gemstonesPresent;
  final String? gemstoneType;
  final int? gemstoneCount;
  final bool hasInvoice;
  final bool? packagingSealed;
  final bool hasAssayCertificate;
  final List<MediaSlot> media;
  final List<String> warnings;
  final Map<String, String> fieldErrors;
  final Failure? failure;
  final bool busy;
  final bool lookupsLoading;
  final bool lookupsReady;
  final PlatformConfig? config;
  final GoldRateSnapshot? rates;
  final List<TaxonomyNode> categories;
  final List<TaxonomyNode> regions;
  final bool canCreateRequest;
  final bool oauthBound;
  final String? publishIdempotencyKey;
  final RequestForCustomer? published;
  final bool uploading;
  /// Guest tapped Publish — after Customer bind, auto-publish (`adr/0011`).
  final bool awaitingLoginToPublish;

  bool get capBlocked => !canCreateRequest;

  bool get imagesRequired {
    final t = requestType;
    if (t == RequestType.findOrnament || t == RequestType.sellOldGold) {
      return true;
    }
    return direction == Direction.sell;
  }

  /// Server media keys only (excludes Guest-local / in-flight placeholders).
  List<String> get mediaKeys => media
      .where((m) =>
          m.key.isNotEmpty &&
          !m.key.startsWith('local:') &&
          !m.key.startsWith('pending:') &&
          !m.key.startsWith('pending-'))
      .map((m) => m.key)
      .toList();

  bool get hasFailedMedia => media.any((m) => m.failure != null);

  bool get mediaInFlight =>
      uploading || media.any((m) => m.uploading);

  /// Guest: photos attached, none failed/in-flight (local AVIF is OK).
  /// Signed-in publish uses [mediaKeysReady] instead.
  bool get photosAttachedReady {
    if (mediaInFlight || hasFailedMedia) return false;
    if (imagesRequired && media.isEmpty) return false;
    return true;
  }

  /// Signed-in: every slot has a READY server key.
  bool get mediaKeysReady {
    if (!photosAttachedReady) return false;
    if (media.any((m) => m.isLocalOnly)) return false;
    if (imagesRequired && mediaKeys.isEmpty) return false;
    return true;
  }

  int get maxImages => config?.maxRequestImages ?? 5;

  String? fieldError(String key) => fieldErrors[key] ?? fieldErrors['body.$key'];

  RequestCreateState copyWith({
    RequestCreateStep? step,
    RequestType? requestType,
    Direction? direction,
    String? draftId,
    String? categoryId,
    String? regionId,
    String? notes,
    String? weightGrams,
    bool? weightIsApproximate,
    Karat? purityKarat,
    OrnamentType? ornamentType,
    ItemCondition? condition,
    String? denominationGrams,
    int? quantity,
    String? mintOrRefiner,
    BudgetMode? budgetMode,
    String? budgetMin,
    String? budgetMax,
    bool? budgetIsFlexible,
    bool? gemstonesPresent,
    String? gemstoneType,
    int? gemstoneCount,
    bool? hasInvoice,
    bool? packagingSealed,
    bool? hasAssayCertificate,
    List<MediaSlot>? media,
    List<String>? warnings,
    Map<String, String>? fieldErrors,
    Failure? failure,
    bool? busy,
    bool? lookupsLoading,
    bool? lookupsReady,
    PlatformConfig? config,
    GoldRateSnapshot? rates,
    List<TaxonomyNode>? categories,
    List<TaxonomyNode>? regions,
    bool? canCreateRequest,
    bool? oauthBound,
    String? publishIdempotencyKey,
    RequestForCustomer? published,
    bool? uploading,
    bool? awaitingLoginToPublish,
    bool clearType = false,
    bool clearDirection = false,
    bool clearFailure = false,
    bool clearDraft = false,
    bool clearPublished = false,
    bool clearWeight = false,
    bool clearPurity = false,
    bool clearOrnament = false,
    bool clearCondition = false,
    bool clearDenomination = false,
    bool clearQuantity = false,
    bool clearMint = false,
    bool clearBudgetMin = false,
    bool clearBudgetMax = false,
    bool clearGemstoneType = false,
    bool clearPackaging = false,
  }) =>
      RequestCreateState(
        step: step ?? this.step,
        requestType: clearType ? null : (requestType ?? this.requestType),
        direction: clearDirection ? null : (direction ?? this.direction),
        draftId: clearDraft ? null : (draftId ?? this.draftId),
        categoryId: categoryId ?? this.categoryId,
        regionId: regionId ?? this.regionId,
        notes: notes ?? this.notes,
        weightGrams: clearWeight ? null : (weightGrams ?? this.weightGrams),
        weightIsApproximate:
            weightIsApproximate ?? this.weightIsApproximate,
        purityKarat: clearPurity ? null : (purityKarat ?? this.purityKarat),
        ornamentType:
            clearOrnament ? null : (ornamentType ?? this.ornamentType),
        condition: clearCondition ? null : (condition ?? this.condition),
        denominationGrams: clearDenomination
            ? null
            : (denominationGrams ?? this.denominationGrams),
        quantity: clearQuantity ? null : (quantity ?? this.quantity),
        mintOrRefiner: clearMint ? null : (mintOrRefiner ?? this.mintOrRefiner),
        budgetMode: budgetMode ?? this.budgetMode,
        budgetMin: clearBudgetMin ? null : (budgetMin ?? this.budgetMin),
        budgetMax: clearBudgetMax ? null : (budgetMax ?? this.budgetMax),
        budgetIsFlexible: budgetIsFlexible ?? this.budgetIsFlexible,
        gemstonesPresent: gemstonesPresent ?? this.gemstonesPresent,
        gemstoneType:
            clearGemstoneType ? null : (gemstoneType ?? this.gemstoneType),
        gemstoneCount: gemstoneCount ?? this.gemstoneCount,
        hasInvoice: hasInvoice ?? this.hasInvoice,
        packagingSealed:
            clearPackaging ? null : (packagingSealed ?? this.packagingSealed),
        hasAssayCertificate:
            hasAssayCertificate ?? this.hasAssayCertificate,
        media: media ?? this.media,
        warnings: warnings ?? this.warnings,
        fieldErrors: fieldErrors ?? this.fieldErrors,
        failure: clearFailure ? null : (failure ?? this.failure),
        busy: busy ?? this.busy,
        lookupsLoading: lookupsLoading ?? this.lookupsLoading,
        lookupsReady: lookupsReady ?? this.lookupsReady,
        config: config ?? this.config,
        rates: rates ?? this.rates,
        categories: categories ?? this.categories,
        regions: regions ?? this.regions,
        canCreateRequest: canCreateRequest ?? this.canCreateRequest,
        oauthBound: oauthBound ?? this.oauthBound,
        publishIdempotencyKey:
            publishIdempotencyKey ?? this.publishIdempotencyKey,
        published: clearPublished ? null : (published ?? this.published),
        uploading: uploading ?? this.uploading,
        awaitingLoginToPublish:
            awaitingLoginToPublish ?? this.awaitingLoginToPublish,
      );
}

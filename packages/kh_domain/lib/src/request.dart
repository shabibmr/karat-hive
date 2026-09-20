import 'package:freezed_annotation/freezed_annotation.dart';

import 'party.dart';

part 'request.freezed.dart';
part 'request.g.dart';

enum RequestType {
  findOrnament,
  sellOldGold,
  goldCoin,
  goldBullion,
  unknown;

  static RequestType parse(String? raw) => switch (raw) {
        'FIND_ORNAMENT' => findOrnament,
        'SELL_OLD_GOLD' => sellOldGold,
        'GOLD_COIN' => goldCoin,
        'GOLD_BULLION' => goldBullion,
        _ => unknown,
      };

  String get wire => switch (this) {
        findOrnament => 'FIND_ORNAMENT',
        sellOldGold => 'SELL_OLD_GOLD',
        goldCoin => 'GOLD_COIN',
        goldBullion => 'GOLD_BULLION',
        unknown => 'UNKNOWN',
      };
}

enum Direction {
  buy,
  sell,
  unknown;

  static Direction parse(String? raw) => switch (raw) {
        'BUY' => buy,
        'SELL' => sell,
        _ => unknown,
      };

  String get wire => switch (this) {
        buy => 'BUY',
        sell => 'SELL',
        unknown => 'UNKNOWN',
      };
}

enum RequestState {
  draft,
  published,
  accepted,
  closed,
  expired,
  cancelled,
  removed,
  unknown;

  static RequestState parse(String? raw) => switch (raw) {
        'DRAFT' => draft,
        'PUBLISHED' => published,
        'ACCEPTED' => accepted,
        'CLOSED' => closed,
        'EXPIRED' => expired,
        'CANCELLED' => cancelled,
        'REMOVED' => removed,
        _ => unknown,
      };

  String get wire => switch (this) {
        draft => 'DRAFT',
        published => 'PUBLISHED',
        accepted => 'ACCEPTED',
        closed => 'CLOSED',
        expired => 'EXPIRED',
        cancelled => 'CANCELLED',
        removed => 'REMOVED',
        unknown => 'UNKNOWN',
      };
}

enum Karat {
  k24,
  k22,
  k21,
  k18,
  unknown;

  static Karat parse(String? raw) => switch (raw) {
        '24K' => k24,
        '22K' => k22,
        '21K' => k21,
        '18K' => k18,
        _ => unknown,
      };

  String get wire => switch (this) {
        k24 => '24K',
        k22 => '22K',
        k21 => '21K',
        k18 => '18K',
        unknown => 'UNKNOWN',
      };
}

enum OrnamentType {
  ring,
  chain,
  bangle,
  necklace,
  earring,
  bracelet,
  pendant,
  other,
  unknown;

  static OrnamentType parse(String? raw) => switch (raw) {
        'RING' => ring,
        'CHAIN' => chain,
        'BANGLE' => bangle,
        'NECKLACE' => necklace,
        'EARRING' => earring,
        'BRACELET' => bracelet,
        'PENDANT' => pendant,
        'OTHER' => other,
        _ => unknown,
      };

  String get wire => switch (this) {
        ring => 'RING',
        chain => 'CHAIN',
        bangle => 'BANGLE',
        necklace => 'NECKLACE',
        earring => 'EARRING',
        bracelet => 'BRACELET',
        pendant => 'PENDANT',
        other => 'OTHER',
        unknown => 'UNKNOWN',
      };
}

enum ItemCondition {
  brandNew,
  likeNew,
  used,
  damaged,
  unknown;

  static ItemCondition parse(String? raw) => switch (raw) {
        'NEW' => brandNew,
        'LIKE_NEW' => likeNew,
        'USED' => used,
        'DAMAGED' => damaged,
        _ => unknown,
      };

  String get wire => switch (this) {
        brandNew => 'NEW',
        likeNew => 'LIKE_NEW',
        used => 'USED',
        damaged => 'DAMAGED',
        unknown => 'UNKNOWN',
      };
}

enum MediaPurpose {
  requestImage,
  offerImage,
  profilePhoto,
  vendorLogo,
  vendorShopPhoto,
  kycDocument,
  exportArtefact,
  unknown;

  static MediaPurpose parse(String? raw) => switch (raw) {
        'REQUEST_IMAGE' => requestImage,
        'OFFER_IMAGE' => offerImage,
        'PROFILE_PHOTO' => profilePhoto,
        'VENDOR_LOGO' => vendorLogo,
        'VENDOR_SHOP_PHOTO' => vendorShopPhoto,
        'KYC_DOCUMENT' => kycDocument,
        'EXPORT_ARTEFACT' => exportArtefact,
        _ => unknown,
      };

  String get wire => switch (this) {
        requestImage => 'REQUEST_IMAGE',
        offerImage => 'OFFER_IMAGE',
        profilePhoto => 'PROFILE_PHOTO',
        vendorLogo => 'VENDOR_LOGO',
        vendorShopPhoto => 'VENDOR_SHOP_PHOTO',
        kycDocument => 'KYC_DOCUMENT',
        exportArtefact => 'EXPORT_ARTEFACT',
        unknown => 'UNKNOWN',
      };
}

enum MediaState {
  pendingUpload,
  pendingProcessing,
  ready,
  quarantined,
  failed,
  unknown;

  static MediaState parse(String? raw) => switch (raw) {
        'PENDING_UPLOAD' => pendingUpload,
        'PENDING_PROCESSING' => pendingProcessing,
        'READY' => ready,
        'QUARANTINED' => quarantined,
        'FAILED' => failed,
        _ => unknown,
      };

  String get wire => switch (this) {
        pendingUpload => 'PENDING_UPLOAD',
        pendingProcessing => 'PENDING_PROCESSING',
        ready => 'READY',
        quarantined => 'QUARANTINED',
        failed => 'FAILED',
        unknown => 'UNKNOWN',
      };
}

class _MediaStateConverter implements JsonConverter<MediaState, String?> {
  const _MediaStateConverter();

  @override
  MediaState fromJson(String? json) => MediaState.parse(json);

  @override
  String toJson(MediaState object) => object.wire;
}

class _MediaPurposeConverter implements JsonConverter<MediaPurpose, String?> {
  const _MediaPurposeConverter();

  @override
  MediaPurpose fromJson(String? json) => MediaPurpose.parse(json);

  @override
  String toJson(MediaPurpose object) => object.wire;
}

Map<String, dynamic> _normalizeMediaRefJson(Map<String, dynamic> json) => {
      'id': json['id'] as String? ?? '',
      'key': json['key'] as String? ?? '',
      'state': json['state']?.toString(),
      'purpose': json['purpose']?.toString(),
      'contentType': json['contentType'] as String? ?? '',
      'byteSize': (json['byteSize'] as num?)?.toInt() ?? 0,
      'displayOrder': (json['displayOrder'] as num?)?.toInt() ?? 0,
      'thumbnailUrl': json['thumbnailUrl'] as String?,
      'displayUrl': json['displayUrl'] as String?,
    };

@freezed
abstract class MediaRef with _$MediaRef {
  const factory MediaRef({
    required String id,
    required String key,
    @_MediaStateConverter() required MediaState state,
    @_MediaPurposeConverter() required MediaPurpose purpose,
    required String contentType,
    required int byteSize,
    required int displayOrder,
    String? thumbnailUrl,
    String? displayUrl,
  }) = _MediaRef;

  factory MediaRef.fromJson(Map<String, dynamic> json) =>
      _$MediaRefFromJson(_normalizeMediaRefJson(json));
}

DateTime? _dt(Object? raw) {
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  return null;
}

Map<String, dynamic> _map(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

class _RequestTypeConverter implements JsonConverter<RequestType, String?> {
  const _RequestTypeConverter();

  @override
  RequestType fromJson(String? json) => RequestType.parse(json);

  @override
  String toJson(RequestType object) => object.wire;
}

class _DirectionConverter implements JsonConverter<Direction, String?> {
  const _DirectionConverter();

  @override
  Direction fromJson(String? json) => Direction.parse(json);

  @override
  String toJson(Direction object) => object.wire;
}

class _RequestStateConverter implements JsonConverter<RequestState, String?> {
  const _RequestStateConverter();

  @override
  RequestState fromJson(String? json) => RequestState.parse(json);

  @override
  String toJson(RequestState object) => object.wire;
}

class _NullableKaratConverter implements JsonConverter<Karat?, String?> {
  const _NullableKaratConverter();

  @override
  Karat? fromJson(String? json) => json == null ? null : Karat.parse(json);

  @override
  String? toJson(Karat? object) => object?.wire;
}

class _NullableOrnamentTypeConverter
    implements JsonConverter<OrnamentType?, String?> {
  const _NullableOrnamentTypeConverter();

  @override
  OrnamentType? fromJson(String? json) =>
      json == null ? null : OrnamentType.parse(json);

  @override
  String? toJson(OrnamentType? object) => object?.wire;
}

class _NullableItemConditionConverter
    implements JsonConverter<ItemCondition?, String?> {
  const _NullableItemConditionConverter();

  @override
  ItemCondition? fromJson(String? json) =>
      json == null ? null : ItemCondition.parse(json);

  @override
  String? toJson(ItemCondition? object) => object?.wire;
}

Map<String, dynamic> _normalizeRequestForCustomerJson(
    Map<String, dynamic> json) {
  final mediaRaw = json['media'] as List? ?? const [];
  return {
    ...json,
    'requestType': json['requestType']?.toString(),
    'direction': json['direction']?.toString(),
    'state': json['state']?.toString(),
    'category': _map(json['category']),
    'region': _map(json['region']),
    'weightGrams': json['weightGrams']?.toString(),
    'weightIsApproximate': json['weightIsApproximate'] as bool? ?? false,
    'purityKarat': json['purityKarat']?.toString(),
    'ornamentType': json['ornamentType']?.toString(),
    'condition': json['condition']?.toString(),
    'denominationGrams': json['denominationGrams']?.toString(),
    'budgetMin': json['budgetMin']?.toString(),
    'budgetMax': json['budgetMax']?.toString(),
    'budgetIsFlexible': json['budgetIsFlexible'] as bool? ?? false,
    'indicativeValue': json['indicativeValue']?.toString(),
    'publishedAt': _dt(json['publishedAt'])?.toIso8601String(),
    'expiresAt': _dt(json['expiresAt'])?.toIso8601String(),
    'offerCount': (json['offerCount'] as num?)?.toInt() ?? 0,
    'media': mediaRaw.map((e) => _map(e)).toList(growable: false),
    'createdAt':
        (_dt(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0))
            .toIso8601String(),
    'updatedAt':
        (_dt(json['updatedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0))
            .toIso8601String(),
  };
}

/// Owner presenter (`RequestForCustomer`). No Vendor identity fields.
@freezed
abstract class RequestForCustomer with _$RequestForCustomer {
  const factory RequestForCustomer({
    required String id,
    @_RequestTypeConverter() required RequestType requestType,
    @_DirectionConverter() required Direction direction,
    @_RequestStateConverter() required RequestState state,
    required CategorySummary category,
    required RegionSummary region,
    required bool weightIsApproximate,
    required bool budgetIsFlexible,
    required int offerCount,
    required List<MediaRef> media,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? reference,
    String? notes,
    String? weightGrams,
    @_NullableKaratConverter() Karat? purityKarat,
    @_NullableOrnamentTypeConverter() OrnamentType? ornamentType,
    @_NullableItemConditionConverter() ItemCondition? condition,
    String? denominationGrams,
    int? quantity,
    String? mintOrRefiner,
    String? budgetMin,
    String? budgetMax,
    String? indicativeValue,
    DateTime? publishedAt,
    DateTime? expiresAt,
    String? cancellationReason,
    String? acceptedOfferId,

    /// Absent on the wire → UI hides the unread marker (CM-K01 / SAM-GAP-1).
    int? unreadOfferCount,

    /// Absent unless ACCEPTED and the Connection join is present (SAM-GAP-3).
    String? connectionId,
  }) = _RequestForCustomer;

  factory RequestForCustomer.fromJson(Map<String, dynamic> json) =>
      _$RequestForCustomerFromJson(_normalizeRequestForCustomerJson(json));
}

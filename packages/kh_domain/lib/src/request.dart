import 'party.dart';

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
  offersReceived,
  accepted,
  closed,
  expired,
  cancelled,
  removed,
  unknown;

  static RequestState parse(String? raw) => switch (raw) {
        'DRAFT' => draft,
        'PUBLISHED' => published,
        'OFFERS_RECEIVED' => offersReceived,
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
        offersReceived => 'OFFERS_RECEIVED',
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
}

class MediaRef {
  const MediaRef({
    required this.id,
    required this.key,
    required this.state,
    required this.purpose,
    required this.contentType,
    required this.byteSize,
    required this.displayOrder,
    this.thumbnailUrl,
    this.displayUrl,
  });

  final String id;
  final String key;
  final MediaState state;
  final MediaPurpose purpose;
  final String contentType;
  final int byteSize;
  final int displayOrder;
  final String? thumbnailUrl;
  final String? displayUrl;

  static MediaRef fromJson(Map<String, dynamic> j) => MediaRef(
        id: j['id'] as String? ?? '',
        key: j['key'] as String? ?? '',
        state: MediaState.parse(j['state'] as String?),
        purpose: MediaPurpose.parse(j['purpose'] as String?),
        contentType: j['contentType'] as String? ?? '',
        byteSize: (j['byteSize'] as num?)?.toInt() ?? 0,
        displayOrder: (j['displayOrder'] as num?)?.toInt() ?? 0,
        thumbnailUrl: j['thumbnailUrl'] as String?,
        displayUrl: j['displayUrl'] as String?,
      );
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

/// Owner presenter (`RequestForCustomer`). No Vendor identity fields.
class RequestForCustomer {
  const RequestForCustomer({
    required this.id,
    required this.requestType,
    required this.direction,
    required this.state,
    required this.category,
    required this.region,
    required this.weightIsApproximate,
    required this.budgetIsFlexible,
    required this.offerCount,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
    this.reference,
    this.notes,
    this.weightGrams,
    this.purityKarat,
    this.ornamentType,
    this.condition,
    this.denominationGrams,
    this.quantity,
    this.mintOrRefiner,
    this.budgetMin,
    this.budgetMax,
    this.indicativeValue,
    this.publishedAt,
    this.expiresAt,
    this.cancellationReason,
    this.acceptedOfferId,
    this.unreadOfferCount,
    this.connectionId,
  });

  final String id;
  final String? reference;
  final RequestType requestType;
  final Direction direction;
  final RequestState state;
  final CategorySummary category;
  final RegionSummary region;
  final String? notes;
  final String? weightGrams;
  final bool weightIsApproximate;
  final Karat? purityKarat;
  final OrnamentType? ornamentType;
  final ItemCondition? condition;
  final String? denominationGrams;
  final int? quantity;
  final String? mintOrRefiner;
  final String? budgetMin;
  final String? budgetMax;
  final bool budgetIsFlexible;
  final String? indicativeValue;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final int offerCount;
  final List<MediaRef> media;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cancellationReason;
  final String? acceptedOfferId;

  /// Absent on the wire → UI hides the unread marker (CM-K01 / SAM-GAP-1).
  final int? unreadOfferCount;

  /// Absent unless ACCEPTED and the Connection join is present (SAM-GAP-3).
  final String? connectionId;

  static RequestForCustomer fromJson(Map<String, dynamic> j) {
    final mediaRaw = j['media'] as List? ?? const [];
    return RequestForCustomer(
      id: j['id'] as String,
      reference: j['reference'] as String?,
      requestType: RequestType.parse(j['requestType'] as String?),
      direction: Direction.parse(j['direction'] as String?),
      state: RequestState.parse(j['state'] as String?),
      category: CategorySummary.fromJson(_map(j['category'])),
      region: RegionSummary.fromJson(_map(j['region'])),
      notes: j['notes'] as String?,
      weightGrams: j['weightGrams']?.toString(),
      weightIsApproximate: j['weightIsApproximate'] as bool? ?? false,
      purityKarat: j['purityKarat'] == null
          ? null
          : Karat.parse(j['purityKarat'] as String?),
      ornamentType: j['ornamentType'] == null
          ? null
          : OrnamentType.parse(j['ornamentType'] as String?),
      condition: j['condition'] == null
          ? null
          : ItemCondition.parse(j['condition'] as String?),
      denominationGrams: j['denominationGrams']?.toString(),
      quantity: (j['quantity'] as num?)?.toInt(),
      mintOrRefiner: j['mintOrRefiner'] as String?,
      budgetMin: j['budgetMin']?.toString(),
      budgetMax: j['budgetMax']?.toString(),
      budgetIsFlexible: j['budgetIsFlexible'] as bool? ?? false,
      indicativeValue: j['indicativeValue']?.toString(),
      publishedAt: _dt(j['publishedAt']),
      expiresAt: _dt(j['expiresAt']),
      offerCount: (j['offerCount'] as num?)?.toInt() ?? 0,
      media: mediaRaw
          .map((e) => MediaRef.fromJson(_map(e)))
          .toList(growable: false),
      createdAt: _dt(j['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _dt(j['updatedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      cancellationReason: j['cancellationReason'] as String?,
      acceptedOfferId: j['acceptedOfferId'] as String?,
      unreadOfferCount: (j['unreadOfferCount'] as num?)?.toInt(),
      connectionId: j['connectionId'] as String?,
    );
  }
}

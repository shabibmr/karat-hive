import 'common_dtos.dart';

/// `connection.presenter.ts` `TalkDto` — the embedded WhatsApp / call deep-link
/// payload (`C-03`, SRS §7.2). `waUrl` is an outbound `wa.me` link only.
class TalkDto {
  const TalkDto({
    required this.available,
    required this.waUrl,
    required this.phone,
    required this.callUrl,
  });

  final bool available;
  final String waUrl;
  final String phone;
  final String callUrl;

  static TalkDto fromJson(Map<String, dynamic> j) => TalkDto(
        available: j['available'] as bool? ?? false,
        waUrl: j['waUrl'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        callUrl: j['callUrl'] as String? ?? '',
      );
}

/// The **revealed** vendor on a Customer's Connection (`connection.presenter.ts`
/// `ConnectionForCustomer.vendor`). Distinct from [MaskedVendorDto]: identity is
/// present because the payload is only reachable through an accepted Connection
/// the viewer is party to (`BR-007`, `AD-FE-07`).
class RevealedVendorDto {
  const RevealedVendorDto({
    required this.id,
    required this.legalBusinessName,
    required this.tradingName,
    required this.tradeLicenceNumber,
    required this.phone,
    required this.connectionCount,
    this.region,
    this.rating,
  });

  final String id;
  final String legalBusinessName;
  final String tradingName;
  final String tradeLicenceNumber;
  final String phone;
  final int connectionCount;
  final RegionSummaryDto? region;
  final RatingSummaryDto? rating;

  static RevealedVendorDto fromJson(Map<String, dynamic> j) => RevealedVendorDto(
        id: j['id'] as String? ?? '',
        legalBusinessName: j['legalBusinessName'] as String? ?? '',
        tradingName: j['tradingName'] as String? ?? '',
        tradeLicenceNumber: j['tradeLicenceNumber'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        connectionCount: j['connectionCount'] as int? ?? 0,
        region: j['region'] == null
            ? null
            : RegionSummaryDto.fromJson(j['region'] as Map<String, dynamic>),
        rating: RatingSummaryDto.fromJson(j['rating'] as Map<String, dynamic>?),
      );
}

class ConnectionOfferDto {
  const ConnectionOfferDto({
    required this.id,
    required this.offeredPrice,
    this.makingCharges,
    this.ratePerGram,
    required this.validityHours,
    this.deliveryTimeframe,
    this.warrantyTerms,
    this.vendorNote,
  });

  final String id;
  final String offeredPrice;
  final String? makingCharges;
  final String? ratePerGram;
  final int validityHours;
  final String? deliveryTimeframe;
  final String? warrantyTerms;
  final String? vendorNote;

  static ConnectionOfferDto fromJson(Map<String, dynamic> j) => ConnectionOfferDto(
        id: j['id'] as String? ?? '',
        offeredPrice: (j['offeredPrice'] ?? '0').toString(),
        makingCharges: j['makingCharges']?.toString(),
        ratePerGram: j['ratePerGram']?.toString(),
        validityHours: j['validityHours'] as int? ?? 0,
        deliveryTimeframe: j['deliveryTimeframe'] as String?,
        warrantyTerms: j['warrantyTerms'] as String?,
        vendorNote: j['vendorNote'] as String?,
      );
}

class ConnectionRequestRefDto {
  const ConnectionRequestRefDto({
    required this.id,
    this.reference,
    required this.requestType,
    required this.direction,
    required this.category,
    required this.region,
  });

  final String id;
  final String? reference;
  final String requestType;
  final String direction;
  final CategorySummaryDto category;
  final RegionSummaryDto region;

  static ConnectionRequestRefDto fromJson(Map<String, dynamic> j) =>
      ConnectionRequestRefDto(
        id: j['id'] as String? ?? '',
        reference: j['reference'] as String?,
        requestType: j['requestType'] as String? ?? '',
        direction: j['direction'] as String? ?? '',
        category: CategorySummaryDto.fromJson(
            (j['category'] as Map<String, dynamic>?) ?? const {}),
        region: RegionSummaryDto.fromJson(
            (j['region'] as Map<String, dynamic>?) ?? const {}),
      );
}

/// `connection.presenter.ts` `ConnectionForCustomer`. Backs `CUS-S15`,
/// `CUS-S16`, `CUS-S18`.
class CustomerConnectionDto {
  const CustomerConnectionDto({
    required this.id,
    required this.offerId,
    required this.requestId,
    required this.state,
    required this.identityRevealedAt,
    this.closedAt,
    this.closedBy,
    required this.vendor,
    required this.offer,
    required this.request,
    required this.talk,
  });

  final String id;
  final String offerId;
  final String requestId;
  final String state;
  final DateTime identityRevealedAt;
  final DateTime? closedAt;
  final String? closedBy;
  final RevealedVendorDto vendor;
  final ConnectionOfferDto offer;
  final ConnectionRequestRefDto request;
  final TalkDto talk;

  static CustomerConnectionDto fromJson(Map<String, dynamic> j) =>
      CustomerConnectionDto(
        id: j['id'] as String,
        offerId: j['offerId'] as String? ?? '',
        requestId: j['requestId'] as String? ?? '',
        state: j['state'] as String? ?? '',
        identityRevealedAt:
            DateTime.parse(j['identityRevealedAt'] as String),
        closedAt: j['closedAt'] == null
            ? null
            : DateTime.parse(j['closedAt'] as String),
        closedBy: j['closedBy'] as String?,
        vendor: RevealedVendorDto.fromJson(
            (j['vendor'] as Map<String, dynamic>?) ?? const {}),
        offer: ConnectionOfferDto.fromJson(
            (j['offer'] as Map<String, dynamic>?) ?? const {}),
        request: ConnectionRequestRefDto.fromJson(
            (j['request'] as Map<String, dynamic>?) ?? const {}),
        talk: TalkDto.fromJson(
            (j['talk'] as Map<String, dynamic>?) ?? const {}),
      );
}

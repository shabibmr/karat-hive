import 'offer.dart';
import 'party.dart';
import 'request.dart';

enum ConnectionState {
  active,
  closed,
  unknown;

  static ConnectionState parse(String? raw) => switch (raw) {
        'ACTIVE' => active,
        'CLOSED' => closed,
        _ => unknown,
      };

  String get wire => switch (this) {
        active => 'ACTIVE',
        closed => 'CLOSED',
        unknown => 'UNKNOWN',
      };
}

enum ClosedBy {
  customer,
  vendor,
  admin,
  unknown;

  static ClosedBy parse(String? raw) => switch (raw) {
        'CUSTOMER' => customer,
        'VENDOR' => vendor,
        'ADMIN' => admin,
        _ => unknown,
      };
}

class TalkPayload {
  const TalkPayload({
    required this.waUrl,
    required this.mobileNumber,
    required this.available,
    this.prefilledMessage = '',
    this.callUrl = '',
  });

  final String waUrl;
  final String mobileNumber;
  final String prefilledMessage;
  final bool available;
  final String callUrl;

  /// True when the server supplied a usable `wa.me` URL. Widgets must not
  /// invent a URL from [mobileNumber] (C-03).
  bool get canOpenWhatsApp {
    final url = waUrl.trim().toLowerCase();
    return available &&
        (url.startsWith('https://wa.me/') || url.startsWith('http://wa.me/'));
  }

  bool get canCall {
    final url = callUrl.trim().toLowerCase();
    return available && url.startsWith('tel:');
  }

  static TalkPayload fromJson(Map<String, dynamic> j) {
    final mobile = (j['mobileNumber'] ?? j['phone'] ?? '') as String;
    return TalkPayload(
      waUrl: j['waUrl'] as String? ?? '',
      mobileNumber: mobile,
      prefilledMessage: j['prefilledMessage'] as String? ?? '',
      available: j['available'] as bool? ?? false,
      callUrl: j['callUrl'] as String? ?? '',
    );
  }
}

class ConnectionRequestSnapshot {
  const ConnectionRequestSnapshot({
    required this.id,
    required this.requestType,
    required this.direction,
    this.reference,
    this.category,
    this.region,
  });

  final String id;
  final String? reference;
  final RequestType requestType;
  final Direction direction;
  final CategorySummary? category;
  final RegionSummary? region;

  static ConnectionRequestSnapshot fromJson(Map<String, dynamic> j) =>
      ConnectionRequestSnapshot(
        id: j['id'] as String? ?? '',
        reference: j['reference'] as String?,
        requestType: RequestType.parse(j['requestType'] as String?),
        direction: Direction.parse(j['direction'] as String?),
        category: CategorySummary.tryParse(j['category']),
        region: RegionSummary.tryParse(j['region']),
      );
}

class ConnectionAcceptedOffer {
  const ConnectionAcceptedOffer({
    required this.id,
    required this.terms,
    this.submittedAt,
  });

  final String id;
  final OfferTerms terms;
  final DateTime? submittedAt;

  static ConnectionAcceptedOffer fromJson(Map<String, dynamic> j) {
    final nested = j['terms'];
    final termsJson = nested is Map
        ? Map<String, dynamic>.from(nested)
        : j;
    return ConnectionAcceptedOffer(
      id: j['id'] as String? ?? '',
      terms: OfferTerms.fromJson(termsJson),
      submittedAt: j['submittedAt'] is String
          ? DateTime.tryParse(j['submittedAt'] as String)
          : null,
    );
  }
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

/// Customer Connection presenter — the only place revealed Vendor fields exist (BR-007).
class ConnectionForCustomer {
  const ConnectionForCustomer({
    required this.id,
    required this.state,
    required this.vendor,
    required this.talk,
    required this.identityRevealedAt,
    this.request,
    this.acceptedOffer,
    this.closedAt,
    this.closedBy,
    this.offerId,
    this.requestId,
    this.createdAt,
  });

  final String id;
  final ConnectionState state;
  final RevealedParty vendor;
  final TalkPayload talk;
  final DateTime identityRevealedAt;
  final ConnectionRequestSnapshot? request;
  final ConnectionAcceptedOffer? acceptedOffer;
  final DateTime? closedAt;
  final ClosedBy? closedBy;
  final String? offerId;
  final String? requestId;
  final DateTime? createdAt;

  static ConnectionForCustomer fromJson(Map<String, dynamic> j) {
    final accepted = j['acceptedOffer'] ?? j['offer'];
    return ConnectionForCustomer(
      id: j['id'] as String,
      state: ConnectionState.parse(j['state'] as String?),
      vendor: RevealedParty.fromVendorJson(_map(j['vendor'])),
      talk: TalkPayload.fromJson(_map(j['talk'])),
      identityRevealedAt:
          _dt(j['identityRevealedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      request: j['request'] == null
          ? null
          : ConnectionRequestSnapshot.fromJson(_map(j['request'])),
      acceptedOffer: accepted == null
          ? null
          : ConnectionAcceptedOffer.fromJson(_map(accepted)),
      closedAt: _dt(j['closedAt']),
      closedBy: j['closedBy'] == null ? null : ClosedBy.parse(j['closedBy'] as String?),
      offerId: j['offerId'] as String?,
      requestId: j['requestId'] as String?,
      createdAt: _dt(j['createdAt']),
    );
  }
}

/// Vendor Connection presenter — the only place revealed Customer fields exist
/// (BR-007). Must never carry a competing Vendor's identity or price (BR-008).
class ConnectionForVendor {
  const ConnectionForVendor({
    required this.id,
    required this.state,
    required this.customer,
    required this.talk,
    required this.identityRevealedAt,
    this.request,
    this.acceptedOffer,
    this.closedAt,
    this.closedBy,
    this.offerId,
    this.requestId,
    this.createdAt,
  });

  final String id;
  final ConnectionState state;
  final RevealedParty customer;
  final TalkPayload talk;
  final DateTime identityRevealedAt;
  final ConnectionRequestSnapshot? request;
  final ConnectionAcceptedOffer? acceptedOffer;
  final DateTime? closedAt;
  final ClosedBy? closedBy;
  final String? offerId;
  final String? requestId;
  final DateTime? createdAt;

  DateTime get connectedAt => createdAt ?? identityRevealedAt;

  static ConnectionForVendor fromJson(Map<String, dynamic> j) {
    final accepted = j['acceptedOffer'] ?? j['offer'];
    return ConnectionForVendor(
      id: j['id'] as String,
      state: ConnectionState.parse(j['state'] as String?),
      customer: RevealedParty.fromCustomerJson(_map(j['customer'])),
      talk: TalkPayload.fromJson(_map(j['talk'])),
      identityRevealedAt:
          _dt(j['identityRevealedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      request: j['request'] == null
          ? null
          : ConnectionRequestSnapshot.fromJson(_map(j['request'])),
      acceptedOffer: accepted == null
          ? null
          : ConnectionAcceptedOffer.fromJson(_map(accepted)),
      closedAt: _dt(j['closedAt']),
      closedBy:
          j['closedBy'] == null ? null : ClosedBy.parse(j['closedBy'] as String?),
      offerId: j['offerId'] as String?,
      requestId: j['requestId'] as String?,
      createdAt: _dt(j['createdAt']),
    );
  }
}

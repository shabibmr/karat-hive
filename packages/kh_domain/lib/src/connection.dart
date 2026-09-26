import 'package:freezed_annotation/freezed_annotation.dart';

import 'offer.dart';
import 'party.dart';
import 'request.dart';
import 'review.dart';

part 'connection.freezed.dart';
part 'connection.g.dart';

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

  String get wire => switch (this) {
        customer => 'CUSTOMER',
        vendor => 'VENDOR',
        admin => 'ADMIN',
        unknown => 'UNKNOWN',
      };
}

class _ConnectionStateConverter
    implements JsonConverter<ConnectionState, String?> {
  const _ConnectionStateConverter();

  @override
  ConnectionState fromJson(String? json) => ConnectionState.parse(json);

  @override
  String toJson(ConnectionState object) => object.wire;
}

class _NullableClosedByConverter implements JsonConverter<ClosedBy?, String?> {
  const _NullableClosedByConverter();

  @override
  ClosedBy? fromJson(String? json) => json == null ? null : ClosedBy.parse(json);

  @override
  String? toJson(ClosedBy? object) => object?.wire;
}

Map<String, dynamic> _map(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

DateTime? _dt(Object? raw) {
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  return null;
}

Map<String, dynamic> _normalizeTalkPayloadJson(Map<String, dynamic> json) {
  final mobile = (json['mobileNumber'] ?? json['phone'] ?? '') as String;
  return {
    'waUrl': json['waUrl'] as String? ?? '',
    'mobileNumber': mobile,
    'prefilledMessage': json['prefilledMessage'] as String? ?? '',
    'available': json['available'] as bool? ?? false,
    'callUrl': json['callUrl'] as String? ?? '',
  };
}

@freezed
abstract class TalkPayload with _$TalkPayload {
  const TalkPayload._();

  const factory TalkPayload({
    required String waUrl,
    required String mobileNumber,
    required bool available,
    @Default('') String prefilledMessage,
    @Default('') String callUrl,
  }) = _TalkPayload;

  factory TalkPayload.fromJson(Map<String, dynamic> json) =>
      _$TalkPayloadFromJson(_normalizeTalkPayloadJson(json));

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

  /// Normalised E.164 phone number via [PhoneNumber] (Architecture-Frontend §10.3).
  PhoneNumber get phoneNumber => PhoneNumber.parse(mobileNumber);
}

Map<String, dynamic> _normalizeConnectionRequestSnapshotJson(
        Map<String, dynamic> json) =>
    {
      'id': json['id'] as String? ?? '',
      'reference': json['reference'] as String?,
      'requestType': json['requestType']?.toString(),
      'direction': json['direction']?.toString(),
      'region': RegionSummary.tryParse(json['region'])?.toJson(),
    };

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

@freezed
abstract class ConnectionRequestSnapshot with _$ConnectionRequestSnapshot {
  const factory ConnectionRequestSnapshot({
    required String id,
    @_RequestTypeConverter() required RequestType requestType,
    @_DirectionConverter() required Direction direction,
    String? reference,
    RegionSummary? region,
  }) = _ConnectionRequestSnapshot;

  factory ConnectionRequestSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ConnectionRequestSnapshotFromJson(
          _normalizeConnectionRequestSnapshotJson(json));
}

OfferTerms _connectionOfferTermsFromJson(Object? raw) =>
    OfferTerms.fromJson(_map(raw));

Map<String, dynamic> _connectionOfferTermsToJson(OfferTerms terms) =>
    terms.toJson();

Map<String, dynamic> _normalizeConnectionAcceptedOfferJson(
    Map<String, dynamic> json) {
  final nested = json['terms'];
  final termsJson = nested is Map ? Map<String, dynamic>.from(nested) : json;
  return {
    'id': json['id'] as String? ?? '',
    'terms': termsJson,
    'submittedAt': json['submittedAt'] is String
        ? (DateTime.tryParse(json['submittedAt'] as String)?.toIso8601String())
        : null,
  };
}

@freezed
abstract class ConnectionAcceptedOffer with _$ConnectionAcceptedOffer {
  const factory ConnectionAcceptedOffer({
    required String id,
    @JsonKey(
      fromJson: _connectionOfferTermsFromJson,
      toJson: _connectionOfferTermsToJson,
    )
    required OfferTerms terms,
    DateTime? submittedAt,
  }) = _ConnectionAcceptedOffer;

  factory ConnectionAcceptedOffer.fromJson(Map<String, dynamic> json) =>
      _$ConnectionAcceptedOfferFromJson(
          _normalizeConnectionAcceptedOfferJson(json));
}

RevealedParty _vendorPartyFromJson(Object? raw) =>
    RevealedParty.fromVendorJson(_map(raw));

RevealedParty _customerPartyFromJson(Object? raw) =>
    RevealedParty.fromCustomerJson(_map(raw));

Map<String, dynamic> _normalizeConnectionForCustomerJson(
    Map<String, dynamic> json) {
  final accepted = json['acceptedOffer'] ?? json['offer'];
  return {
    ...json,
    'state': json['state']?.toString(),
    'identityRevealedAt':
        (_dt(json['identityRevealedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0))
            .toIso8601String(),
    'request':
        json['request'] == null ? null : _map(json['request']),
    'acceptedOffer': accepted == null ? null : _map(accepted),
    'closedAt': _dt(json['closedAt'])?.toIso8601String(),
    'closedBy': json['closedBy']?.toString(),
    'createdAt': _dt(json['createdAt'])?.toIso8601String(),
    'myReview': json['myReview'] is Map
        ? Map<String, dynamic>.from(json['myReview'] as Map)
        : null,
  };
}

/// Customer Connection presenter — the only place revealed Vendor fields exist (BR-007).
@freezed
abstract class ConnectionForCustomer with _$ConnectionForCustomer {
  const factory ConnectionForCustomer({
    required String id,
    @_ConnectionStateConverter() required ConnectionState state,
    @JsonKey(fromJson: _vendorPartyFromJson) required RevealedParty vendor,
    required TalkPayload talk,
    required DateTime identityRevealedAt,
    ConnectionRequestSnapshot? request,
    ConnectionAcceptedOffer? acceptedOffer,
    DateTime? closedAt,
    @_NullableClosedByConverter() ClosedBy? closedBy,
    String? offerId,
    String? requestId,
    DateTime? createdAt,
    Review? myReview,
  }) = _ConnectionForCustomer;

  factory ConnectionForCustomer.fromJson(Map<String, dynamic> json) =>
      _$ConnectionForCustomerFromJson(
          _normalizeConnectionForCustomerJson(json));
}

Map<String, dynamic> _normalizeAcceptOfferResultJson(
        Map<String, dynamic> json) =>
    {
      'offer': _map(json['offer']),
      'connection': _map(json['connection']),
    };

/// `POST /v1/offers/{id}/accept` success body.
@freezed
abstract class AcceptOfferResult with _$AcceptOfferResult {
  const factory AcceptOfferResult({
    required OfferForCustomer offer,
    required ConnectionForCustomer connection,
  }) = _AcceptOfferResult;

  factory AcceptOfferResult.fromJson(Map<String, dynamic> json) =>
      _$AcceptOfferResultFromJson(_normalizeAcceptOfferResultJson(json));
}

Map<String, dynamic> _normalizeConnectionForVendorJson(
    Map<String, dynamic> json) {
  final accepted = json['acceptedOffer'] ?? json['offer'];
  return {
    ...json,
    'state': json['state']?.toString(),
    'identityRevealedAt':
        (_dt(json['identityRevealedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0))
            .toIso8601String(),
    'request':
        json['request'] == null ? null : _map(json['request']),
    'acceptedOffer': accepted == null ? null : _map(accepted),
    'closedAt': _dt(json['closedAt'])?.toIso8601String(),
    'closedBy': json['closedBy']?.toString(),
    'createdAt': _dt(json['createdAt'])?.toIso8601String(),
  };
}

/// Vendor Connection presenter — the only place revealed Customer fields exist
/// (BR-007). Must never carry a competing Vendor's identity or price (BR-008).
@freezed
abstract class ConnectionForVendor with _$ConnectionForVendor {
  const ConnectionForVendor._();

  const factory ConnectionForVendor({
    required String id,
    @_ConnectionStateConverter() required ConnectionState state,
    @JsonKey(fromJson: _customerPartyFromJson) required RevealedParty customer,
    required TalkPayload talk,
    required DateTime identityRevealedAt,
    ConnectionRequestSnapshot? request,
    ConnectionAcceptedOffer? acceptedOffer,
    DateTime? closedAt,
    @_NullableClosedByConverter() ClosedBy? closedBy,
    String? offerId,
    String? requestId,
    DateTime? createdAt,
  }) = _ConnectionForVendor;

  factory ConnectionForVendor.fromJson(Map<String, dynamic> json) =>
      _$ConnectionForVendorFromJson(_normalizeConnectionForVendorJson(json));

  DateTime get connectedAt => createdAt ?? identityRevealedAt;
}

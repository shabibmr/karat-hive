// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TalkPayload _$TalkPayloadFromJson(Map<String, dynamic> json) => _TalkPayload(
  waUrl: json['waUrl'] as String,
  mobileNumber: json['mobileNumber'] as String,
  available: json['available'] as bool,
  prefilledMessage: json['prefilledMessage'] as String? ?? '',
  callUrl: json['callUrl'] as String? ?? '',
);

Map<String, dynamic> _$TalkPayloadToJson(_TalkPayload instance) =>
    <String, dynamic>{
      'waUrl': instance.waUrl,
      'mobileNumber': instance.mobileNumber,
      'available': instance.available,
      'prefilledMessage': instance.prefilledMessage,
      'callUrl': instance.callUrl,
    };

_ConnectionRequestSnapshot _$ConnectionRequestSnapshotFromJson(
  Map<String, dynamic> json,
) => _ConnectionRequestSnapshot(
  id: json['id'] as String,
  requestType: const _RequestTypeConverter().fromJson(
    json['requestType'] as String?,
  ),
  direction: const _DirectionConverter().fromJson(json['direction'] as String?),
  reference: json['reference'] as String?,
  region: json['region'] == null
      ? null
      : RegionSummary.fromJson(json['region'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConnectionRequestSnapshotToJson(
  _ConnectionRequestSnapshot instance,
) => <String, dynamic>{
  'id': instance.id,
  'requestType': const _RequestTypeConverter().toJson(instance.requestType),
  'direction': const _DirectionConverter().toJson(instance.direction),
  'reference': instance.reference,
  'region': instance.region?.toJson(),
};

_ConnectionAcceptedOffer _$ConnectionAcceptedOfferFromJson(
  Map<String, dynamic> json,
) => _ConnectionAcceptedOffer(
  id: json['id'] as String,
  terms: _connectionOfferTermsFromJson(json['terms']),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
);

Map<String, dynamic> _$ConnectionAcceptedOfferToJson(
  _ConnectionAcceptedOffer instance,
) => <String, dynamic>{
  'id': instance.id,
  'terms': _connectionOfferTermsToJson(instance.terms),
  'submittedAt': instance.submittedAt?.toIso8601String(),
};

_ConnectionForCustomer _$ConnectionForCustomerFromJson(
  Map<String, dynamic> json,
) => _ConnectionForCustomer(
  id: json['id'] as String,
  state: const _ConnectionStateConverter().fromJson(json['state'] as String?),
  vendor: _vendorPartyFromJson(json['vendor']),
  talk: TalkPayload.fromJson(json['talk'] as Map<String, dynamic>),
  identityRevealedAt: DateTime.parse(json['identityRevealedAt'] as String),
  request: json['request'] == null
      ? null
      : ConnectionRequestSnapshot.fromJson(
          json['request'] as Map<String, dynamic>,
        ),
  acceptedOffer: json['acceptedOffer'] == null
      ? null
      : ConnectionAcceptedOffer.fromJson(
          json['acceptedOffer'] as Map<String, dynamic>,
        ),
  closedAt: json['closedAt'] == null
      ? null
      : DateTime.parse(json['closedAt'] as String),
  closedBy: const _NullableClosedByConverter().fromJson(
    json['closedBy'] as String?,
  ),
  offerId: json['offerId'] as String?,
  requestId: json['requestId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  myReview: json['myReview'] == null
      ? null
      : Review.fromJson(json['myReview'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConnectionForCustomerToJson(
  _ConnectionForCustomer instance,
) => <String, dynamic>{
  'id': instance.id,
  'state': const _ConnectionStateConverter().toJson(instance.state),
  'vendor': instance.vendor.toJson(),
  'talk': instance.talk.toJson(),
  'identityRevealedAt': instance.identityRevealedAt.toIso8601String(),
  'request': instance.request?.toJson(),
  'acceptedOffer': instance.acceptedOffer?.toJson(),
  'closedAt': instance.closedAt?.toIso8601String(),
  'closedBy': const _NullableClosedByConverter().toJson(instance.closedBy),
  'offerId': instance.offerId,
  'requestId': instance.requestId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'myReview': instance.myReview?.toJson(),
};

_AcceptOfferResult _$AcceptOfferResultFromJson(Map<String, dynamic> json) =>
    _AcceptOfferResult(
      offer: OfferForCustomer.fromJson(json['offer'] as Map<String, dynamic>),
      connection: ConnectionForCustomer.fromJson(
        json['connection'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AcceptOfferResultToJson(_AcceptOfferResult instance) =>
    <String, dynamic>{
      'offer': instance.offer.toJson(),
      'connection': instance.connection.toJson(),
    };

_ConnectionForVendor _$ConnectionForVendorFromJson(Map<String, dynamic> json) =>
    _ConnectionForVendor(
      id: json['id'] as String,
      state: const _ConnectionStateConverter().fromJson(
        json['state'] as String?,
      ),
      customer: _customerPartyFromJson(json['customer']),
      talk: TalkPayload.fromJson(json['talk'] as Map<String, dynamic>),
      identityRevealedAt: DateTime.parse(json['identityRevealedAt'] as String),
      request: json['request'] == null
          ? null
          : ConnectionRequestSnapshot.fromJson(
              json['request'] as Map<String, dynamic>,
            ),
      acceptedOffer: json['acceptedOffer'] == null
          ? null
          : ConnectionAcceptedOffer.fromJson(
              json['acceptedOffer'] as Map<String, dynamic>,
            ),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      closedBy: const _NullableClosedByConverter().fromJson(
        json['closedBy'] as String?,
      ),
      offerId: json['offerId'] as String?,
      requestId: json['requestId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ConnectionForVendorToJson(
  _ConnectionForVendor instance,
) => <String, dynamic>{
  'id': instance.id,
  'state': const _ConnectionStateConverter().toJson(instance.state),
  'customer': instance.customer.toJson(),
  'talk': instance.talk.toJson(),
  'identityRevealedAt': instance.identityRevealedAt.toIso8601String(),
  'request': instance.request?.toJson(),
  'acceptedOffer': instance.acceptedOffer?.toJson(),
  'closedAt': instance.closedAt?.toIso8601String(),
  'closedBy': const _NullableClosedByConverter().toJson(instance.closedBy),
  'offerId': instance.offerId,
  'requestId': instance.requestId,
  'createdAt': instance.createdAt?.toIso8601String(),
};

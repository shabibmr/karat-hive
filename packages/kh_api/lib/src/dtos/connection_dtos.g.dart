// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TalkDto _$TalkDtoFromJson(Map<String, dynamic> json) => _TalkDto(
  available: json['available'] as bool,
  waUrl: json['waUrl'] as String,
  phone: json['phone'] as String,
  callUrl: json['callUrl'] as String,
);

Map<String, dynamic> _$TalkDtoToJson(_TalkDto instance) => <String, dynamic>{
  'available': instance.available,
  'waUrl': instance.waUrl,
  'phone': instance.phone,
  'callUrl': instance.callUrl,
};

_RevealedVendorDto _$RevealedVendorDtoFromJson(Map<String, dynamic> json) =>
    _RevealedVendorDto(
      id: json['id'] as String,
      legalBusinessName: json['legalBusinessName'] as String,
      tradingName: json['tradingName'] as String,
      tradeLicenceNumber: json['tradeLicenceNumber'] as String,
      phone: json['phone'] as String,
      connectionCount: (json['connectionCount'] as num).toInt(),
      region: json['region'] == null
          ? null
          : RegionSummaryDto.fromJson(json['region'] as Map<String, dynamic>),
      rating: json['rating'] == null
          ? null
          : RatingSummaryDto.fromJson(json['rating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RevealedVendorDtoToJson(_RevealedVendorDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'legalBusinessName': instance.legalBusinessName,
      'tradingName': instance.tradingName,
      'tradeLicenceNumber': instance.tradeLicenceNumber,
      'phone': instance.phone,
      'connectionCount': instance.connectionCount,
      'region': instance.region,
      'rating': instance.rating,
    };

_ConnectionOfferDto _$ConnectionOfferDtoFromJson(Map<String, dynamic> json) =>
    _ConnectionOfferDto(
      id: json['id'] as String,
      offeredPrice: json['offeredPrice'] as String,
      makingCharges: json['makingCharges'] as String?,
      ratePerGram: json['ratePerGram'] as String?,
      validityHours: (json['validityHours'] as num).toInt(),
      deliveryTimeframe: json['deliveryTimeframe'] as String?,
      warrantyTerms: json['warrantyTerms'] as String?,
      vendorNote: json['vendorNote'] as String?,
    );

Map<String, dynamic> _$ConnectionOfferDtoToJson(_ConnectionOfferDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'offeredPrice': instance.offeredPrice,
      'makingCharges': instance.makingCharges,
      'ratePerGram': instance.ratePerGram,
      'validityHours': instance.validityHours,
      'deliveryTimeframe': instance.deliveryTimeframe,
      'warrantyTerms': instance.warrantyTerms,
      'vendorNote': instance.vendorNote,
    };

_ConnectionRequestRefDto _$ConnectionRequestRefDtoFromJson(
  Map<String, dynamic> json,
) => _ConnectionRequestRefDto(
  id: json['id'] as String,
  reference: json['reference'] as String?,
  requestType: json['requestType'] as String,
  direction: json['direction'] as String,
  region: RegionSummaryDto.fromJson(json['region'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConnectionRequestRefDtoToJson(
  _ConnectionRequestRefDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'reference': instance.reference,
  'requestType': instance.requestType,
  'direction': instance.direction,
  'region': instance.region,
};

_CustomerConnectionDto _$CustomerConnectionDtoFromJson(
  Map<String, dynamic> json,
) => _CustomerConnectionDto(
  id: json['id'] as String,
  offerId: json['offerId'] as String,
  requestId: json['requestId'] as String,
  state: json['state'] as String,
  identityRevealedAt: DateTime.parse(json['identityRevealedAt'] as String),
  closedAt: json['closedAt'] == null
      ? null
      : DateTime.parse(json['closedAt'] as String),
  closedBy: json['closedBy'] as String?,
  vendor: RevealedVendorDto.fromJson(json['vendor'] as Map<String, dynamic>),
  offer: ConnectionOfferDto.fromJson(json['offer'] as Map<String, dynamic>),
  request: ConnectionRequestRefDto.fromJson(
    json['request'] as Map<String, dynamic>,
  ),
  talk: TalkDto.fromJson(json['talk'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CustomerConnectionDtoToJson(
  _CustomerConnectionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'offerId': instance.offerId,
  'requestId': instance.requestId,
  'state': instance.state,
  'identityRevealedAt': instance.identityRevealedAt.toIso8601String(),
  'closedAt': instance.closedAt?.toIso8601String(),
  'closedBy': instance.closedBy,
  'vendor': instance.vendor,
  'offer': instance.offer,
  'request': instance.request,
  'talk': instance.talk,
};

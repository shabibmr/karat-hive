// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OfferListItemImpl _$$OfferListItemImplFromJson(Map<String, dynamic> json) =>
    _$OfferListItemImpl(
      id: json['id'] as String,
      reference: json['reference'] as String?,
      requestId: json['requestId'] as String,
      requestReference: json['requestReference'] as String?,
      requestType: $enumDecodeNullable(
        _$RequestTypeEnumMap,
        json['requestType'],
        unknownValue: RequestType.findOrnament,
      ),
      vendorId: json['vendorId'] as String,
      vendorName: json['vendorName'] as String,
      offeredPrice: (json['offeredPrice'] as num).toDouble(),
      state:
          $enumDecodeNullable(
            _$OfferStateEnumMap,
            json['state'],
            unknownValue: OfferState.pending,
          ) ??
          OfferState.pending,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      outcome: json['outcome'] as String?,
      makingCharges: (json['makingCharges'] as num?)?.toDouble(),
      ratePerGram: (json['ratePerGram'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$OfferListItemImplToJson(_$OfferListItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'requestId': instance.requestId,
      'requestReference': instance.requestReference,
      'requestType': _$RequestTypeEnumMap[instance.requestType],
      'vendorId': instance.vendorId,
      'vendorName': instance.vendorName,
      'offeredPrice': instance.offeredPrice,
      'state': _$OfferStateEnumMap[instance.state]!,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'outcome': instance.outcome,
      'makingCharges': instance.makingCharges,
      'ratePerGram': instance.ratePerGram,
    };

const _$RequestTypeEnumMap = {
  RequestType.findOrnament: 'FIND_ORNAMENT',
  RequestType.sellOldGold: 'SELL_OLD_GOLD',
  RequestType.goldCoin: 'GOLD_COIN',
  RequestType.goldBullion: 'GOLD_BULLION',
};

const _$OfferStateEnumMap = {
  OfferState.pending: 'PENDING',
  OfferState.accepted: 'ACCEPTED',
  OfferState.rejected: 'REJECTED',
  OfferState.expired: 'EXPIRED',
  OfferState.withdrawn: 'WITHDRAWN',
  OfferState.withdrawnBySystem: 'WITHDRAWN_BY_SYSTEM',
};

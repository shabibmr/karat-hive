// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OfferTerms _$OfferTermsFromJson(Map<String, dynamic> json) => _OfferTerms(
  offeredPrice: json['offeredPrice'] as String,
  weightGrams: json['weightGrams'] as String,
  purityKarat: json['purityKarat'] as String,
  makingCharges: json['makingCharges'] as String?,
  ratePerGram: json['ratePerGram'] as String?,
  deliveryTimeframe: json['deliveryTimeframe'] as String?,
  warrantyTerms: json['warrantyTerms'] as String?,
  vendorNote: json['vendorNote'] as String?,
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => MediaRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MediaRef>[],
);

Map<String, dynamic> _$OfferTermsToJson(_OfferTerms instance) =>
    <String, dynamic>{
      'offeredPrice': instance.offeredPrice,
      'weightGrams': instance.weightGrams,
      'purityKarat': instance.purityKarat,
      'makingCharges': instance.makingCharges,
      'ratePerGram': instance.ratePerGram,
      'deliveryTimeframe': instance.deliveryTimeframe,
      'warrantyTerms': instance.warrantyTerms,
      'vendorNote': instance.vendorNote,
      'media': instance.media.map((e) => e.toJson()).toList(),
    };

_OfferForCustomer _$OfferForCustomerFromJson(Map<String, dynamic> json) =>
    _OfferForCustomer(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      state: const _OfferStateConverter().fromJson(json['state'] as String?),
      terms: _offerTermsFromJson(json['terms']),
      vendor: MaskedParty.fromJson(json['vendor'] as Map<String, dynamic>),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      revisionCount: (json['revisionCount'] as num).toInt(),
      decidedAt: json['decidedAt'] == null
          ? null
          : DateTime.parse(json['decidedAt'] as String),
      viewedByCustomerAt: json['viewedByCustomerAt'] == null
          ? null
          : DateTime.parse(json['viewedByCustomerAt'] as String),
      viewedByCustomerAtPresent:
          json['viewedByCustomerAtPresent'] as bool? ?? false,
    );

Map<String, dynamic> _$OfferForCustomerToJson(_OfferForCustomer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requestId': instance.requestId,
      'state': const _OfferStateConverter().toJson(instance.state),
      'terms': _offerTermsToJson(instance.terms),
      'vendor': instance.vendor.toJson(),
      'submittedAt': instance.submittedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'revisionCount': instance.revisionCount,
      'decidedAt': instance.decidedAt?.toIso8601String(),
      'viewedByCustomerAt': instance.viewedByCustomerAt?.toIso8601String(),
      'viewedByCustomerAtPresent': instance.viewedByCustomerAtPresent,
    };

_ReviewExcerpt _$ReviewExcerptFromJson(Map<String, dynamic> json) =>
    _ReviewExcerpt(
      abbreviatedName: json['abbreviatedName'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$ReviewExcerptToJson(_ReviewExcerpt instance) =>
    <String, dynamic>{
      'abbreviatedName': instance.abbreviatedName,
      'rating': instance.rating,
      'comment': instance.comment,
    };

_VendorRatingDetail _$VendorRatingDetailFromJson(Map<String, dynamic> json) =>
    _VendorRatingDetail(
      summary: _ratingSummaryFromJson(json['summary']),
      excerpts:
          (json['excerpts'] as List<dynamic>?)
              ?.map((e) => ReviewExcerpt.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ReviewExcerpt>[],
    );

Map<String, dynamic> _$VendorRatingDetailToJson(_VendorRatingDetail instance) =>
    <String, dynamic>{
      'summary': _ratingSummaryToJson(instance.summary),
      'excerpts': instance.excerpts.map((e) => e.toJson()).toList(),
    };

_OfferRequestSummary _$OfferRequestSummaryFromJson(Map<String, dynamic> json) =>
    _OfferRequestSummary(
      id: json['id'] as String,
      requestType: const _RequestTypeConverter().fromJson(
        json['requestType'] as String?,
      ),
      direction: const _DirectionConverter().fromJson(
        json['direction'] as String?,
      ),
      customerLabel: json['customerLabel'] as String,
      reference: json['reference'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      regionId: json['regionId'] as String?,
      regionName: json['regionName'] as String?,
      purityKarat: json['purityKarat'] as String?,
      weightGrams: json['weightGrams'] as String?,
      budgetMax: json['budgetMax'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$OfferRequestSummaryToJson(
  _OfferRequestSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'requestType': const _RequestTypeConverter().toJson(instance.requestType),
  'direction': const _DirectionConverter().toJson(instance.direction),
  'customerLabel': instance.customerLabel,
  'reference': instance.reference,
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'regionId': instance.regionId,
  'regionName': instance.regionName,
  'purityKarat': instance.purityKarat,
  'weightGrams': instance.weightGrams,
  'budgetMax': instance.budgetMax,
  'expiresAt': instance.expiresAt?.toIso8601String(),
};

_OfferForVendor _$OfferForVendorFromJson(Map<String, dynamic> json) =>
    _OfferForVendor(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      state: const _OfferStateConverter().fromJson(json['state'] as String?),
      terms: _offerTermsFromJson(json['terms']),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      revisionCount: (json['revisionCount'] as num).toInt(),
      decidedAt: json['decidedAt'] == null
          ? null
          : DateTime.parse(json['decidedAt'] as String),
      viewedByCustomerAt: json['viewedByCustomerAt'] == null
          ? null
          : DateTime.parse(json['viewedByCustomerAt'] as String),
      requestSummary: json['requestSummary'] == null
          ? null
          : OfferRequestSummary.fromJson(
              json['requestSummary'] as Map<String, dynamic>,
            ),
      declineReason: const _NullableOfferDeclineReasonConverter().fromJson(
        json['declineReason'] as String?,
      ),
      awardedElsewhere: json['awardedElsewhere'] as bool? ?? false,
      connectionId: json['connectionId'] as String?,
    );

Map<String, dynamic> _$OfferForVendorToJson(_OfferForVendor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requestId': instance.requestId,
      'state': const _OfferStateConverter().toJson(instance.state),
      'terms': _offerTermsToJson(instance.terms),
      'submittedAt': instance.submittedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'revisionCount': instance.revisionCount,
      'decidedAt': instance.decidedAt?.toIso8601String(),
      'viewedByCustomerAt': instance.viewedByCustomerAt?.toIso8601String(),
      'requestSummary': instance.requestSummary?.toJson(),
      'declineReason': const _NullableOfferDeclineReasonConverter().toJson(
        instance.declineReason,
      ),
      'awardedElsewhere': instance.awardedElsewhere,
      'connectionId': instance.connectionId,
    };

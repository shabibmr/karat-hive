import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kh_admin/features/offers/model/offer_enums.dart';

part 'offer_detail.freezed.dart';
part 'offer_detail.g.dart';

/// Parent request summary embedded in [OfferDetail] (ADM-S11).
@freezed
class OfferParentRequestSummary with _$OfferParentRequestSummary {
  const factory OfferParentRequestSummary({
    required String id,
    String? reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    RequestType? requestType,
    String? customerName,
    String? customerMobile,
    String? customerEmail,
    String? categoryName,
    String? regionName,
    double? indicativeValue,
    String? notes,
  }) = _OfferParentRequestSummary;

  factory OfferParentRequestSummary.fromJson(Map<String, dynamic> json) =>
      _$OfferParentRequestSummaryFromJson(json);
}

/// Unmasked vendor profile summary embedded in [OfferDetail] (ADM-S11).
@freezed
class OfferVendorSummary with _$OfferVendorSummary {
  const factory OfferVendorSummary({
    required String id,
    required String legalBusinessName,
    String? tradingName,
    String? tradeLicenceNumber,
    String? contactPersonName,
    String? mobileNumber,
    String? email,
    double? rating,
    int? completedDeals,
  }) = _OfferVendorSummary;

  factory OfferVendorSummary.fromJson(Map<String, dynamic> json) =>
      _$OfferVendorSummaryFromJson(json);
}

/// Attached image or certificate in [OfferDetail] (ADM-S11).
@freezed
class OfferAttachment with _$OfferAttachment {
  const factory OfferAttachment({
    required String id,
    required String fileName,
    String? url,
    String? mimeType,
    int? sizeBytes,
    DateTime? uploadedAt,
  }) = _OfferAttachment;

  factory OfferAttachment.fromJson(Map<String, dynamic> json) =>
      _$OfferAttachmentFromJson(json);
}

/// Historical revision snapshot for FR-VEN-014 in [OfferDetail] (ADM-S11).
@freezed
class OfferRevisionItem with _$OfferRevisionItem {
  const factory OfferRevisionItem({
    required int revisionNumber,
    required DateTime revisedAt,
    required double offeredPrice,
    double? makingCharges,
    double? ratePerGram,
    String? deliveryTimeframe,
    String? vendorNote,
    String? changeSummary,
  }) = _OfferRevisionItem;

  factory OfferRevisionItem.fromJson(Map<String, dynamic> json) =>
      _$OfferRevisionItemFromJson(json);
}

/// State transition audit entry in [OfferDetail] (ADM-S11).
@freezed
class OfferStateTransitionItem with _$OfferStateTransitionItem {
  const factory OfferStateTransitionItem({
    String? fromState,
    required String toState,
    required DateTime transitionedAt,
    String? actor,
    String? reason,
  }) = _OfferStateTransitionItem;

  factory OfferStateTransitionItem.fromJson(Map<String, dynamic> json) =>
      _$OfferStateTransitionItemFromJson(json);
}

/// Internal admin note for [OfferDetail] (ADM-S11).
@freezed
class OfferInternalNoteItem with _$OfferInternalNoteItem {
  const factory OfferInternalNoteItem({
    required String id,
    required String author,
    required String text,
    required DateTime createdAt,
  }) = _OfferInternalNoteItem;

  factory OfferInternalNoteItem.fromJson(Map<String, dynamic> json) =>
      _$OfferInternalNoteItemFromJson(json);
}

/// Full offer inspection model for ADM-S11.
@freezed
class OfferDetail with _$OfferDetail {
  const OfferDetail._();

  const factory OfferDetail({
    required String id,
    String? reference,
    @Default(OfferState.pending)
    @JsonKey(unknownEnumValue: OfferState.pending)
    OfferState state,
    required double offeredPrice,
    double? makingCharges,
    double? ratePerGram,
    double? goldPrice,
    double? vat,
    double? totalAmount,
    String? deliveryTimeframe,
    String? warrantyTerms,
    String? vendorNote,
    int? validityHours,
    DateTime? expiresAt,
    required DateTime submittedAt,
    DateTime? decidedAt,
    String? declineReason,
    @Default(0) int revisionCount,
    String? winningOfferId,
    String? winningOfferReference,
    double? winningOfferPrice,
    String? winningVendorName,
    OfferParentRequestSummary? parentRequest,
    OfferVendorSummary? vendor,
    @Default([]) List<OfferAttachment> attachments,
    @Default([]) List<OfferRevisionItem> revisions,
    @Default([]) List<OfferStateTransitionItem> stateTransitions,
    @Default([]) List<OfferInternalNoteItem> internalNotes,
  }) = _OfferDetail;

  factory OfferDetail.fromJson(Map<String, dynamic> json) =>
      _$OfferDetailFromJson(json);

  double get calculatedGoldPrice =>
      goldPrice ?? (offeredPrice - (makingCharges ?? 0.0));
  double get calculatedVat => vat ?? (offeredPrice * 0.05);
  double get calculatedTotal => totalAmount ?? offeredPrice;
}

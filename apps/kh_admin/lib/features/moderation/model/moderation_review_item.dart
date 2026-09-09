import 'package:kh_admin/features/moderation/model/moderation_enums.dart';

/// Single review item in the ADM-S16 Review Moderation Queue.
class ModerationReviewItem {
  const ModerationReviewItem({
    required this.id,
    required this.connectionId,
    required this.authorType,
    required this.authorUserId,
    required this.subjectUserId,
    required this.rating,
    this.comment,
    required this.state,
    this.vendorResponse,
    this.vendorResponseState,
    this.moderatedByAdminId,
    this.editableUntil,
    this.publishedAt,
    required this.createdAt,
    this.authorName,
    this.authorEmail,
    this.subjectName,
    this.subjectEmail,
    this.requestId,
    this.offerId,
  });

  final String id;
  final String connectionId;
  final AuthorType authorType;
  final String authorUserId;
  final String subjectUserId;
  final int rating;
  final String? comment;
  final ReviewState state;
  final String? vendorResponse;
  final ReviewState? vendorResponseState;
  final String? moderatedByAdminId;
  final DateTime? editableUntil;
  final DateTime? publishedAt;
  final DateTime createdAt;

  final String? authorName;
  final String? authorEmail;
  final String? subjectName;
  final String? subjectEmail;
  final String? requestId;
  final String? offerId;

  factory ModerationReviewItem.fromJson(Map<String, dynamic> json) {
    final authorObj = json['author'] is Map<String, dynamic>
        ? json['author'] as Map<String, dynamic>
        : null;
    final subjectObj = json['subject'] is Map<String, dynamic>
        ? json['subject'] as Map<String, dynamic>
        : null;
    final connObj = json['connection'] is Map<String, dynamic>
        ? json['connection'] as Map<String, dynamic>
        : null;

    final authorCust = authorObj?['customerProfile'] is Map<String, dynamic>
        ? authorObj!['customerProfile'] as Map<String, dynamic>
        : null;
    final authorVend = authorObj?['vendorProfile'] is Map<String, dynamic>
        ? authorObj!['vendorProfile'] as Map<String, dynamic>
        : null;

    final subjectCust = subjectObj?['customerProfile'] is Map<String, dynamic>
        ? subjectObj!['customerProfile'] as Map<String, dynamic>
        : null;
    final subjectVend = subjectObj?['vendorProfile'] is Map<String, dynamic>
        ? subjectObj!['vendorProfile'] as Map<String, dynamic>
        : null;

    final authorName = authorCust?['displayName']?.toString() ??
        authorVend?['tradingName']?.toString() ??
        authorObj?['displayName']?.toString();

    final subjectName = subjectCust?['displayName']?.toString() ??
        subjectVend?['tradingName']?.toString() ??
        subjectObj?['displayName']?.toString();

    final stateStr = json['state']?.toString();
    final authorTypeStr = json['authorType']?.toString();
    final respStateStr = json['vendorResponseState']?.toString();

    final ratingVal = json['rating'] is num ? (json['rating'] as num).toInt() : 5;

    return ModerationReviewItem(
      id: json['id']?.toString() ?? '',
      connectionId: json['connectionId']?.toString() ?? '',
      authorType: AuthorType.fromWire(authorTypeStr) ?? AuthorType.customer,
      authorUserId: json['authorUserId']?.toString() ?? '',
      subjectUserId: json['subjectUserId']?.toString() ?? '',
      rating: ratingVal,
      comment: json['comment']?.toString(),
      state: ReviewState.fromWire(stateStr) ?? ReviewState.pendingModeration,
      vendorResponse: json['vendorResponse']?.toString(),
      vendorResponseState: ReviewState.fromWire(respStateStr),
      moderatedByAdminId: json['moderatedByAdminId']?.toString(),
      editableUntil: json['editableUntil'] != null
          ? DateTime.tryParse(json['editableUntil'].toString())
          : null,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      authorName: authorName,
      authorEmail: authorObj?['email']?.toString(),
      subjectName: subjectName,
      subjectEmail: subjectObj?['email']?.toString(),
      requestId: connObj?['requestId']?.toString(),
      offerId: connObj?['offerId']?.toString(),
    );
  }
}

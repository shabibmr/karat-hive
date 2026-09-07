import 'party.dart';

enum ReviewState {
  pendingModeration,
  published,
  rejected,
  redacted,
  withdrawn,
  unknown;

  static ReviewState parse(String? raw) => switch (raw) {
        'PENDING_MODERATION' => pendingModeration,
        'PUBLISHED' => published,
        'REJECTED' => rejected,
        'REDACTED' => redacted,
        'WITHDRAWN' => withdrawn,
        _ => unknown,
      };
}

class ReviewVendorResponse {
  const ReviewVendorResponse({required this.text, required this.state});

  final String text;
  final ReviewState state;

  static ReviewVendorResponse fromJson(Map<String, dynamic> j) =>
      ReviewVendorResponse(
        text: j['text'] as String? ?? '',
        state: ReviewState.parse(j['state'] as String?),
      );
}

class Review {
  const Review({
    required this.id,
    required this.connectionId,
    required this.authorType,
    required this.rating,
    required this.state,
    required this.editableUntil,
    required this.createdAt,
    this.comment,
    this.vendorResponse,
    this.publishedAt,
    this.authorDisplayName,
  });

  final String id;
  final String connectionId;
  final PartyRole authorType;
  final int rating;
  final String? comment;
  final ReviewState state;
  final ReviewVendorResponse? vendorResponse;
  final DateTime editableUntil;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String? authorDisplayName;

  static Review fromJson(Map<String, dynamic> j) {
    final vr = j['vendorResponse'];
    return Review(
      id: j['id'] as String,
      connectionId: j['connectionId'] as String,
      authorType: PartyRole.parse(j['authorType'] as String?),
      rating: (j['rating'] as num?)?.toInt() ?? 0,
      comment: j['comment'] as String?,
      state: ReviewState.parse(j['state'] as String?),
      vendorResponse: vr is Map
          ? ReviewVendorResponse.fromJson(Map<String, dynamic>.from(vr))
          : null,
      editableUntil: DateTime.tryParse(j['editableUntil'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      publishedAt: j['publishedAt'] is String
          ? DateTime.tryParse(j['publishedAt'] as String)
          : null,
      authorDisplayName: j['authorDisplayName'] as String?,
    );
  }
}

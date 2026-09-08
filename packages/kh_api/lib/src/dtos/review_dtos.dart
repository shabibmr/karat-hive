/// `review.presenter.ts` `ReviewView`. Backs `CUS-S18` and `GET /v1/me/reviews`.
class ReviewDto {
  const ReviewDto({
    required this.id,
    required this.connectionId,
    required this.authorType,
    this.authorDisplayName,
    required this.rating,
    this.comment,
    required this.state,
    this.vendorResponse,
    required this.editableUntil,
    required this.createdAt,
    this.publishedAt,
  });

  final String id;
  final String connectionId;
  final String authorType; // CUSTOMER | VENDOR
  final String? authorDisplayName;
  final int rating;
  final String? comment;
  final String state;
  final ReviewResponseDto? vendorResponse;
  final DateTime editableUntil;
  final DateTime createdAt;
  final DateTime? publishedAt;

  static ReviewDto fromJson(Map<String, dynamic> j) => ReviewDto(
        id: j['id'] as String,
        connectionId: j['connectionId'] as String? ?? '',
        authorType: j['authorType'] as String? ?? 'CUSTOMER',
        authorDisplayName: j['authorDisplayName'] as String?,
        rating: j['rating'] as int? ?? 0,
        comment: j['comment'] as String?,
        state: j['state'] as String? ?? '',
        vendorResponse: j['vendorResponse'] == null
            ? null
            : ReviewResponseDto.fromJson(
                j['vendorResponse'] as Map<String, dynamic>),
        editableUntil: DateTime.parse(j['editableUntil'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
        publishedAt: j['publishedAt'] == null
            ? null
            : DateTime.parse(j['publishedAt'] as String),
      );
}

class ReviewResponseDto {
  const ReviewResponseDto({required this.text, required this.state});

  final String text;
  final String state;

  static ReviewResponseDto fromJson(Map<String, dynamic> j) => ReviewResponseDto(
        text: j['text'] as String? ?? '',
        state: j['state'] as String? ?? '',
      );
}

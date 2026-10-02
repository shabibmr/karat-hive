import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(ref.watch(khApiProvider));
});

class ReviewsRepository {
  const ReviewsRepository(this._api);
  final KhApi _api;

  Future<Result<Review>> create({
    required String connectionId,
    required int rating,
    String? comment,
  }) =>
      _api.reviews.create(
        connectionId: connectionId,
        rating: rating,
        comment: comment,
      );

  /// `GET /v1/me/reviews` — [role] is author/subject (`FR-VEN-029`).
  Future<Result<PagedResult<Review>>> list({
    ReviewListRole? role,
    String? cursor,
    int limit = 20,
  }) =>
      _api.reviews.list(role: role, cursor: cursor, limit: limit);

  Future<Result<Review>> patch(
    String id, {
    int? rating,
    String? comment,
  }) =>
      _api.reviews.patch(id, rating: rating, comment: comment);

  Future<Result<Review>> withdraw(String id) => _api.reviews.withdraw(id);

  Future<Result<Review>> respond(
    String id, {
    required String response,
  }) =>
      _api.reviews.respond(id, response: response);

  Future<Result<void>> flag(String id) => _api.reviews.flag(id);

  Future<Result<VendorPerformanceDto>> getPerformance() =>
      _api.performance.getPerformance();
}

extension ReviewsRepositoryAuthored on ReviewsRepository {
  /// True when the viewer already authored a review for [connectionId] (`BR-017`).
  ///
  /// [myReview] from a Connection detail payload short-circuits when present
  /// (Customer presenters may include it; Vendor presenters often do not).
  ///
  /// Walks AUTHOR pages until the Connection is found or the cursor ends.
  /// On list failure, returns false so close can still open leave-review;
  /// leave-review surfaces `REVIEW_ALREADY_EXISTS` if a review already exists.
  Future<bool> hasAuthoredForConnection(
    String connectionId, {
    Review? myReview,
    int pageSize = 50,
    int maxPages = 20,
  }) async {
    if (myReview != null) return true;

    String? cursor;
    for (var pageIndex = 0; pageIndex < maxPages; pageIndex++) {
      final res = await list(
        role: ReviewListRole.author,
        cursor: cursor,
        limit: pageSize,
      );
      final found = res.when(
        ok: (page) {
          if (page.items.any((r) => r.connectionId == connectionId)) {
            return true;
          }
          final next = page.nextCursor;
          if (next == null || next.isEmpty) return false;
          cursor = next;
          return null;
        },
        err: (_) => false,
      );
      if (found != null) return found;
    }
    return false;
  }
}

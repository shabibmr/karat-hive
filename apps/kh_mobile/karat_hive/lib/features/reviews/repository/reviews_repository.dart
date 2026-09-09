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

  /// `GET /v1/me/reviews` — [role] is `AUTHOR` | `SUBJECT` (`FR-VEN-029`).
  Future<Result<PagedResult<Review>>> list({
    String? role,
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

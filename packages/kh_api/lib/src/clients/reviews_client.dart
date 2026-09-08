import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class ReviewsClient {
  const ReviewsClient(this._client);
  final KhApiClient _client;

  Future<Result<Review>> create({
    required String connectionId,
    required int rating,
    String? comment,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/connections/$connectionId/reviews',
      body: {
        'rating': rating,
        if (comment != null) 'comment': comment,
      },
    );
    return r.when(
      ok: (d) => Ok(Review.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<Review>> patch(
    String id, {
    int? rating,
    String? comment,
  }) async {
    final r = await _client.send('PATCH', '/v1/reviews/$id', body: {
      if (rating != null) 'rating': rating,
      if (comment != null) 'comment': comment,
    });
    return r.when(
      ok: (d) => Ok(Review.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<Review>> withdraw(String id) async {
    final r = await _client.send('POST', '/v1/reviews/$id/withdraw');
    return r.when(
      ok: (d) => Ok(Review.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}

import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../paged.dart';

Result<Review> _parseReview(dynamic raw) {
  try {
    if (raw is! Map) {
      return const Err(ServerFailure(
        code: 'BAD_RESPONSE',
        message: 'Review response was not an object.',
      ));
    }
    return Ok(Review.fromJson(Map<String, dynamic>.from(raw)));
  } catch (_) {
    return const Err(ServerFailure(
      code: 'BAD_RESPONSE',
      message: 'Could not read review response.',
    ));
  }
}

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
    return r.when(ok: _parseReview, err: Err.new);
  }

  /// `GET /v1/me/reviews` — authored by me, and (Vendor) published about me.
  /// [role] is `AUTHOR` | `SUBJECT` when provided (`FR-VEN-029`).
  Future<Result<PagedResult<Review>>> list({
    String? role,
    String? cursor,
    int limit = 20,
  }) async {
    final r = await _client.send(
      'GET',
      '/v1/me/reviews',
      query: {
        if (role != null) 'role': role,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit.toString(),
      },
      unwrapData: false,
    );
    return r.when(
      ok: (raw) {
        try {
          return Ok(parsePagedEnvelope(raw, Review.fromJson));
        } catch (_) {
          return const Err(ServerFailure(
            code: 'BAD_RESPONSE',
            message: 'Could not load reviews.',
          ));
        }
      },
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
    return r.when(ok: _parseReview, err: Err.new);
  }

  Future<Result<Review>> withdraw(String id) async {
    final r = await _client.send('POST', '/v1/reviews/$id/withdraw');
    return r.when(ok: _parseReview, err: Err.new);
  }

  /// Vendor response on a published review about them (`FR-VEN-029`). Max 500.
  Future<Result<Review>> respond(
    String id, {
    required String response,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/reviews/$id/response',
      body: {'response': response},
    );
    return r.when(ok: _parseReview, err: Err.new);
  }

  /// Vendor flag on a published review about them (`FR-VEN-029` AC3).
  Future<Result<void>> flag(String id) async {
    final r = await _client.send('POST', '/v1/reviews/$id/flag');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }
}

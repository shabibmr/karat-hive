import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/reviews/repository/reviews_repository.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class _PagingReviewsRepository implements ReviewsRepository {
  _PagingReviewsRepository({
    required this.pages,
    this.failOnPage,
  });

  final List<PagedResult<Review>> pages;
  final int? failOnPage;
  final List<String?> cursorsSeen = [];
  int calls = 0;

  @override
  Future<Result<Review>> create({
    required String connectionId,
    required int rating,
    String? comment,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> flag(String id) async => const Ok(null);

  @override
  Future<Result<PagedResult<Review>>> list({
    ReviewListRole? role,
    String? cursor,
    int limit = 20,
  }) async {
    cursorsSeen.add(cursor);
    final index = calls++;
    if (failOnPage != null && index == failOnPage) {
      return const Err(NetworkFailure(message: 'offline'));
    }
    if (index >= pages.length) {
      return const Ok(PagedResult.empty());
    }
    return Ok(pages[index]);
  }

  @override
  Future<Result<Review>> patch(String id, {int? rating, String? comment}) =>
      throw UnimplementedError();

  @override
  Future<Result<Review>> respond(String id, {required String response}) =>
      throw UnimplementedError();

  @override
  Future<Result<Review>> withdraw(String id) => throw UnimplementedError();

  @override
  Future<Result<VendorPerformanceDto>> getPerformance() =>
      throw UnimplementedError();
}

Review _review(String connectionId, {String id = 'rev'}) => Review(
      id: id,
      connectionId: connectionId,
      authorType: PartyRole.customer,
      rating: 5,
      state: ReviewState.pendingModeration,
      editableUntil: DateTime.utc(2026, 12, 1),
      createdAt: DateTime.utc(2026, 9, 1),
    );

void main() {
  test('myReview short-circuits without listing', () async {
    final repo = _PagingReviewsRepository(pages: const []);
    final found = await repo.hasAuthoredForConnection(
      'conn-x',
      myReview: _review('conn-x'),
    );
    expect(found, isTrue);
    expect(repo.calls, 0);
  });

  test('walks AUTHOR pages until connection is found', () async {
    final repo = _PagingReviewsRepository(
      pages: [
        PagedResult(
          items: [_review('other-1'), _review('other-2')],
          nextCursor: 'c2',
        ),
        PagedResult(
          items: [_review('conn-target', id: 'rev-target')],
          nextCursor: null,
        ),
      ],
    );

    final found = await repo.hasAuthoredForConnection(
      'conn-target',
      pageSize: 2,
    );

    expect(found, isTrue);
    expect(repo.calls, 2);
    expect(repo.cursorsSeen, [null, 'c2']);
  });

  test('returns false when AUTHOR pages end without a match', () async {
    final repo = _PagingReviewsRepository(
      pages: [
        PagedResult(items: [_review('other')], nextCursor: null),
      ],
    );

    final found = await repo.hasAuthoredForConnection('missing');
    expect(found, isFalse);
    expect(repo.calls, 1);
  });

  test('returns false on list failure so leave-review can open', () async {
    final repo = _PagingReviewsRepository(
      pages: const [],
      failOnPage: 0,
    );

    final found = await repo.hasAuthoredForConnection('conn-x');
    expect(found, isFalse);
  });
}

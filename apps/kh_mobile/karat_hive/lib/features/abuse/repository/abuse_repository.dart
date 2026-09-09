import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final abuseRepositoryProvider = Provider<AbuseRepository>((ref) {
  return AbuseRepository(ref.watch(khApiProvider));
});

class AbuseRepository {
  const AbuseRepository(this._api);
  final KhApi _api;

  Future<Result<AbuseReport>> submit({
    required AbuseEntityType entityType,
    required String entityId,
    required String category,
    required String description,
  }) =>
      _api.abuse.submit(
        entityType: entityType,
        entityId: entityId,
        category: category,
        description: description,
      );
}

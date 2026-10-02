import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';
import '../../../core/firebase/firebase_analytics_service.dart';
import '../repository/connections_repository.dart';

class ConnectionsListController
    extends AsyncNotifier<List<ConnectionForCustomer>> {
  @override
  Future<List<ConnectionForCustomer>> build() async {
    final repo = ref.watch(connectionsRepositoryProvider);
    return _fetch(repo);
  }

  Future<List<ConnectionForCustomer>> _fetch(ConnectionsRepository repo) async {
    final first = await repo.listMine();
    return first.when(
      ok: (page) => _sort(page.items),
      err: (f) => throw f,
    );
  }

  List<ConnectionForCustomer> _sort(List<ConnectionForCustomer> items) {
    final copy = [...items];
    copy.sort((a, b) {
      final aActive = a.state == ConnectionState.active ? 0 : 1;
      final bActive = b.state == ConnectionState.active ? 0 : 1;
      if (aActive != bActive) return aActive - bActive;
      final at = a.identityRevealedAt;
      final bt = b.identityRevealedAt;
      return bt.compareTo(at);
    });
    return copy;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(ref.read(connectionsRepositoryProvider)),
    );
  }
}

final connectionsListProvider = AsyncNotifierProvider.autoDispose<
    ConnectionsListController, List<ConnectionForCustomer>>(
  ConnectionsListController.new,
);

class ConnectionDetailController
    extends AsyncNotifier<ConnectionForCustomer> {
  ConnectionDetailController(this.arg);

  final String arg;

  @override
  Future<ConnectionForCustomer> build() async {
    return _load();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<ConnectionForCustomer> _load() async {
    final repo = ref.read(connectionsRepositoryProvider);
    final hasToken = await _hasAccessToken();
    final r = await repo.getById(arg);
    return r.when(
      ok: (c) {
        _logDetail('connection_detail_ok', hasToken: hasToken, failure: null);
        return c;
      },
      err: (f) {
        _logDetail('connection_detail_err', hasToken: hasToken, failure: f);
        throw f;
      },
    );
  }

  Future<bool> _hasAccessToken() async {
    try {
      final tokens = await ref.read(tokenStorageProvider).read();
      final access = tokens?.accessToken;
      return access != null && access.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _logDetail(
    String event, {
    required bool hasToken,
    required Failure? failure,
  }) {
    try {
      final params = <String, Object>{
        'connection_id': arg,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'has_token': hasToken ? 1 : 0,
        if (failure != null) 'err_type': failure.runtimeType.toString(),
        if (failure?.code != null) 'err_code': failure!.code!,
        if (failure?.message != null && failure!.message!.isNotEmpty)
          'err_message': _clip(failure.message!),
      };
      // ignore: unawaited_futures — fire-and-forget diagnostic
      ref.read(firebaseAnalyticsServiceProvider).logEvent(
            name: event,
            parameters: params,
          );
    } catch (_) {
      // Diagnostics must never break the detail load path.
    }
  }

  static String _clip(String value, [int max = 100]) =>
      value.length <= max ? value : value.substring(0, max);

  Future<Result<void>> talkOpened() {
    return ref.read(connectionsRepositoryProvider).recordContactEvent(
          arg,
          channel: 'WHATSAPP',
        );
  }

  Future<Result<void>> numberCopied() {
    return ref.read(connectionsRepositoryProvider).recordContactEvent(
          arg,
          channel: 'PHONE',
        );
  }

  Future<Result<ConnectionForCustomer>> close({String? reason}) async {
    final r = await ref.read(connectionsRepositoryProvider).close(
          arg,
          reason: reason,
        );
    r.when(
      ok: (c) => state = AsyncData(c),
      err: (_) {},
    );
    return r;
  }
}

final connectionDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ConnectionDetailController, ConnectionForCustomer, String>(
  ConnectionDetailController.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';

/// Composition root. Session-scoped singletons (keep-alive) per
/// Architecture-Frontend §6.2.
final envProvider = Provider<Env>((_) => Env.fromDefines());

final serverClockProvider = Provider<ServerClock>((_) => ServerClock());

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

final apiClientProvider = Provider<KhApiClient>((ref) {
  final env = ref.watch(envProvider);
  final storage = ref.watch(tokenStorageProvider);
  final clock = ref.watch(serverClockProvider);
  late final KhApiClient client;
  client = KhApiClient(
    baseUrl: env.apiBaseUrl,
    tokenStorage: storage,
    serverClock: clock,
    // G2-A14: domain calls use the Karat Hive access token only.
    tokenGetter: () async {
      final tokens = await storage.read();
      return tokens?.accessToken;
    },
    onRefresh: (refreshToken) => KhApi.refresh(client, refreshToken),
  );
  return client;
});

final khApiProvider = Provider<KhApi>((ref) => KhApi(ref.watch(apiClientProvider)));

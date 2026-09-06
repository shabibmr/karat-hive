import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';

import '../core/firebase/firebase_auth_service.dart';

/// Composition root. Session-scoped singletons (keep-alive) per
/// Architecture-Frontend §6.2.
final envProvider = Provider<Env>((_) => Env.fromDefines());

final serverClockProvider = Provider<ServerClock>((_) => ServerClock());

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

final apiClientProvider = Provider<KhApiClient>((ref) {
  final env = ref.watch(envProvider);
  final storage = ref.watch(tokenStorageProvider);
  final clock = ref.watch(serverClockProvider);
  final authService = ref.watch(firebaseAuthServiceProvider);
  late final KhApiClient client;
  client = KhApiClient(
    baseUrl: env.apiBaseUrl,
    tokenStorage: storage,
    serverClock: clock,
    tokenGetter: () async {
      final fbToken = await authService.getIdToken();
      if (fbToken != null && fbToken.isNotEmpty) return fbToken;
      final tokens = await storage.read();
      return tokens?.accessToken;
    },
    onTokenRefresh: () async {
      final fbToken = await authService.getIdToken(forceRefresh: true);
      return fbToken != null && fbToken.isNotEmpty;
    },
    onRefresh: (refreshToken) => KhApi.refresh(client, refreshToken),
  );
  return client;
});

final khApiProvider = Provider<KhApi>((ref) => KhApi(ref.watch(apiClientProvider)));

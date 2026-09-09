import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/auth/auth_broadcast_interface.dart';
import 'package:kh_admin/core/auth/auth_broadcast_stub.dart'
    if (dart.library.js_interop) 'package:kh_admin/core/auth/auth_broadcast_web.dart';

export 'auth_broadcast_interface.dart';

/// Provider for multi-tab auth broadcast channel (TR-S4-05).
final authBroadcastProvider = Provider<AuthBroadcast>((ref) {
  final broadcast = createAuthBroadcast();
  ref.onDispose(() => broadcast.dispose());
  return broadcast;
});

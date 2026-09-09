import 'dart:async';

import 'package:kh_admin/core/auth/auth_broadcast_interface.dart';

/// Non-web fallback stub for [AuthBroadcast].
class PlatformAuthBroadcast implements AuthBroadcast {
  final _controller = StreamController<void>.broadcast();

  @override
  void broadcastLogout() {}

  @override
  Stream<void> get onLogout => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}

AuthBroadcast createAuthBroadcast() => PlatformAuthBroadcast();

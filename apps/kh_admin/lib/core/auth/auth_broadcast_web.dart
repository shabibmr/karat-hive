import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'package:kh_admin/core/auth/auth_broadcast_interface.dart';

/// Web implementation using standard [web.BroadcastChannel] (TR-S4-05).
class WebAuthBroadcast implements AuthBroadcast {
  WebAuthBroadcast() {
    try {
      _channel = web.BroadcastChannel('kh_admin_auth');
      _channel?.onmessage = (web.MessageEvent event) {
        final data = event.data;
        if (data != null) {
          final str = data.dartify()?.toString();
          if (str == 'logout') {
            _controller.add(null);
          }
        }
      }.toJS;
    } on Object catch (_) {
      // Graceful fallback if BroadcastChannel is unsupported
    }
  }

  web.BroadcastChannel? _channel;
  final _controller = StreamController<void>.broadcast();

  @override
  void broadcastLogout() {
    try {
      _channel?.postMessage('logout'.toJS);
    } on Object catch (_) {}
  }

  @override
  Stream<void> get onLogout => _controller.stream;

  @override
  void dispose() {
    try {
      _channel?.close();
    } on Object catch (_) {}
    _controller.close();
  }
}

AuthBroadcast createAuthBroadcast() => WebAuthBroadcast();

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/session/session_controller.dart';

/// In-memory flag: Guest tapped Publish and must finish auth without losing create.
class PendingPublishIntent extends Notifier<bool> {
  @override
  bool build() => false;

  void setPending() => state = true;

  void clearPending() => state = false;
}

final pendingPublishIntentProvider =
    NotifierProvider<PendingPublishIntent, bool>(PendingPublishIntent.new);

/// Vendor login drops guest publish intent (GL-16 / GL-61). Idempotent.
void clearPendingPublishIfVendor(
  SessionState session,
  bool pending,
  void Function() clear, {
  void Function()? resetCreate,
}) {
  if (pending && session is SignedIn && session.isVendor) {
    resetCreate?.call();
    clear();
  }
}

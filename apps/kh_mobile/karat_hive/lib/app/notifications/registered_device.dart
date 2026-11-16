import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Backend id of this install's registered push device, so sign-out can delete
/// it while the session is still authenticated. In-memory only: the device
/// binder re-registers (idempotent upsert) on every signed-in launch.
class RegisteredDeviceId extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) => state = id;

  void clear() => state = null;
}

final registeredDeviceIdProvider =
    NotifierProvider<RegisteredDeviceId, String?>(RegisteredDeviceId.new);

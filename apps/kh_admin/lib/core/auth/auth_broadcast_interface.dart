/// Contract for multi-tab auth broadcast (TR-S4-05 / ADM-INS-85).
abstract class AuthBroadcast {
  void broadcastLogout();
  Stream<void> get onLogout;
  void dispose();
}

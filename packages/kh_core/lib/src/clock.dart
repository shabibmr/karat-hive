/// Server-time offset holder. The client ticks countdowns from server time, never
/// the device clock (Architecture-Frontend §11, C-07).
class ServerClock {
  Duration _offset = Duration.zero;

  void syncFrom(DateTime serverTime) {
    _offset = serverTime.difference(DateTime.now().toUtc());
  }

  DateTime now() => DateTime.now().toUtc().add(_offset);
}

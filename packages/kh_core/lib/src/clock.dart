/// Server-time offset holder. The client ticks countdowns from server time, never
/// the device clock (Architecture-Frontend §11, C-07).
class ServerClock {
  ServerClock({DateTime Function()? nowProvider}) : _nowProvider = nowProvider;

  final DateTime Function()? _nowProvider;
  Duration _offset = Duration.zero;

  void syncFrom(DateTime serverTime) {
    _offset = serverTime.difference(_deviceNow());
  }

  DateTime _deviceNow() => _nowProvider != null ? _nowProvider!() : DateTime.now().toUtc();

  DateTime now() => _deviceNow().add(_offset);
}

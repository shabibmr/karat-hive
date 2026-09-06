import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// Scope to ambiently provide a [ServerClock] down the widget tree.
class ServerClockScope extends InheritedWidget {
  const ServerClockScope({
    super.key,
    required this.clock,
    required super.child,
  });

  final ServerClock clock;

  static ServerClock? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ServerClockScope>()?.clock;

  @override
  bool updateShouldNotify(ServerClockScope oldWidget) => clock != oldWidget.clock;
}

/// Urgency tier for expiry countdown styling per SH-DOM-07 / AD-FE-11.
enum ExpiryUrgency {
  /// More than 24 hours remaining — standard ink styling.
  normal,

  /// Between 6 and 24 hours remaining — amber / gold warning styling.
  warning,

  /// Less than 6 hours remaining — danger styling.
  critical,

  /// Expired (0 or negative time remaining).
  expired,
}

/// SH-DOM-07: The domain-aware expiry countdown widget.
///
/// Features:
/// - Consumes [ServerClock] offset, never bare device time (AD-FE-11, C-07).
/// - Self-contained stateful ticking: updates locally without rebuilding parent lists.
/// - Urgency styling: normal (>24h), warning (<=24h), critical (<=6h), expired (<=0s).
/// - Accessibility: Screen readers receive polite semantic announcements rather than per-second ticks.
class ExpiryCountdown extends StatefulWidget {
  const ExpiryCountdown({
    super.key,
    required this.expiresAt,
    this.clock,
    this.onExpired,
    this.style,
    this.showIcon = true,
    this.expiredLabel = 'Expired',
    this.customFormatter,
  });

  /// Target expiry timestamp in UTC.
  final DateTime expiresAt;

  /// Optional explicit [ServerClock]. If null, resolved from [ServerClockScope]
  /// or a fallback default instance.
  final ServerClock? clock;

  /// Callback invoked once when time expires.
  final VoidCallback? onExpired;

  /// Optional text style override.
  final TextStyle? style;

  /// Whether to display the urgency timer icon.
  final bool showIcon;

  /// Text to display when expired.
  final String expiredLabel;

  /// Optional custom duration formatter.
  final String Function(Duration remaining)? customFormatter;

  @override
  State<ExpiryCountdown> createState() => _ExpiryCountdownState();
}

class _ExpiryCountdownState extends State<ExpiryCountdown> {
  static final ServerClock _defaultClock = ServerClock();

  Timer? _timer;
  ServerClock? _clock;
  late Duration _remaining;
  late ExpiryUrgency _urgency;
  bool _hasNotifiedExpired = false;

  @override
  void initState() {
    super.initState();
    _remaining = Duration.zero;
    _urgency = ExpiryUrgency.normal;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clock = widget.clock ?? ServerClockScope.maybeOf(context) ?? _defaultClock;
    _recompute(notifyOnExpire: true);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ExpiryCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt || oldWidget.clock != widget.clock) {
      _hasNotifiedExpired = false;
      _clock = widget.clock ?? ServerClockScope.maybeOf(context) ?? _defaultClock;
      _recompute(notifyOnExpire: false);
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _recompute({bool notifyOnExpire = true}) {
    final now = (_clock ?? _defaultClock).now();
    final diff = widget.expiresAt.toUtc().difference(now);

    if (diff <= Duration.zero) {
      _remaining = Duration.zero;
      _urgency = ExpiryUrgency.expired;
      _timer?.cancel();
      _timer = null;
      if (notifyOnExpire && !_hasNotifiedExpired) {
        _hasNotifiedExpired = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onExpired?.call();
        });
      }
    } else {
      _remaining = diff;
      if (diff > const Duration(hours: 24)) {
        _urgency = ExpiryUrgency.normal;
      } else if (diff > const Duration(hours: 6)) {
        _urgency = ExpiryUrgency.warning;
      } else {
        _urgency = ExpiryUrgency.critical;
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_urgency == ExpiryUrgency.expired) return;

    // Tick every second without notifying parent widgets
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _recompute(notifyOnExpire: true);
      });
    });
  }

  String _formatDuration(Duration d) {
    if (widget.customFormatter != null) {
      return widget.customFormatter!(d);
    }
    if (d <= Duration.zero) {
      return widget.expiredLabel;
    }

    // Round up milliseconds to avoid displaying 59m 59s when 1h was scheduled
    final totalSeconds = (d.inMilliseconds / 1000).ceil();
    if (totalSeconds <= 0) {
      return widget.expiredLabel;
    }

    final days = totalSeconds ~/ 86400;
    final hours = (totalSeconds % 86400) ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h left';
    }
    if (hours > 0) {
      return '${hours}h ${minutes}m left';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s left';
    }
    return '${seconds}s left';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = _formatDuration(_remaining);

    final (Color color, IconData icon) = switch (_urgency) {
      ExpiryUrgency.normal => (tokens.ink.withValues(alpha: 0.75), Icons.access_time),
      ExpiryUrgency.warning => (const Color(0xFFC8A046), Icons.access_time_filled),
      ExpiryUrgency.critical => (tokens.danger, Icons.warning_amber_rounded),
      ExpiryUrgency.expired => (tokens.danger, Icons.timer_off_outlined),
    };

    final effectiveStyle = (widget.style ?? Theme.of(context).textTheme.labelMedium)
        ?.copyWith(color: color, fontWeight: FontWeight.w600);

    return Semantics(
      label: 'Time remaining: $text',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.showIcon) ...[
              Icon(icon, size: 14, color: color),
              SizedBox(width: tokens.space.xs),
            ],
            Text(
              text,
              style: effectiveStyle,
            ),
          ],
        ),
      ),
    );
  }
}

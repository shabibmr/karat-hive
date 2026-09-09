import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// Default inactivity duration before idle timeout triggers: 60 minutes.
const Duration kDefaultIdleTimeout = Duration(minutes: 60);

/// Default warning duration before idle timeout triggers: 5 minutes.
const Duration kDefaultIdleWarningDuration = Duration(minutes: 5);

/// Pure-Dart manager for tracking idle state and timeout callbacks.
///
/// Can be used standalone or wrapped in [IdleTimeoutListener].
class IdleTimeoutManager {
  IdleTimeoutManager({
    required this.onTimeout,
    this.timeout = kDefaultIdleTimeout,
    bool autoStart = true,
  }) {
    if (autoStart) {
      start();
    }
  }

  /// The callback invoked when inactivity exceeds [timeout].
  final VoidCallback onTimeout;

  /// Duration of inactivity before [onTimeout] is invoked.
  final Duration timeout;

  Timer? _timer;
  DateTime? _lastActivity;
  bool _isPaused = false;

  /// The timestamp of the most recent recorded user activity.
  DateTime? get lastActivity => _lastActivity;

  /// Whether the timeout timer is currently active and ticking.
  bool get isActive => _timer != null && _timer!.isActive;

  /// Whether the manager is currently paused.
  bool get isPaused => _isPaused;

  /// Starts or restarts the idle timeout timer.
  void start() {
    _isPaused = false;
    _resetTimer();
  }

  /// Records user activity and resets the timeout timer.
  void recordActivity() {
    _lastActivity = DateTime.now();
    if (!_isPaused) {
      _resetTimer();
    }
  }

  /// Pauses the idle timeout timer without resetting [lastActivity].
  void pause() {
    _isPaused = true;
    _cancelTimer();
  }

  /// Resumes the idle timeout timer.
  void resume() {
    if (_isPaused) {
      _isPaused = false;
      _resetTimer();
    }
  }

  /// Cancels the idle timeout timer.
  void cancel() {
    _cancelTimer();
  }

  /// Disposes of timer resources.
  void dispose() {
    cancel();
  }

  void _resetTimer() {
    _cancelTimer();
    _timer = Timer(timeout, onTimeout);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

/// A dialog that warns the user that their administrative session is about to expire
/// due to inactivity and provides a live countdown timer with actions to stay logged in or log out.
class IdleWarningDialog extends StatefulWidget {
  const IdleWarningDialog({
    super.key,
    required this.countdown,
    required this.onStayLoggedIn,
    required this.onLogout,
  });

  /// The countdown duration remaining before the session is terminated.
  final Duration countdown;

  /// Callback invoked when the user chooses to stay logged in.
  final VoidCallback onStayLoggedIn;

  /// Callback invoked when the user chooses to log out or countdown reaches zero.
  final VoidCallback onLogout;

  @override
  State<IdleWarningDialog> createState() => _IdleWarningDialogState();
}

class _IdleWarningDialogState extends State<IdleWarningDialog> {
  late int _remainingSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdown.inSeconds;
    if (_remainingSeconds > 0) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_remainingSeconds <= 1) {
          timer.cancel();
          setState(() {
            _remainingSeconds = 0;
          });
          widget.onLogout();
        } else {
          setState(() {
            _remainingSeconds--;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatCountdown(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;

    return AlertDialog(
      key: const Key('idle-warning-dialog'),
      backgroundColor: colors.backgroundElevated,
      shape: RoundedRectangleBorder(
        borderRadius: shapes.roundedMd,
        side: BorderSide(color: colors.borderSubtle),
      ),
      title: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: colors.goldPrimary,
            size: 24,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              'Session Expiring Soon',
              style: typography.title.copyWith(color: colors.textPrimary),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have been inactive for a while. For your security, your session will expire in:',
            style: typography.body.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.md),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.lg,
                vertical: spacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.backgroundSurface,
                borderRadius: shapes.roundedSm,
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Text(
                _formatCountdown(_remainingSeconds),
                key: const Key('idle-warning-countdown'),
                style: typography.displayL.copyWith(
                  color: colors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('idle-logout-button'),
          onPressed: widget.onLogout,
          child: Text(
            'Log Out',
            style: typography.bodySmall.copyWith(color: colors.textMuted),
          ),
        ),
        ElevatedButton(
          key: const Key('idle-stay-logged-in-button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.goldPrimary,
            foregroundColor: colors.backgroundPrimary,
          ),
          onPressed: widget.onStayLoggedIn,
          child: Text(
            'Stay Logged In',
            style: typography.bodySmall.copyWith(
              color: colors.backgroundPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Displays an [IdleWarningDialog] modal dialog to alert the user of impending session timeout.
///
/// Automatically pops the dialog and calls [onStayLoggedIn] or [onLogout] when the
/// corresponding actions occur.
Future<bool?> showIdleWarningDialog(
  BuildContext context, {
  required Duration countdown,
  required VoidCallback onStayLoggedIn,
  required VoidCallback onLogout,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return IdleWarningDialog(
        countdown: countdown,
        onStayLoggedIn: () {
          Navigator.of(dialogContext, rootNavigator: true).maybePop(true);
          onStayLoggedIn();
        },
        onLogout: () {
          Navigator.of(dialogContext, rootNavigator: true).maybePop(false);
          onLogout();
        },
      );
    },
  );
}

/// Inherited widget allowing descendant widgets to access [IdleTimeoutListenerState].
class _InheritedIdleTimeout extends InheritedWidget {
  const _InheritedIdleTimeout({
    required this.state,
    required super.child,
  });

  final IdleTimeoutListenerState state;

  @override
  bool updateShouldNotify(_InheritedIdleTimeout oldWidget) => false;
}

/// A widget that detects user interaction (pointer movements, clicks, hovers,
/// scrolling, and keyboard events) and resets an idle timeout timer.
///
/// If no interaction occurs within [timeout] (default: 60 minutes), logout
/// is triggered. If [warningDuration] is specified (default: 5 minutes), a
/// warning dialog is displayed before logout occurs.
class IdleTimeoutListener extends StatefulWidget {
  const IdleTimeoutListener({
    super.key,
    required this.child,
    this.onTimeout,
    this.onLogout,
    this.onWarning,
    this.timeout = kDefaultIdleTimeout,
    this.warningDuration = kDefaultIdleWarningDuration,
    this.enabled = true,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Invoked when no activity has occurred for [timeout] duration.
  final VoidCallback? onTimeout;

  /// Invoked when user chooses to log out or session times out.
  final VoidCallback? onLogout;

  /// Invoked when the warning phase begins.
  final VoidCallback? onWarning;

  /// Duration of inactivity before idle timeout occurs.
  ///
  /// Defaults to 60 minutes ([kDefaultIdleTimeout]).
  final Duration timeout;

  /// Duration before [timeout] when the warning dialog is presented.
  ///
  /// Defaults to 5 minutes ([kDefaultIdleWarningDuration]).
  /// When `null`, or if [warningDuration] is greater than or equal to [timeout],
  /// the warning phase is bypassed.
  final Duration? warningDuration;

  /// Whether idle detection and timer ticking are enabled.
  ///
  /// Defaults to `true`. When `false`, the timer is cancelled.
  final bool enabled;

  /// Obtains the [IdleTimeoutListenerState] from the given [context].
  static IdleTimeoutListenerState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedIdleTimeout>()
        ?.state;
  }

  /// Resets the idle timer of the nearest [IdleTimeoutListener] ancestor.
  static void resetOf(BuildContext context) {
    final state =
        context.findAncestorStateOfType<IdleTimeoutListenerState>();
    state?.resetTimer(force: true);
  }

  @override
  State<IdleTimeoutListener> createState() => IdleTimeoutListenerState();
}

/// State for [IdleTimeoutListener] exposing methods to programmatically
/// reset, pause, and resume the idle timer.
class IdleTimeoutListenerState extends State<IdleTimeoutListener> {
  Timer? _timer;
  Timer? _logoutTimer;
  bool _isPaused = false;
  bool _isWarningActive = false;
  bool _isLoggingOut = false;
  bool _dialogIsShowing = false;
  BuildContext? _dialogContext;
  DateTime? _lastActivity;

  /// Timestamp of the last recorded user interaction.
  DateTime? get lastActivity => _lastActivity;

  /// Whether the idle detector is paused.
  bool get isPaused => _isPaused;

  /// Whether the countdown timer is currently active.
  bool get isActive =>
      (_timer != null && _timer!.isActive) ||
      (_logoutTimer != null && _logoutTimer!.isActive);

  /// Whether the warning phase is currently active.
  bool get isWarningActive => _isWarningActive;

  Duration? get _effectiveWarningDuration {
    final warning = widget.warningDuration;
    if (warning == null || warning <= Duration.zero) return null;
    if (warning >= widget.timeout) return null;
    return warning;
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    if (widget.enabled) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant IdleTimeoutListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _startTimer();
      } else {
        _cancelTimer();
        _cancelLogoutTimer();
      }
    } else if (widget.enabled &&
        (oldWidget.timeout != widget.timeout ||
            oldWidget.warningDuration != widget.warningDuration)) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _cancelTimer();
    _cancelLogoutTimer();
    _dismissWarningDialog();
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (widget.enabled && !_isPaused) {
      resetTimer();
    }
    return false;
  }

  /// Manually resets the idle timer.
  ///
  /// When [force] is true, resets the timer even if the warning phase is active
  /// (e.g. user clicked "Stay Logged In" or programmatic reset).
  void resetTimer({bool force = false}) {
    if (!mounted || !widget.enabled || _isPaused) return;
    if (_isWarningActive && !force) return;
    if (_isWarningActive) {
      _dismissWarningDialog();
      _isWarningActive = false;
    }
    _isLoggingOut = false;
    _lastActivity = DateTime.now();
    _startTimer();
  }

  /// Pauses the idle timer without triggering logout.
  void pause() {
    _isPaused = true;
    _cancelTimer();
    _cancelLogoutTimer();
  }

  /// Resumes the idle timer.
  void resume() {
    if (_isPaused) {
      _isPaused = false;
      if (widget.enabled) {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _cancelTimer();
    _cancelLogoutTimer();
    _isWarningActive = false;

    final warning = _effectiveWarningDuration;
    if (warning != null) {
      final idleBeforeWarning = widget.timeout - warning;
      _timer = Timer(idleBeforeWarning, _onWarningTriggered);
    } else {
      _timer = Timer(widget.timeout, _onTimeoutTriggered);
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _cancelLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }

  void _dismissWarningDialog() {
    if (_dialogIsShowing && _dialogContext != null) {
      _dialogIsShowing = false;
      Navigator.of(_dialogContext!, rootNavigator: true).maybePop();
      _dialogContext = null;
    }
  }

  void _onWarningTriggered() {
    if (!mounted || !widget.enabled || _isPaused || _isWarningActive) return;
    _isWarningActive = true;

    widget.onWarning?.call();

    final warning = _effectiveWarningDuration;
    if (warning == null) {
      _triggerLogout();
      return;
    }

    final navigator = Navigator.maybeOf(context, rootNavigator: true);
    if (navigator != null) {
      _dialogIsShowing = true;
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) {
          _dialogContext = dialogCtx;
          return IdleWarningDialog(
            countdown: warning,
            onStayLoggedIn: () {
              _dialogIsShowing = false;
              Navigator.of(dialogCtx, rootNavigator: true).maybePop(true);
              if (mounted) {
                resetTimer(force: true);
              }
            },
            onLogout: () {
              _dialogIsShowing = false;
              Navigator.of(dialogCtx, rootNavigator: true).maybePop(false);
              if (mounted) {
                _triggerLogout();
              }
            },
          );
        },
      ).then((_) {
        _dialogIsShowing = false;
        _dialogContext = null;
      });
    }

    _cancelLogoutTimer();
    _logoutTimer = Timer(warning, _onLogoutTimeoutTriggered);
  }

  void _onLogoutTimeoutTriggered() {
    if (!mounted || !widget.enabled || _isPaused) return;
    _triggerLogout();
  }

  void _onTimeoutTriggered() {
    if (!mounted || !widget.enabled || _isPaused) return;
    _triggerLogout();
  }

  void _triggerLogout() {
    if (!mounted || _isLoggingOut) return;
    _isLoggingOut = true;
    _cancelTimer();
    _cancelLogoutTimer();
    if (_isWarningActive) {
      _dismissWarningDialog();
      _isWarningActive = false;
    }

    widget.onLogout?.call();
    widget.onTimeout?.call();

    try {
      final container = ProviderScope.containerOf(context, listen: false);
      container.read(sessionControllerProvider.notifier).logout();
    } on Object catch (_) {
      // ProviderScope not present (e.g. standalone widget test)
    }
  }

  void _onPointerActivity(PointerEvent event) {
    resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedIdleTimeout(
      state: this,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerActivity,
        onPointerMove: _onPointerActivity,
        onPointerUp: _onPointerActivity,
        onPointerHover: _onPointerActivity,
        onPointerSignal: _onPointerActivity,
        onPointerCancel: _onPointerActivity,
        child: MouseRegion(
          opaque: false,
          onHover: (_) => resetTimer(),
          onEnter: (_) => resetTimer(),
          onExit: (_) => resetTimer(),
          child: Focus(
            canRequestFocus: false,
            descendantsAreFocusable: true,
            onKeyEvent: (node, event) {
              resetTimer();
              return KeyEventResult.ignored;
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Alternative alias for [IdleTimeoutListener].
typedef IdleTimeoutDetector = IdleTimeoutListener;

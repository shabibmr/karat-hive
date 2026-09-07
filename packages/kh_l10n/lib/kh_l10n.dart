library kh_l10n;

import 'package:flutter/widgets.dart';

import 'l10n/app_localizations.dart';
import 'src/formatters.dart';
import 'src/strings.dart';

export 'l10n/app_localizations.dart';
export 'src/formatters.dart';
export 'src/strings.dart';

/// Western → Arabic-Indic digit mapping (Architecture-Frontend §14).
String forceArabicIndicDigits(String input) {
  const western = '0123456789';
  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  final buffer = StringBuffer();
  for (final unit in input.codeUnits) {
    final ch = String.fromCharCode(unit);
    final index = western.indexOf(ch);
    buffer.write(index >= 0 ? arabicIndic[index] : ch);
  }
  return buffer.toString();
}

bool isArabicLocale(String locale) =>
    locale.toLowerCase().startsWith('ar');

/// Applies [forceArabicIndicDigits] when [locale] is Arabic.
String localizeDigits(String input, String locale) =>
    isArabicLocale(locale) ? forceArabicIndicDigits(input) : input;

/// Label bundle for [RelativeTimeFormatter] (SH-DOM-08).
class RelativeTimeLabels {
  const RelativeTimeLabels({
    required this.justNow,
    required this.minutesAgo,
    required this.hoursAgo,
    required this.daysAgo,
  });

  final String justNow;
  final String Function(int count) minutesAgo;
  final String Function(int count) hoursAgo;
  final String Function(int count) daysAgo;

  static const RelativeTimeLabels english = RelativeTimeLabels(
    justNow: 'just now',
    minutesAgo: _enMinutesAgo,
    hoursAgo: _enHoursAgo,
    daysAgo: _enDaysAgo,
  );

  static String _enMinutesAgo(int count) => '${count}m ago';
  static String _enHoursAgo(int count) => '${count}h ago';
  static String _enDaysAgo(int count) => '${count}d ago';

  factory RelativeTimeLabels.fromAppLocalizations(AppLocalizations l10n) {
    return RelativeTimeLabels(
      justNow: l10n.relativeTimeJustNow,
      minutesAgo: l10n.relativeTimeMinutesAgo,
      hoursAgo: l10n.relativeTimeHoursAgo,
      daysAgo: l10n.relativeTimeDaysAgo,
    );
  }
}

/// Label bundle for [ExpiryCountdownFormatter] (SH-DOM-07).
class ExpiryLabels {
  const ExpiryLabels({
    required this.expired,
    required this.daysHoursLeft,
    required this.hoursMinutesLeft,
    required this.minutesSecondsLeft,
    required this.secondsLeft,
    required this.timeRemainingSemantics,
  });

  final String expired;
  final String Function(int days, int hours) daysHoursLeft;
  final String Function(int hours, int minutes) hoursMinutesLeft;
  final String Function(int minutes, int seconds) minutesSecondsLeft;
  final String Function(int seconds) secondsLeft;
  final String Function(String text) timeRemainingSemantics;

  static const ExpiryLabels english = ExpiryLabels(
    expired: 'Expired',
    daysHoursLeft: _enDaysHours,
    hoursMinutesLeft: _enHoursMinutes,
    minutesSecondsLeft: _enMinutesSeconds,
    secondsLeft: _enSeconds,
    timeRemainingSemantics: _enSemantics,
  );

  static String _enDaysHours(int days, int hours) => '${days}d ${hours}h left';
  static String _enHoursMinutes(int hours, int minutes) =>
      '${hours}h ${minutes}m left';
  static String _enMinutesSeconds(int minutes, int seconds) =>
      '${minutes}m ${seconds}s left';
  static String _enSeconds(int seconds) => '${seconds}s left';
  static String _enSemantics(String text) => 'Time remaining: $text';

  factory ExpiryLabels.fromAppLocalizations(AppLocalizations l10n) {
    return ExpiryLabels(
      expired: l10n.expiryExpired,
      daysHoursLeft: l10n.expiryDaysHoursLeft,
      hoursMinutesLeft: l10n.expiryHoursMinutesLeft,
      minutesSecondsLeft: l10n.expiryMinutesSecondsLeft,
      secondsLeft: l10n.expirySecondsLeft,
      timeRemainingSemantics: l10n.expiryTimeRemainingSemantics,
    );
  }
}

class ExpiryCountdownFormatter {
  static String format(
    Duration remaining, {
    String locale = 'en',
    ExpiryLabels? labels,
    String? expiredLabel,
  }) {
    final resolved = labels ?? ExpiryLabels.english;
    final expired = expiredLabel ?? resolved.expired;

    if (remaining <= Duration.zero) {
      return localizeDigits(expired, locale);
    }

    final totalSeconds = (remaining.inMilliseconds / 1000).ceil();
    if (totalSeconds <= 0) {
      return localizeDigits(expired, locale);
    }

    final days = totalSeconds ~/ 86400;
    final hours = (totalSeconds % 86400) ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final String text;
    if (days > 0) {
      text = resolved.daysHoursLeft(days, hours);
    } else if (hours > 0) {
      text = resolved.hoursMinutesLeft(hours, minutes);
    } else if (minutes > 0) {
      text = resolved.minutesSecondsLeft(minutes, seconds);
    } else {
      text = resolved.secondsLeft(seconds);
    }
    return localizeDigits(text, locale);
  }

  static String semanticsLabel(
    String formatted, {
    String locale = 'en',
    ExpiryLabels? labels,
  }) {
    final resolved = labels ?? ExpiryLabels.english;
    return localizeDigits(
      resolved.timeRemainingSemantics(formatted),
      locale,
    );
  }
}

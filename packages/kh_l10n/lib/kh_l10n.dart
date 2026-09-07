library kh_l10n;

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';

export 'l10n/app_localizations.dart';

/// Locale / delegate helper for Karat Hive surfaces.
///
/// User-facing copy lives in ARB → [AppLocalizations] (CP2-F05).
class KhStrings {
  KhStrings(this.locale);
  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    _KhStringsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static KhStrings of(BuildContext context) =>
      Localizations.of<KhStrings>(context, KhStrings) ?? KhStrings(const Locale('en'));

  bool get isRtl => locale.languageCode == 'ar';
}

class _KhStringsDelegate extends LocalizationsDelegate<KhStrings> {
  const _KhStringsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<KhStrings> load(Locale locale) async => KhStrings(locale);

  @override
  bool shouldReload(_KhStringsDelegate old) => false;
}

/// Western → Arabic-Indic digit mapping (Architecture-Frontend §14).
///
/// `intl` `ar_AE` / generic `ar` ship `ZERO_DIGIT=0`; only locales like `ar_EG`
/// emit Eastern Arabic numerals. Product preference is Arabic-Indic for every
/// Arabic formatter output, so we force the mapping after NumberFormat / ICU.
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

/// AED money formatting lives in exactly one place (Architecture-Frontend §8.4).
class MoneyFormatter {
  static String aed(num amount, {String locale = 'en'}) {
    final isAr = isArabicLocale(locale);
    final formatted = NumberFormat.currency(
      locale: isAr ? 'ar_AE' : 'en_AE',
      symbol: 'AED ',
    ).format(amount);
    return localizeDigits(formatted, locale);
  }
}

/// Label bundle for [RelativeTimeFormatter] (SH-DOM-08).
///
/// Widgets resolve copy from [AppLocalizations]; pure-Dart callers keep the
/// English defaults so kh_ui_domain stays free of a hard Flutter l10n coupling.
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

class RelativeTimeFormatter {
  static String since(
    DateTime past, {
    DateTime? now,
    String locale = 'en',
    RelativeTimeLabels? labels,
  }) {
    final resolved = labels ?? RelativeTimeLabels.english;
    final d = (now ?? DateTime.now().toUtc()).difference(past);
    final String text;
    if (d.inMinutes < 1) {
      text = resolved.justNow;
    } else if (d.inHours < 1) {
      text = resolved.minutesAgo(d.inMinutes);
    } else if (d.inDays < 1) {
      text = resolved.hoursAgo(d.inHours);
    } else {
      text = resolved.daysAgo(d.inDays);
    }
    return localizeDigits(text, locale);
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

    // Round up milliseconds to avoid displaying 59m 59s when 1h was scheduled.
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

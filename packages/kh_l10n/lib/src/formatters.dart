import 'package:intl/intl.dart';
import 'package:kh_l10n/src/strings.dart';

String _language(String locale) => locale.startsWith('ar') ? 'ar' : 'en';

String _icuLocale(String locale) =>
    _language(locale) == 'ar' ? 'ar_AE' : 'en_AE';

/// AED money formatting lives in exactly one place (Architecture-Frontend §8.4).
/// Widgets must not concatenate a currency code onto a raw number (`SH-DOM-03`).
class MoneyFormatter {
  static String aed(num amount, {String locale = 'en'}) =>
      NumberFormat.currency(locale: _icuLocale(locale), symbol: 'AED ').format(
        amount,
      );
}

/// Grams with a mandatory two decimal places and unit (`SH-DOM-05`, C-02).
class WeightFormatter {
  static String grams(num grams, {String locale = 'en'}) {
    final n = NumberFormat('0.00', _icuLocale(locale)).format(grams);
    final unit = _language(locale) == 'ar' ? 'غ' : 'g';
    return '$n $unit';
  }
}

/// Karat (K) and fineness (parts per thousand) (`SH-DOM-06`, C-02).
class KaratFormatter {
  static String karat(int karat, {String locale = 'en'}) {
    final n = NumberFormat('0', _icuLocale(locale)).format(karat);
    return '${n}K';
  }

  static String fineness(int fineness, {String locale = 'en'}) =>
      NumberFormat('000', _icuLocale(locale)).format(fineness);

  static String karatAndFineness(
    int karat,
    int fineness, {
    String locale = 'en',
  }) =>
      '${KaratFormatter.karat(karat, locale: locale)} (${KaratFormatter.fineness(fineness, locale: locale)})';
}

/// Relative time (`SH-DOM-08`). Locale copy comes from [KhStrings], not widgets.
class RelativeTimeFormatter {
  static String since(DateTime past, {DateTime? now, String locale = 'en'}) {
    final strings = KhStrings.fromLanguage(locale);
    final end = (now ?? DateTime.now()).toUtc();
    final d = end.difference(past.toUtc());
    if (d.inMinutes < 1) return strings.s('time.justNow');
    if (d.inHours < 1) {
      return strings.s('time.minutesAgo').replaceAll('{n}', '${d.inMinutes}');
    }
    if (d.inDays < 1) {
      return strings.s('time.hoursAgo').replaceAll('{n}', '${d.inHours}');
    }
    return strings.s('time.daysAgo').replaceAll('{n}', '${d.inDays}');
  }
}

/// Gulf Standard Time display from a UTC instant (`BR-021`, C-01). UAE has no DST.
class GstFormatter {
  static const offset = Duration(hours: 4);

  static const _enMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _arMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  /// Wall-clock fields in GST (not a zoned [DateTime]).
  static DateTime toGst(DateTime instant) {
    final utc = instant.toUtc();
    final shifted = utc.add(offset);
    return DateTime(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
      shifted.second,
      shifted.millisecond,
      shifted.microsecond,
    );
  }

  static String display(DateTime utc, {String locale = 'en'}) {
    final w = toGst(utc);
    final ar = _language(locale) == 'ar';
    final months = ar ? _arMonths : _enMonths;
    final day = ar ? NumberFormat('0', 'ar').format(w.day) : '${w.day}';
    final year = ar ? NumberFormat('0000', 'ar').format(w.year) : '${w.year}';
    final hh = ar
        ? NumberFormat('00', 'ar').format(w.hour)
        : w.hour.toString().padLeft(2, '0');
    final mm = ar
        ? NumberFormat('00', 'ar').format(w.minute)
        : w.minute.toString().padLeft(2, '0');
    return '$day ${months[w.month - 1]} $year, $hh:$mm GST';
  }
}

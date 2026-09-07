import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_l10n/kh_l10n.dart';

void main() {
  group('forceArabicIndicDigits', () {
    test('maps western digits and leaves other glyphs', () {
      expect(forceArabicIndicDigits('AED 1,250.50'), 'AED ١,٢٥٠.٥٠');
      expect(forceArabicIndicDigits('12h 0m left'), '١٢h ٠m left');
    });
  });

  group('MoneyFormatter (SH-DOM-03)', () {
    test('formats AED in English with Western digits', () {
      final text = MoneyFormatter.aed(1250.5, locale: 'en');
      expect(text, contains('AED'));
      expect(text, contains('1,250.50'));
      expect(text.contains('١'), isFalse);
    });

    test('forces Arabic-Indic digits for ar locale (ar_AE is Latin in intl)', () {
      final text = MoneyFormatter.aed(1250.5, locale: 'ar');
      expect(text, contains('AED'));
      expect(text, contains('١'));
      expect(text, contains('٢٥٠'));
    });

    test('ar_AE language tag also forces Arabic-Indic digits', () {
      final text = MoneyFormatter.aed(42, locale: 'ar_AE');
      expect(text, contains('٤٢'));
    });

    test('AED uses two decimal places', () {
      expect(MoneyFormatter.aed(10, locale: 'en'), contains('10.00'));
    });

    test('KhStrings.aed delegates to MoneyFormatter with instance locale', () {
      final en = KhStrings(const Locale('en'));
      expect(en.aed(99), MoneyFormatter.aed(99, locale: 'en'));
    });
  });

  group('WeightFormatter (SH-DOM-05)', () {
    test('grams always two decimal places with unit', () {
      expect(WeightFormatter.grams(12.5, locale: 'en'), '12.50 g');
      expect(WeightFormatter.grams(0.1, locale: 'en'), '0.10 g');
    });

    test('grams Arabic includes a unit (no widget concatenation)', () {
      final formatted = WeightFormatter.grams(12.5, locale: 'ar');
      expect(formatted, isNot(equals('12.5')));
      expect(formatted, contains('غ'));
    });
  });

  group('KaratFormatter (SH-DOM-06)', () {
    test('karat uses K suffix (C-02)', () {
      expect(KaratFormatter.karat(24, locale: 'en'), '24K');
      expect(KaratFormatter.karat(22, locale: 'en'), '22K');
      expect(KaratFormatter.karat(21, locale: 'en'), '21K');
      expect(KaratFormatter.karat(18, locale: 'en'), '18K');
    });

    test('fineness is three-digit parts-per-thousand', () {
      expect(KaratFormatter.fineness(999, locale: 'en'), '999');
      expect(KaratFormatter.fineness(916, locale: 'en'), '916');
      expect(KaratFormatter.fineness(875, locale: 'en'), '875');
      expect(KaratFormatter.fineness(750, locale: 'en'), '750');
    });

    test('karatAndFineness pairs both without widget interpolation of K', () {
      expect(KaratFormatter.karatAndFineness(22, 916, locale: 'en'), '22K (916)');
    });
  });

  group('RelativeTimeFormatter (SH-DOM-08)', () {
    final now = DateTime.utc(2026, 9, 7, 12, 0, 0);

    test('English buckets match defaults', () {
      expect(
        RelativeTimeFormatter.since(now.subtract(const Duration(seconds: 20)), now: now),
        'just now',
      );
      expect(
        RelativeTimeFormatter.since(now.subtract(const Duration(minutes: 5)), now: now),
        '5m ago',
      );
      expect(
        RelativeTimeFormatter.since(now.subtract(const Duration(hours: 2)), now: now),
        '2h ago',
      );
      expect(
        RelativeTimeFormatter.since(now.subtract(const Duration(days: 3)), now: now),
        '3d ago',
      );
    });

    test('Arabic locale via KhStrings', () {
      expect(
        RelativeTimeFormatter.since(
          now.subtract(const Duration(seconds: 20)),
          now: now,
          locale: 'ar',
        ),
        isNot(equals('just now')),
      );
      expect(
        RelativeTimeFormatter.since(
          now.subtract(const Duration(hours: 2)),
          now: now,
          locale: 'ar',
        ),
        isNot(contains('ago')),
      );
    });

    test('injected labels are used and digit-localised', () {
      final labels = RelativeTimeLabels(
        justNow: 'الآن',
        minutesAgo: (n) => 'منذ $n د',
        hoursAgo: (n) => 'منذ $n س',
        daysAgo: (n) => 'منذ $n ي',
      );
      expect(
        RelativeTimeFormatter.since(
          now.subtract(const Duration(hours: 2)),
          now: now,
          locale: 'ar',
          labels: labels,
        ),
        'منذ ٢ س',
      );
    });
  });

  group('ExpiryCountdownFormatter', () {
    test('English defaults match widget contract', () {
      expect(
        ExpiryCountdownFormatter.format(Duration.zero),
        'Expired',
      );
      expect(
        ExpiryCountdownFormatter.format(const Duration(hours: 36)),
        '1d 12h left',
      );
      expect(
        ExpiryCountdownFormatter.format(const Duration(hours: 12)),
        '12h 0m left',
      );
      expect(
        ExpiryCountdownFormatter.format(const Duration(minutes: 3, seconds: 5)),
        '3m 5s left',
      );
      expect(
        ExpiryCountdownFormatter.format(const Duration(seconds: 5)),
        '5s left',
      );
    });

    test('Arabic locale forces Indic digits', () {
      expect(
        ExpiryCountdownFormatter.format(
          const Duration(hours: 12),
          locale: 'ar',
        ),
        '١٢h ٠m left',
      );
    });

    test('semantics label is localisable', () {
      expect(
        ExpiryCountdownFormatter.semanticsLabel('12h 0m left'),
        'Time remaining: 12h 0m left',
      );
      final labels = ExpiryLabels(
        expired: 'منتهية',
        daysHoursLeft: (d, h) => 'متبقي $dي $hس',
        hoursMinutesLeft: (h, m) => 'متبقي $hس $mد',
        minutesSecondsLeft: (m, s) => 'متبقي $mد $sث',
        secondsLeft: (s) => 'متبقي $sث',
        timeRemainingSemantics: (t) => 'الوقت المتبقي: $t',
      );
      expect(
        ExpiryCountdownFormatter.semanticsLabel(
          'متبقي ١٢س ٠د',
          locale: 'ar',
          labels: labels,
        ),
        'الوقت المتبقي: متبقي ١٢س ٠د',
      );
    });
  });

  group('GstFormatter (BR-021, C-01)', () {
    test('displays UTC instant in Gulf Standard Time (UTC+4)', () {
      final utc = DateTime.utc(2026, 9, 7, 12, 0);
      expect(GstFormatter.display(utc, locale: 'en'), '7 Sep 2026, 16:00 GST');
    });

    test('toGst shifts by four hours without DST', () {
      final utc = DateTime.utc(2026, 1, 1, 22, 30);
      final gst = GstFormatter.toGst(utc);
      expect(gst.hour, 2);
      expect(gst.day, 2);
    });

    test('Arabic display still labels GST and is not the UTC clock', () {
      final utc = DateTime.utc(2026, 9, 7, 12, 0);
      final ar = GstFormatter.display(utc, locale: 'ar');
      expect(ar, contains('GST'));
      expect(ar, isNot(contains('12:00')));
    });
  });
}

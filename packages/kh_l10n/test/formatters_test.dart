import 'package:flutter_test/flutter_test.dart';
import 'package:kh_l10n/kh_l10n.dart';

void main() {
  group('forceArabicIndicDigits', () {
    test('maps western digits and leaves other glyphs', () {
      expect(forceArabicIndicDigits('AED 1,250.50'), 'AED ١,٢٥٠.٥٠');
      expect(forceArabicIndicDigits('12h 0m left'), '١٢h ٠m left');
    });
  });

  group('MoneyFormatter', () {
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
      // No Western digits remain in the numeric portion.
      expect(RegExp(r'[0-9]').hasMatch(text), isFalse);
    });

    test('ar_AE language tag also forces Arabic-Indic digits', () {
      final text = MoneyFormatter.aed(42, locale: 'ar_AE');
      expect(RegExp(r'[0-9]').hasMatch(text), isFalse);
      expect(text, contains('٤٢'));
    });
  });

  group('RelativeTimeFormatter', () {
    final now = DateTime.utc(2026, 9, 7, 12, 0, 0);

    test('English defaults match CP-1 copy', () {
      expect(
        RelativeTimeFormatter.since(
          now.subtract(const Duration(seconds: 30)),
          now: now,
        ),
        'just now',
      );
      expect(
        RelativeTimeFormatter.since(
          now.subtract(const Duration(minutes: 5)),
          now: now,
        ),
        '5m ago',
      );
      expect(
        RelativeTimeFormatter.since(
          now.subtract(const Duration(hours: 2)),
          now: now,
        ),
        '2h ago',
      );
      expect(
        RelativeTimeFormatter.since(
          now.subtract(const Duration(days: 3)),
          now: now,
        ),
        '3d ago',
      );
    });

    test('Arabic locale forces Indic digits on default English labels', () {
      expect(
        RelativeTimeFormatter.since(
          now.subtract(const Duration(hours: 2)),
          now: now,
          locale: 'ar',
        ),
        '٢h ago',
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
}

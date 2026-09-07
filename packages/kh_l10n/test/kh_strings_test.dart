import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_l10n/kh_l10n.dart';

void main() {
  const customerKeys = [
    'shell.nav.home',
    'shell.nav.requests',
    'shell.nav.connections',
    'shell.nav.alerts',
    'shell.nav.profile',
    'auth.googleSignIn',
    'auth.registerCustomer',
    'auth.displayName',
    'auth.emailOptional',
    'auth.termsOfService',
    'auth.privacyPolicy',
    'auth.acceptTerms',
    'auth.acceptPrivacy',
    'auth.createAccount',
    'auth.continueAsCustomer',
    'auth.continueAsVendor',
  ];

  test('EN and AR tables share every key', () {
    final en = KhStrings(const Locale('en'));
    final ar = KhStrings(const Locale('ar'));
    expect(en.tableKeys.toSet(), ar.tableKeys.toSet());
  });

  test('Customer shell and auth keys exist in EN and AR (not identity fallback)', () {
    final en = KhStrings(const Locale('en'));
    final ar = KhStrings(const Locale('ar'));
    for (final key in customerKeys) {
      expect(en.s(key), isNot(equals(key)), reason: 'missing EN $key');
      expect(ar.s(key), isNot(equals(key)), reason: 'missing AR $key');
      expect(en.s(key), isNotEmpty);
      expect(ar.s(key), isNotEmpty);
      expect(en.s(key), isNot(equals(ar.s(key))), reason: '$key should differ by locale');
    }
  });

  test('Google sign-in and Customer register copy is Customer-facing', () {
    final en = KhStrings(const Locale('en'));
    expect(en.s('auth.googleSignIn').toLowerCase(), contains('google'));
    expect(en.s('auth.registerCustomer').toLowerCase(), contains('customer'));
    expect(en.s('auth.termsOfService').toLowerCase(), contains('terms'));
    expect(en.s('auth.privacyPolicy').toLowerCase(), contains('privacy'));
  });

  test('Vendor register key is unchanged', () {
    final en = KhStrings(const Locale('en'));
    expect(en.s('auth.register'), 'Create a vendor account');
  });

  test('Customer nav labels match ui-mock destinations', () {
    final en = KhStrings(const Locale('en'));
    expect(en.s('shell.nav.home'), 'Home');
    expect(en.s('shell.nav.requests'), 'Requests');
    expect(en.s('shell.nav.connections'), 'Connections');
    expect(en.s('shell.nav.alerts'), 'Alerts');
    expect(en.s('shell.nav.profile'), 'Profile');
  });
}

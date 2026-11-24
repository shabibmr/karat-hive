import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// Keys passed to [KhStrings.s] must exist. A miss renders the key itself.
void main() {
  test('every KhStrings.s lookup resolves in EN and AR', () {
    final keys = _literalKeys(_libDir()).followedBy(_expandedKeys());
    final en = KhStrings(const Locale('en'));
    final ar = KhStrings(const Locale('ar'));
    final missing = <String>[];
    for (final key in keys.toSet()) {
      if (en.s(key) == key) missing.add('EN $key');
      if (ar.s(key) == key) missing.add('AR $key');
    }
    expect(missing, isEmpty);
  });
}

Directory _libDir() {
  final direct = Directory('lib');
  if (direct.existsSync()) return direct;
  fail('lib/ not found from ${Directory.current.path}');
}

/// String literals inside each `.s(...)` call, including a key on the next line.
Iterable<String> _literalKeys(Directory lib) sync* {
  final call = RegExp(r'\.s\(');
  final quoted = RegExp(r"'([^'$]+)'");
  for (final entity in lib.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final source = entity.readAsStringSync();
    for (final match in call.allMatches(source)) {
      final close = _matchingParen(source, match.end - 1);
      if (close < 0) continue;
      final args = source.substring(match.end, close);
      for (final key in quoted.allMatches(args)) {
        yield key.group(1)!;
      }
    }
  }
}

int _matchingParen(String source, int open) {
  var depth = 0;
  for (var i = open; i < source.length; i++) {
    final char = source.codeUnitAt(i);
    if (char == 0x28) {
      depth++;
    } else if (char == 0x29) {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}

/// Interpolated lookups. Decline and cancel omit `UNKNOWN`: those screens
/// never pass that wire into `s`.
Iterable<String> _expandedKeys() sync* {
  for (var i = 1; i <= 3; i++) {
    yield 'cus.home.editorial.$i.a';
    yield 'cus.home.editorial.$i.b';
    yield 'cus.home.editorial.$i.c';
  }
  for (final type in RequestType.values) {
    yield 'cus.requestType.${type.wire}';
  }
  for (final state in RequestState.values) {
    yield 'cus.state.${state.wire}';
  }
  for (final reason in const [
    'CHANGED_MIND',
    'FOUND_ELSEWHERE',
    'WRONG_DETAILS',
    'OTHER',
  ]) {
    yield 'cus.cancel.$reason';
  }
  for (final reason in const [
    OfferDeclineReason.priceTooHigh,
    OfferDeclineReason.termsUnsuitable,
    OfferDeclineReason.noLongerRequired,
    OfferDeclineReason.other,
  ]) {
    yield 'cus.decline.${reason.wire}';
  }
}

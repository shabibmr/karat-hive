import 'package:flutter/material.dart';

/// Design tokens exposed through a ThemeExtension so feature code reads
/// `context.tokens.space.md`, never a raw value (Architecture-Frontend §8.1).
@immutable
class KhTokens extends ThemeExtension<KhTokens> {
  const KhTokens({
    required this.gold,
    required this.ink,
    required this.surface,
    required this.danger,
    required this.success,
    required this.radius,
    required this.space,
  });

  final Color gold;
  final Color ink;
  final Color surface;
  final Color danger;
  final Color success;
  final KhRadius radius;
  final KhSpace space;

  static const light = KhTokens(
    gold: Color(0xFFC8A046),
    ink: Color(0xFF1C1B1A),
    surface: Color(0xFFFDFBF7),
    danger: Color(0xFFB3261E),
    success: Color(0xFF2E7D32),
    radius: KhRadius(),
    space: KhSpace(),
  );

  @override
  KhTokens copyWith({
    Color? gold,
    Color? ink,
    Color? surface,
    Color? danger,
    Color? success,
    KhRadius? radius,
    KhSpace? space,
  }) =>
      KhTokens(
        gold: gold ?? this.gold,
        ink: ink ?? this.ink,
        surface: surface ?? this.surface,
        danger: danger ?? this.danger,
        success: success ?? this.success,
        radius: radius ?? this.radius,
        space: space ?? this.space,
      );

  @override
  KhTokens lerp(ThemeExtension<KhTokens>? other, double t) => this;
}

class KhSpace {
  const KhSpace();
  double get xs => 4;
  double get sm => 8;
  double get md => 16;
  double get lg => 24;
  double get xl => 32;
}

class KhRadius {
  const KhRadius();
  double get sm => 8;
  double get md => 12;
  double get lg => 20;
}

extension KhTokensX on BuildContext {
  KhTokens get tokens => Theme.of(this).extension<KhTokens>() ?? KhTokens.light;
}

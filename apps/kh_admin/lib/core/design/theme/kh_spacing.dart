import 'package:flutter/material.dart';

/// Admin-density spacing tokens.
/// Compact spacing for desktop admin views to support data-dense tables and trees.
@immutable
class KhSpacing extends ThemeExtension<KhSpacing> {
  const KhSpacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
    required this.treeIndent,
    required this.tableRowHeight,
    required this.sidebarWidth,
    required this.topBarHeight,
    required this.buttonHeight,
    required this.inputHeight,
  });

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  final double treeIndent;
  final double tableRowHeight;
  final double sidebarWidth;
  final double topBarHeight;
  final double buttonHeight;
  final double inputHeight;

  static const admin = KhSpacing(
    xxs: 2.0,
    xs: 4.0,
    sm: 8.0,
    md: 12.0,
    lg: 16.0,
    xl: 24.0,
    xxl: 32.0,
    xxxl: 48.0,
    treeIndent: 24.0,
    tableRowHeight: 44.0,
    sidebarWidth: 260.0,
    topBarHeight: 56.0,
    buttonHeight: 36.0,
    inputHeight: 40.0,
  );

  @override
  KhSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? treeIndent,
    double? tableRowHeight,
    double? sidebarWidth,
    double? topBarHeight,
    double? buttonHeight,
    double? inputHeight,
  }) {
    return KhSpacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
      treeIndent: treeIndent ?? this.treeIndent,
      tableRowHeight: tableRowHeight ?? this.tableRowHeight,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      topBarHeight: topBarHeight ?? this.topBarHeight,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      inputHeight: inputHeight ?? this.inputHeight,
    );
  }

  @override
  KhSpacing lerp(ThemeExtension<KhSpacing>? other, double t) {
    if (other is! KhSpacing) return this;
    return KhSpacing(
      xxs: _lerpDouble(xxs, other.xxs, t),
      xs: _lerpDouble(xs, other.xs, t),
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      xxl: _lerpDouble(xxl, other.xxl, t),
      xxxl: _lerpDouble(xxxl, other.xxxl, t),
      treeIndent: _lerpDouble(treeIndent, other.treeIndent, t),
      tableRowHeight: _lerpDouble(tableRowHeight, other.tableRowHeight, t),
      sidebarWidth: _lerpDouble(sidebarWidth, other.sidebarWidth, t),
      topBarHeight: _lerpDouble(topBarHeight, other.topBarHeight, t),
      buttonHeight: _lerpDouble(buttonHeight, other.buttonHeight, t),
      inputHeight: _lerpDouble(inputHeight, other.inputHeight, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

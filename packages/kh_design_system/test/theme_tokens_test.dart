import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// V01 — locks plan §5 tokens, button chrome, and nav selection.
void main() {
  test('KhTokens.light matches visual-pass table', () {
    const t = KhTokens.light;
    expect(t.gold, const Color(0xFFD8A858));
    expect(t.goldDark, const Color(0xFF8A6A1F));
    expect(t.ctaFill, const Color(0xFFD8C0A8));
    expect(t.formSurface, const Color(0xFFF0E8E0));
    expect(t.ink, const Color(0xFF1C1B1A));
    expect(t.surface, const Color(0xFFFDFBF7));
    expect(t.navBackground, const Color(0xFFF6F1E6));
    expect(t.radius.button, 10);
    expect(t.radius.pill, 24);
  });

  testWidgets('primary FilledButton uses ctaFill, ink label, radius 10',
      (tester) async {
    late ButtonStyle style;
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Builder(
          builder: (context) {
            style = Theme.of(context).filledButtonTheme.style!;
            return Scaffold(
              body: FilledButton(
                onPressed: () {},
                child: const Text('Continue'),
              ),
            );
          },
        ),
      ),
    );

    final bg = style.backgroundColor!.resolve({});
    final fg = style.foregroundColor!.resolve({});
    final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
    final minSize = style.minimumSize!.resolve({})!;

    expect(bg, KhTokens.light.ctaFill);
    expect(fg, KhTokens.light.ink);
    expect(
      shape.borderRadius,
      BorderRadius.circular(KhTokens.light.radius.button),
    );
    expect(minSize.height, 48);
    expect(style.elevation!.resolve({}), 0);
  });

  testWidgets('NavigationBarTheme uses goldDark selection and no stadium',
      (tester) async {
    late ThemeData theme;
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final nav = theme.navigationBarTheme;
    expect(nav.height, 80);
    expect(nav.elevation, 0);
    expect(nav.indicatorColor, Colors.transparent);

    final selectedLabel = nav.labelTextStyle!.resolve({WidgetState.selected})!;
    final idleLabel = nav.labelTextStyle!.resolve({})!;
    expect(selectedLabel.color, KhTokens.light.goldDark);
    expect(idleLabel.color, KhTokens.light.inkNavIdle);

    final selectedIcon = nav.iconTheme!.resolve({WidgetState.selected})!;
    final idleIcon = nav.iconTheme!.resolve({})!;
    expect(selectedIcon.color, KhTokens.light.goldDark);
    expect(idleIcon.color, KhTokens.light.inkNavIdle);
  });
}

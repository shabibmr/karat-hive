import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/design/theme/kh_colors.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';

void main() {
  test('buildKhAdminTheme defaults to light', () {
    final theme = buildKhAdminTheme();
    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, KhColors.light.backgroundPrimary);
    expect(
      theme.extension<KhThemeExtension>()!.colors.textPrimary,
      KhColors.light.textPrimary,
    );
  });

  test('buildKhAdminTheme dark keeps sapphire canvas', () {
    final theme = buildKhAdminTheme(Brightness.dark);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, KhColors.dark.backgroundPrimary);
    expect(
      theme.extension<KhThemeExtension>()!.colors.textPrimary,
      KhColors.dark.textPrimary,
    );
  });

  testWidgets('light theme paints cream scaffold and sapphire body text',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildKhAdminTheme(Brightness.light),
        home: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: context.kh.colors.backgroundPrimary,
              body: Text(
                'Hello Admin',
                style: context.kh.typography.body,
              ),
            );
          },
        ),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, KhColors.light.backgroundPrimary);

    final text = tester.widget<Text>(find.text('Hello Admin'));
    expect(text.style?.color, KhColors.light.textPrimary);
  });
}

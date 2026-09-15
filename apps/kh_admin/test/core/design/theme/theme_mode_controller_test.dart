import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/design/theme/theme_mode_controller.dart';
import 'package:kh_admin/core/design/theme/theme_preference_store.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';

void main() {
  test('theme mode defaults to light', () {
    final container = ProviderContainer(
      overrides: [
        themePreferenceStoreProvider.overrideWithValue(ThemePreferenceStore()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('toggle switches between light and dark and persists', () {
    final store = ThemePreferenceStore();
    final container = ProviderContainer(
      overrides: [
        themePreferenceStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(themeModeProvider.notifier);
    controller.toggle();
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(store.read(), ThemeMode.dark);

    controller.toggle();
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(store.read(), ThemeMode.light);
  });

  test('restores persisted dark preference on create', () {
    final store = ThemePreferenceStore()..write(ThemeMode.dark);
    final container = ProviderContainer(
      overrides: [
        themePreferenceStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  testWidgets('MaterialApp follows themeModeProvider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final mode = ref.watch(themeModeProvider);
            final isDark = mode == ThemeMode.dark;
            return MaterialApp(
              theme: buildKhAdminTheme(Brightness.light),
              darkTheme: buildKhAdminTheme(Brightness.dark),
              themeMode: mode,
              home: Scaffold(
                body: Column(
                  children: [
                    Text(isDark ? 'dark' : 'light'),
                    IconButton(
                      key: const Key('theme-mode-toggle'),
                      icon: const Icon(Icons.dark_mode_outlined),
                      onPressed: () =>
                          ref.read(themeModeProvider.notifier).toggle(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('light'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('light'))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byKey(const Key('theme-mode-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('dark'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('dark'))).brightness,
      Brightness.dark,
    );
  });
}

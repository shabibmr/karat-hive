# kh_design_system

Tokens, theme and the `Kh*` primitive widgets. **Domain-free** — no `kh_domain`, no API types, no business rules. Anything that knows what a Request is belongs in `kh_ui_domain`.

`src/tokens.dart` and `src/theme.dart` are the single source of colour, spacing and typography. A raw `Color(0x…)` or bare `EdgeInsets` number in a widget here is a token that should exist.

## Goldens

`test/goldens/` stores an **LTR and an RTL** PNG per widget (`kh_app_bar_ltr.png`, `kh_app_bar_rtl.png`). CI runs `flutter test --update-goldens=false` in this package, so any visual change fails until the goldens are regenerated — and both directions must be regenerated together.

Regenerate deliberately, from this directory:

```
flutter test --update-goldens
```

Review the diff before committing; a golden refreshed to hide an unintended change is the failure mode this suite exists to catch.

A new primitive needs a widget test, both goldens, and an export in `lib/kh_design_system.dart`.

# kh_l10n

English and Arabic copy plus the domain formatters. `AppLocalizations` is aliased as `KhL10n`.

## ARB → generated Dart

`lib/l10n/app_en.arb` is the template; `app_ar.arb` must carry the same keys. Regeneration must run **inside this package** — `flutter gen-l10n` from the workspace root is rejected because of `generate: true`:

```
melos run gen-l10n          # scoped to kh_l10n; or cd here and run flutter gen-l10n
```

The generated `app_localizations*.dart` files are committed.

Every new user-facing string lands in **both** ARB files. The workspace-root analyzer plugin fails the build on hard-coded strings in widgets, so a missing translation surfaces as a lint error rather than English leaking into the Arabic build.

`kh_admin` has its own `lib/l10n/` and does not use this package.

## Arabic is more than translation

`localizeDigits` / `forceArabicIndicDigits` convert Western digits to Arabic-Indic for `ar` locales. Numbers rendered through `intl` or string interpolation still need this pass — formatters here already apply it.

`RelativeTimeLabels` and `ExpiryLabels` are label bundles injected into `RelativeTimeFormatter` / `ExpiryCountdownFormatter`, so those formatters stay usable from pure-Dart tests via the `.english` constants while production builds them with `.fromAppLocalizations(l10n)`. Adding a label means extending the bundle, the ARB files, and the `.english` default.

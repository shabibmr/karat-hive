# kh_domain

Entities, value objects and enums. **Pure Dart** — no `flutter` dependency, no HTTP, no widgets. Tests run under `package:test`, not `flutter_test`.

Every type is `freezed` + `json_serializable`. After editing a model, regenerate:

```
melos run gen        # from the repo root; or: dart run build_runner build
```

Commit the `.freezed.dart` / `.g.dart` output — it is checked in.

## Masking is a type, not a flag

`party.dart` models `MaskedParty` and `RevealedParty` as **distinct types**. Pre-acceptance UI cannot read identity because the fields are absent from the shape, not because they are null. Keep that split intact: adding an optional `phone` to the masked variant defeats the whole mechanism.

## Wire enums

Enums parse defensively from the backend's SCREAMING_CASE strings with an `unknown`/fallback member, and expose `wireName` for serialising back. A new backend enum value must not crash an older client — follow the existing `parse` pattern.

Add a new model to the `lib/kh_domain.dart` barrel.

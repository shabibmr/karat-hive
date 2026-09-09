# Admin Flutter Portal — Inspection (index)

| | |
|---|---|
| **Product** | Karat Hive |
| **Surface** | Flutter Web Admin Portal (`apps/kh_admin`) |
| **HEAD** | `88802985d39a4679724875d900275fa038d3bb89` (`main` = `origin/main`) |
| **Date** | 8 September 2026 |
| **Status** | Snapshot. **Not the plan of record.** |
| **Finding prefix** | `ADM-INS-nn` — register is [`REGISTER.md`](REGISTER.md). Stable, never reused. |

Axes stay in **separate files**. A screen can pass one axis and fail another; do not collapse them into one score.

| File | Axis | ID range |
|---|---|---|
| [`REGISTER.md`](REGISTER.md) | Master finding register | `ADM-INS-01`–`87` (gaps reserved) |
| [`standards.md`](standards.md) | Documented AD-FE / architecture + smells | `01`–`23` |
| [`spec.md`](spec.md) | SRS `FR-ADM-*`, Architecture-Frontend §16, Screen-API-Map | `30`–`48` |
| [`structure.md`](structure.md) | Module layout, layering, duplication | `50`–`53` |
| [`quality.md`](quality.md) | Analyzer, errors, a11y remainder | `60`–`63` |
| [`efficiency.md`](efficiency.md) | Rebuilds, tables, bundle remainder | `70`–`73` |
| [`tests-operability.md`](tests-operability.md) | Tests, flavours, CI, runtime plumbing | `80`–`87` |

Flutter/Dart engineering review (checklist mapping, enhancement list, does not mint IDs): [`docs/Admin-Flutter-Dart-Code-Review.md`](../../../../docs/Admin-Flutter-Dart-Code-Review.md) (9 September 2026).

**Out of this slice:** ADM-S20 gold-rate (deferred).

**Spec sources:** `docs/Architecture-Frontend.md`, `docs/Admin-App-Completion-Plan.md`, `docs/Requirements-Spec-v1.3.md`, `docs/Screen-API-Map.md`, `docs/adr/0010-google-signin-only-login.md`.

**Standards sources:** AD-FE-03…14, `analysis_options.yaml`, CONTEXT.md `_Avoid_` lists, Fowler *Refactoring* ch.3 smell baseline.

# Implementation Plan: Missing KhStrings labels

Source: My Requests card shows `cus.card.estimatedValue` and `cus.card.viewDetails`. Inventory of `KhStrings.s` call sites against `packages/kh_l10n/lib/src/strings.dart` (24 Nov 2026).

## Overview

`KhStrings.s` returns the key when the table has no entry (`_bundle[key] ?? key`). Two different holes share that mechanism.

The raw-key leak is small. Six keys used with a bare `s.s(...)` are absent from both the English and Arabic maps, and all six are rendered by `OwnerRequestCard`: the value caption, the View Details button, and the four item-condition words in the meta line.

The larger hole does not print keys. `createCopy` treats a missing key as “use the English fallback”. 88 `create.*` keys are missing, so the Customer create flow is English in both locales. Arabic never reaches those labels.

EN and AR maps already share the same key set (276 keys). Dynamic lookups for Request type, Request state, cancel reasons, decline reasons, and home editorial slides resolve, except `cus.requestType.UNKNOWN` and `cus.state.UNKNOWN`, which only appear for an unrecognised wire value.

Copy stays in the in-memory table in `strings.dart`. The file says not to start ARB there. Do not move this fix into `app_en.arb`.

## Architecture decisions

- Add every missing key to both locale maps in the same edit. A key in only one locale fails the existing parity test.
- Card caption is **Indicative Value**, not the mock’s “Estimated Value”. `UI-Design-Context.md` §12 and `CONTEXT.md` Indicative Value require that. Update `owner_request_card_test.dart` to expect `Indicative Value`.
- View Details stays **View Details** (`apps/kh_mobile/designs/Implementation-Plan.md`, lock on the summary card).
- Condition words match the create-flow fallbacks already in `create_fields.dart`: New, Like new, Used, Damaged.
- Leave `KhStrings.s` returning the key on a miss. `createCopy` depends on that identity check until phase 2 lands the keys. A debug assert would break the create flow today.
- The recurrence guard scans `lib/**/*.dart` for string literals passed to `.s(`. It does not scan `createCopy` until those keys are in the table.

## Copy to add (phase 1)

| Key | English | Arabic (proposed) |
|---|---|---|
| `cus.card.estimatedValue` | Indicative Value | القيمة الإرشادية |
| `cus.card.viewDetails` | View Details | عرض التفاصيل |
| `create.condition.new` | New | جديدة |
| `create.condition.likeNew` | Like new | شبه جديدة |
| `create.condition.used` | Used | مستعملة |
| `create.condition.damaged` | Damaged | متضررة |
| `cus.requestType.UNKNOWN` | Request | طلب |
| `cus.state.UNKNOWN` | Unknown | غير معروف |

Arabic strings are proposals. Confirm them before they ship.

## Task list

GitHub issues are the tracker (`docs/agents/issue-tracker.md`). Open one issue per task after this plan is approved. Do not file them before that.

### Phase 1: Stop the raw keys

- [x] Task 1: Add the eight keys above to both maps in `packages/kh_l10n/lib/src/strings.dart`, and extend `packages/kh_l10n/test/kh_strings_test.dart` so each key resolves in EN and AR and the two locales differ.
- [x] Task 2: Point `owner_request_card_test.dart` at `Indicative Value` and `View Details`, and assert the brand-new condition renders `New` (the fixture is `ItemCondition.brandNew`).
- [x] Task 3: Add `apps/kh_mobile/karat_hive/test/l10n/string_key_coverage_test.dart`. Walk `lib/**/*.dart`, collect every `.s('literal')` and the expanded dynamic keys (`cus.home.editorial.{1,2,3}.{a,b,c}`, `cus.requestType.*`, `cus.state.*`, `cus.cancel.*`, `cus.decline.*` from the domain wire values). Fail when EN or AR returns the key.

### Checkpoint: Phase 1

- [x] `kh_strings_test.dart` passes (6 tests).
- [x] `owner_request_card_test.dart` and the new coverage test pass (3 tests).
- [x] Widget test shows Indicative Value, View Details, and `· New` on the coin fixture. Arabic lines are the approved proposals. Device pass not run in this session.

### Phase 2: Arabic on the create flow

Each task copies the existing English fallback into the EN map and adds an Arabic line. After the keys exist, `createCopy` returns the table value and the English fallback stays only as a safety net. One screen group per task.

- [ ] Task 4: Request-type screen (`create.typeTitle`, `create.type.*`, `create.capBlocked`, `create.loadFailed`).
- [ ] Task 5: Compose fields (`create_fields.dart`, `find_ornament_screen.dart`, `find_specs_section.dart`): purity, weight, budget, notes, ornament types, direction, gemstones, mint/refiner.
- [ ] Task 6: Photos (`request_images_section.dart`, `request_image_capture_screen.dart`, `find_compose_photo_mosaic.dart`).
- [ ] Task 7: Review and publish (`request_review_publish_screen.dart`) plus shared chrome (`create.continue`, `create.saveDraft` in `create_flow_chrome.dart`).
- [ ] Task 8: Extend the coverage test to every `createCopy(context, 'key', ...)` literal. Delete nothing from the fallback argument; it remains the miss path.

### Checkpoint: Phase 2

- [ ] Coverage test fails if a new `create.*` call site has no table entry.
- [ ] Create flow in Arabic shows Arabic for type, compose, photos, and review. English is unchanged from today’s fallbacks.
- [ ] `dart analyze` on `packages/kh_l10n` and `apps/kh_mobile/karat_hive`.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Arabic proposals are unreviewed | Medium | Phase 1 table is eight strings. Hold the edit if the wording is wrong. |
| Indicative Value disagrees with Card-mock.png | Low | Terminology lock in UI-Design-Context §12 overrides the mock word. The widget test is the check. |
| Coverage regex misses a multiline `s.s(` | Medium | Task 3 includes the multiline form already used in `my_requests_screen.dart`. |
| Phase 2 translation drift from the English fallback | Medium | EN value is copied from the fallback string in the same task. Do not rewrite English. |

## Open questions

- Approve the eight Arabic lines, or supply replacements, before Task 1.
- Phase 2 can wait. Phase 1 is enough to fix the My Requests card.

## Out of scope

- Migrating `KhStrings` to ARB / `gen-l10n`.
- Vendor screens. Those use `AppLocalizations`, which fails the build when a getter is missing.
- Rewriting create-flow English copy.

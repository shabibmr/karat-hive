# Mobile visual pass — Review of T01–H02

| | |
|---|---|
| **Document** | Review of implemented tasks T01–H02 |
| **Plan** | [`Implementation-Plan.md`](Implementation-Plan.md) |
| **Register** | [`Tasks-Register.md`](Tasks-Register.md) |
| **Date** | 30 September 2026 |

## Verdict

Structurally T01–H02 follow the plan. Token values are correct (`gold` `#D8A858`, `ctaFill` `#D8C0A8`, `formSurface` `#F0E8E0`), both pressed colours use the −16/−16/−12 darken, buttons are 48 px with radius 10 and a flat fill, the nav has no stadium, and Home has the photo hero and 2×2 photo tiles.

It is not yet in a "done" state: the design-system tests fail and there are a few real defects.

## Test and analyze results

| Check | Result |
|---|---|
| `dart analyze` on `kh_design_system`, `kh_l10n`, `karat_hive` | 0 errors, 0 warnings (info-level lints only, in existing code) |
| `flutter test` customer home + guest landing | 26/26 pass, including no-overflow at 320, 390, 1024 px in en and ar |
| `flutter test` in `kh_design_system` | **9 golden tests fail** (KhButton, BottomNav, AppShell, ConfirmDialog, SegmentedTabs, StatusChip tones, DateRangePicker, +2) |

The golden failures are pixel diffs from the token change, not crashes. The register leaves test updates to V01, but T01–T03 are marked done while their own package is red. SegmentedTabs and StatusChip also changed, so the gold move reached widgets outside the task list. Inspect the images before regenerating goldens.

## Findings

1. **Selected nav label is below accessible contrast.** Gold `#D8A858` on nav background `#F6F1E6` is about 1.9:1, failing WCAG for text (4.5:1) and icons (3:1). `tokens.dart:28` already says gold is "Never text on ivory". The code follows plan lock #6, so this is a plan problem needing a decision. Simplest fix: gold icon with a bold ink label, or `goldDark` for the label.
2. **English and Arabic type names diverge.** `strings.dart:102-103` now says "Gold Coin(s)" / "Gold Bullion"; Arabic at `:372-373` still says "Buy / Sell …". The comment at `:99` claims these are `CONTEXT.md` names, but `CONTEXT.md` says "Buy/Sell Gold Coin(s)". Either shorten the Arabic too and fix the comment, or restore "Buy/Sell" in English.
3. **Hero next-button fails accessibility.** `_HeroNextButton` (`kh_hero_carousel.dart`) is 40×40 (minimum 48) and has no semantic label. Needs a `kh_l10n` label and a 48 px tap area.
4. **No tests for the redesigned tile and hero.** `KhServiceCard` and `KhHeroCarousel` have no golden or widget test in `kh_design_system`; only app-level tests (text, overflow). Add LTR + RTL goldens under V01.
5. **Leftovers in `KhServiceCard`:**
   - `icon` and `expand` parameters are now no-ops kept "for compatibility"; remove them and update the two call sites.
   - `KhServiceGrid` doc still tells callers to pass `expand: true`.
   - Fixed 168 px height ignores text scale; a three-line title at large text rises above the scrim (starts at 45%) onto bare photo.
   - Scrim uses raw `Color(0x..000000)`; the hero uses `t.ink`.
6. **Token issues (`tokens.dart`):**
   - `ctaFillPressed` is a hard-coded hex getter, not derived from `ctaFill`, so it won't follow a `copyWith` override.
   - `goldPressed` and `goldNavPill` are now unused.
7. **Old gold `#C8A046` still hard-coded:**
   - `create_fields.dart:108` and `:685` (Buy fill) — C01 should pick these up.
   - `kh_ui_domain/.../expiry_countdown.dart:194` — no task covers it; add one.
8. **Hero image has no fallback.** No `errorBuilder` (the tile has one), so a missing asset shows a broken image. At ≥1024 px the hero is still 208 px high with the photo cropped heavily; check in V02.

## Scope and housekeeping

- Guest Landing also changed (shared tile widget). Correct, but add `guest_landing_screen.dart` to H02's file list in the register.
- Two copies of `design-System.md`: repo-root `designs/design-System.md` (tracked, uncommitted ~2,400-line rewrite) and `apps/kh_mobile/designs/design-System.md` (untracked folder, linked from the plan). They can drift.
- `KhBottomNav` drops the badge on the selected icon. Pre-existing, not part of this work.

## Recommended before H03

1. Fix findings 2 and 3.
2. Clean up finding 5.
3. Inspect and regenerate the 9 goldens so `kh_design_system` passes.
4. Decide finding 1 (plan change).

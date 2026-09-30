# Mobile visual pass — still to do

| | |
|---|---|
| **Date** | 30 September 2026 |
| **From** | Code review of `2510cc3...HEAD` (`db5c8b9`, `f03bd60`) and the rewrite of `apps/kh_mobile/karat_hive/docs/UI-Design-Context.md` |
| **Related** | [`Implementation-Plan.md`](Implementation-Plan.md) · [`Tasks-Register.md`](Tasks-Register.md) · [`Implementation-Plan-Pass-2.md`](Implementation-Plan-Pass-2.md) · [`Tasks-Register-Pass-2.md`](Tasks-Register-Pass-2.md) · [`UI-Design-Context.md`](../karat_hive/docs/UI-Design-Context.md) §14 |

Path shorthand: `app/` = `apps/kh_mobile/karat_hive/lib/features/`, `ds/` = `packages/kh_design_system/lib/src/`.

Status values: **open** · **pass 2** (owned by a task in `Tasks-Register-Pass-2.md`) · **done** · **blocked** (waits on a decision; don't resolve by inference).

---

## 1. Correctness — fix first

Domain or copy is wrong on screen today.

| # | Status | Task | Where | Source |
|---|---|---|---|---|
| 1.1 | open | The summary card labels a Customer budget "Estimated Value". Rename it to **Indicative Value**, and hide the panel when no Indicative Value exists rather than showing the budget | `app/request_manage/presentation/widgets/owner_request_card.dart:124,279-287`; `kh_l10n` `cus.card.estimatedValue` | `CONTEXT.md` Indicative Value; review K01 |
| 1.2 | open | The Indicative Value falls back to 24K when no purity is picked, so it overstates. Show no figure until a karat is chosen | `app/request_create/controller/request_create_controller.dart:1056` | SRS FR-CUS-020 "stated purity"; review C03 |
| 1.3 | open | The ornament type shows as title-cased `wire` text, so Arabic users see English. Use `kh_l10n` labels | `owner_request_card.dart:248` | NFR-022; UI-Design-Context §9 |
| 1.4 | open | The media-count badge uses `Positioned(right: -4)`. Use `PositionedDirectional(end: …)` so it mirrors in RTL | `owner_request_card.dart:195` | UI-Design-Context §9 |
| 1.5 | open | The review budget row always reads "Up to AED {max}". Show the min–max range when the Customer entered one | `app/request_create/presentation/request_review_publish_screen.dart:355-360` | Review C02 |
| 1.6 | open | The Find review screen has no **Save draft** (`if (!isFind)`). Add it as the secondary action | `request_review_publish_screen.dart:279` | Tasks-Register C01 |
| 1.7 | open | The brand wordmark is `gold` on ivory (2.1:1). Change it to `goldDark` or `ink` | `ds/widgets/kh_brand_mark.dart:37` | UI-Design-Context §2.5, G-05 |
| 1.8 | open | Request-type tiles say "Gold Coin(s)" / "Gold Bullion". Use the Request Type names, or get a Product Owner decision on short tile labels | `kh_l10n` `service.card.coins`, `service.card.bullion` | `CONTEXT.md` Request Type; G-06 |
| 1.9 | open | The Sell Old Gold screen title uses the `service.card.sellGold` key. Switch to `create.type.sellGold` | `app/request_create/presentation/find_ornament_screen.dart` | Review C03 |
| 1.10 | open | Eyebrows in `goldDark` on `formSurface` are 4.2:1, which fails AA. Use `inkSecondary` on create and review screens | `app/request_create/presentation/widgets/create_flow_chrome.dart` | UI-Design-Context §2.5, §6.15 |

## 2. Unplanned behaviour changes — confirm or revert

These changed outside the plan's file list. Decide whether to keep each one, then record it in the plan or revert it.

| # | Status | Change | Where |
|---|---|---|---|
| 2.1 | open | The **View offers** shortcut and the whole-card tap were removed from My Requests | `app/request_manage/presentation/my_requests_screen.dart:177-181` |
| 2.2 | open | The Buy/Sell direction label was dropped from the summary card | `owner_request_card.dart` |
| 2.3 | open | The expiry warning colour changed | `packages/kh_ui_domain/lib/src/expiry_countdown.dart:194` |
| 2.4 | open | Guest Landing got the brand mark and photo tiles (plan §4.2 scopes Home only) | `app/guest/presentation/guest_landing_screen.dart:45-68,193-197` |
| 2.5 | open | `KhNetworkImage` switched to `cached_network_image`, adding two dependencies. No task covers it | `ds/widgets/kh_network_image.dart:64-74`; `packages/kh_design_system/pubspec.yaml` |
| 2.6 | blocked | Live gold rates are now fetched to show an Indicative Value to end users. Waits on O-04 (Yahoo Finance terms) | `request_create_controller.dart:308` |

## 3. Verification — V02 is not actually complete

| # | Status | Task | Source |
|---|---|---|---|
| 3.1 | open | Run the **wide** (~1024) check for Find review, Sell Old Gold, Coins/Bullion, the summary card and the Vendor shell. Every one is "—" in the notes | `Verification-Notes-V01-V02.md`; Tasks-Register V02 |
| 3.2 | open | `RequestReviewMosaic` is fixed at 2 columns, so photos balloon at wide widths. Adapt the column count | UI-Design-Context §6.9, §10 |
| 3.3 | open | Reopen V02 in `Tasks-Register.md` until 3.1 is done | — |
| 3.4 | open | Add goldens for the new and changed widgets at 320 / 390 / 1024, LTR and RTL | UI-Design-Context §13 |

## 4. Design-system alignment (UI-Design-Context §14.1)

G-01…G-04 are now owned by pass 2 (`Tasks-Register-Pass-2.md` G01–G04). Track them there.

| # | Status | Gap | Where |
|---|---|---|---|
| 4.1 | pass 2 (G01) | **G-01:** move the status colours to the muted set (`#557A62` / `#A5793E` / `#9B514A`) | `ds/tokens.dart`, `ds/widgets/kh_status_chip.dart` |
| 4.2 | pass 2 (G02) | **G-02:** move the type scale to the target in §3.2. Form input 14 → 16, labels 10.5 → 12–13, errors 11 → 12; lighter weights | `ds/theme.dart`, `ds/typography.dart` |
| 4.3 | pass 2 (G03) | **G-03:** add spacing tokens for 40 / 48 / 64 / 80 | `ds/tokens.dart` `KhSpace` |
| 4.4 | pass 2 (G04) | **G-04:** field radius 12 → 10; bottom-sheet top radius 16 → 20 | `ds/tokens.dart`, `ds/theme.dart` |
| 4.5 | open | Restyle the status chip, state views and confirmation dialog to §6.20–§6.22 (skeletons over spinners, calm errors) | `kh_status_chip.dart`, `state_views.dart`, `kh_confirm_dialog.dart` |
| 4.6 | open | `ctaFillPressed` blends 10% toward ink, which isn't "the existing relative darken" (T02). Accept it and update the plan, or match the old 1a ratio | `ds/tokens.dart:40` |

## 5. Code quality

| # | Status | Task | Where |
|---|---|---|---|
| 5.1 | open | Reuse `kh_ui_domain`'s `indicative_valuation.dart` and `purity_picker.dart` instead of the app-local copies | `create_fields.dart:954` `SellIndicativeValuePanel`; `find_ornament_screen.dart:346` `_SellPurityChip` |
| 5.2 | open | Remove duplication: `_SellPurityChip` is a copy of `_CtaFillChip`, `_IconReviewRow` repeats `SellIconFieldRow`, and the tile asset paths appear on both Home and Guest | `find_ornament_screen.dart:346`, `create_fields.dart:831,909`, `request_review_publish_screen.dart:504`, `customer_home_screen.dart:57`, `guest_landing_screen.dart:45` |
| 5.3 | open | Share one label map for each repeated switch: the `OrnamentType` label and the `ItemCondition` label | `request_review_publish_screen.dart:571`, `create_fields.dart:402,784`, `owner_request_card.dart:290` |
| 5.4 | open | Consider a separate Find review widget instead of `isFind` ternaries throughout the review screen | `request_review_publish_screen.dart:225` onward |
| 5.5 | open | Name or source the magic values: the ±4% valuation band, the `['24','22','21','18']` fallback karat list, and the `stepLabel: ''` sentinel | `create_fields.dart:970`, `find_ornament_screen.dart:230`, `request_review_publish_screen.dart:237` |
| 5.6 | open | Replace hard-coded values with tokens: `72.0`, `circular(999)`, `TextStyle(fontSize: 11)`, `_inkFill = Color(0xFF1C1B1A)` | `owner_request_card.dart:171,202,208`, `create_fields.dart:110` |
| 5.7 | open | Drop the test-only static mutable `KhNetworkImage.defaultCacheManager`, or inject it | `ds/widgets/kh_network_image.dart:14` |
| 5.8 | open | Move the compose widgets (choice chip, segmented control, check row, stepper, read-out tile, action bar, dashed tile) from `create_fields.dart` into `kh_design_system` | UI-Design-Context §13 |

## 6. Repository hygiene

| # | Status | Task |
|---|---|---|
| 6.1 | open | Keep **one** copy of the design references. `designs/` and `apps/kh_mobile/designs/` hold byte-identical `design-System.md` and 1–2 MB PNGs. The new UI-Design-Context cites `designs/design-System.md`; `Implementation-Plan.md` cites the `apps/kh_mobile/designs/` copy. Fix whichever reference loses |
| 6.2 | open | Delete the retired sources `Home-2.png` and `find-button-rounded.png` from `designs/` and `ui-mock/`. Both copies are now tracked (`119e318`) (N01) |
| 6.3 | open | Remove unused bundled JPGs (`diamond_jewelry_card`, `gold_bullion_card`, `vendor_badge_card`, ~2 MB). `pubspec.yaml:52` ships all of `assets/images/` |
| 6.4 | open | Triage the reference files committed in `119e318` to `apps/kh_mobile/designs/` and `designs/`: the ChatGPT images, `inspire 1.webp` (identical to `hero_jewellery.webp`), `5ca7a…webp`, `source.txt` and `component_src.txt` |
| 6.5 | open | Clean the escaped markdown in `design-System.md` (`\#`, `\*\*`, `&#x20;`) so it renders |
| 6.6 | done | Commit the UI-Design-Context rewrite (`1b018f8`) |

## 7. Docs follow-up

| # | Status | Task |
|---|---|---|
| 7.1 | open | `Implementation-Plan.md` and `Tasks-Register.md` still say "this pass does not rewrite `UI-Design-Context.md`". Note that the rewrite has happened (30 Sep 2026) |
| 7.2 | open | O-03 is decided (`99e19e4` dropped the activity strip). Update the `CLAUDE.md` "Working product notes" line ("hero + service grid + activity summary") and UI-Design-Context §6.12 and §14.2 O-03 to match |
| 7.3 | open | Re-base `ui-mock/` and `ui-screens/` on the new UI-Design-Context (O-09) |

## 8. Open decisions (UI-Design-Context §14.2)

| # | Status | Decision | Blocks |
|---|---|---|---|
| O-01 | blocked | Screen gutter: 16 (shipped) or 20 (the written system's preference) | UI-Design-Context §4.2 |
| O-02 | blocked | Clover brand-mark asset from `Home-1.png` | App header (the wordmark stands in) |
| O-03 | done | Activity summary on Home: dropped to match `Home-1.png` (`99e19e4`). Docs follow-up is 7.2 | — |
| O-04 | blocked | Yahoo Finance redistribution terms | Showing a rate-derived Indicative Value (2.6) |
| O-05 | blocked | **Anklet** chip — not in `OrnamentType` | Ornament-type chip row |
| O-06 | blocked | Bullion purity: Karat or Fineness | Bullion purity picker |
| O-07 | blocked | Validation and error states for the four compose screens, including the bullion minimum (`BR-010`) | Compose error styling |
| O-08 | blocked | Real photography for hero slides | Release build |
| O-09 | blocked | Re-basing `ui-mock/` off the archived dark palette | Prototype parity (7.3) |

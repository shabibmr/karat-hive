# Implementation Plan: Redesign 4 Create Request Screens (1a Direction)

The 4 Create Request screens (**Find an Ornament**, **Sell Old Gold**, **Buy / Sell Gold Coin**, **Buy / Sell Gold Bullion**) in `apps/kh_mobile/karat_hive` are being updated to high-fidelity specs from `docs/design_handoff_karat_hive`.

---

## Architectural & UX Overview

### Core Objectives
1. **Single Viewport Density**: Transition form screens from multi-card scrolling lists to dense, single-viewport layouts with 48px fixed height rows, 1px hairline section dividers, and tight 2-up grid pairing.
2. **Standardized Header Chrome & Action Bar**:
   - Top Header: 36px circular back button (`arrow_back`), 21px serif screen title (Cormorant Garamond), and 10px gold uppercase eyebrow text (`SPECIFY THE PIECE · BUY / SELL`).
   - Bottom Action Bar: Fixed 1px hairline top rule, 48px full-width pill buttons — "Save draft" (1fr outlined) and "Continue" (1.8fr filled gold `#C8A046`).
3. **Bilingual (EN / AR) Alignment**: Complete coverage of English and Arabic strings in `packages/kh_l10n` with RTL layout mirroring.

---

## File Change Matrix

| File / Component | Action | Description |
| :--- | :--- | :--- |
| `packages/kh_l10n/lib/src/strings.dart` | `[MODIFY]` | Add missing EN and AR copy strings for all 4 Create Request screens (eyebrows, photo notes, coin denominations, assay certificates). |
| `lib/features/request_create/presentation/widgets/create_flow_chrome.dart` | `[MODIFY]` | Update `CreateFlowChrome` and `DraftActions` to match the 1a design specs (36px back button, gold eyebrow, 48px action bar pills). |
| `lib/features/request_create/presentation/widgets/create_fields.dart` | `[MODIFY]` | Redesign field widgets: `OrnamentTypeChips`, `WeightPurityFields`, `DirectionControl` (46px pill switch), `BudgetEditor` (segmented max/range toggle), and condition/assay inputs. |
| `lib/features/request_create/presentation/widgets/request_images_section.dart` | `[MODIFY]` | Redesign photo picker row: 64×64px rounded thumbnails, "X / 5" count badge, dashed add tile, and mandatory actual-item note for Sell Gold. |
| `lib/features/request_create/presentation/find_ornament_screen.dart` | `[MODIFY]` | Update `FindOrnamentScreen`, `SellOldGoldScreen`, `GoldCoinsScreen`, and `GoldBullionScreen` layout, chrome props, and conditional field rendering. |
| `test/features/request_create/presentation/` | `[MODIFY]` | Update widget tests to verify new chip selectors, segmented controls, and draft actions. |

---

## Detailed Task Breakdown

### Task 1: Update Localization Bundle (`kh_l10n`)
- Expand `packages/kh_l10n/lib/src/strings.dart` with keys for:
  - Header eyebrows: `create.eyebrow.buy` ("SPECIFY THE PIECE · BUY"), `create.eyebrow.sell` ("SPECIFY THE PIECE · SELL").
  - Photo guidance: `create.actualItemPhotos` ("Photos must be of the actual item — stock or catalogue images are not accepted.").
  - Form field labels & placeholders: `create.budgetMaxOnly` ("Maximum only"), `create.budgetRange` ("Min–max range"), `create.packagingSealed` ("Sealed packaging"), `create.assay` ("Serial / assay certificate present").

### Task 2: Redesign Chrome & Shared Form Field Components
- **`create_flow_chrome.dart`**:
  - Replace default Scaffold app bar with custom 60px header:
    - 36px circular icon button with thin border (`arrow_back`).
    - Title block: 21px serif title + 10px uppercase gold eyebrow (`#C8A046`).
  - Refine `DraftActions` widget:
    - 1px top border rule.
    - Side-by-side row: `KhButton` "Save draft" (secondary outline, 1fr) and "Continue" (primary filled gold `#C8A046`, 1.8fr).
- **`create_fields.dart`**:
  - **`OrnamentTypeChips`**: Horizontal scrolling / wrap row of 9 ornament type chips (Ring, Necklace, Bracelet, Bangle, Earrings, Pendant, Chain, Anklet, Other). Active state = `#1C1B1A` ink pill; inactive state = outlined pill.
  - **`WeightPurityFields`**: 2-up grid row pairing Weight (grams input, 48px) with 4-up Purity chip row (24K, 22K, 21K, 18K).
  - **`DirectionControl`**: Segmented pill control (46px height) with animated Buy (`#C8A046`) and Sell (`#1C1B1A`) state transitions.
  - **`BudgetEditor`**: Segmented control switching between "Maximum only" (1-up Max field) and "Min–max range" (2-up Min + Max fields).
- **`request_images_section.dart`**:
  - Compact horizontal photo strip (64×64px rounded thumbnails with delete overlays and "X / 5" photo counter) + dashed add tile button.

### Task 3: Redesign the 4 Request Screens
1. **Find an Ornament Screen (`FindOrnamentScreen`)**:
   - Photos row + Ornament type chips + 2-up Weight & Purity + "Weight is approximate" checkbox + "Includes gemstones" toggle (conditionally showing Gemstone type & count) + Budget mode segmented control & fields + Notes input.
2. **Sell Old Gold Screen (`SellOldGoldScreen`)**:
   - Photos row with "Actual item only" warning + Ornament type chips + 2-up Weight & Purity + Condition picker + "Original invoice/certificate" toggle + Notes input (no budget section).
3. **Gold Coins Screen (`GoldCoinsScreen`)**:
   - Buy/Sell `DirectionControl` at top + 7-up Denomination chips (1, 2.5, 5, 10, 20, 50, 100 g) + Quantity stepper (– / +) with live total weight badge + 2-up Weight & Purity + Mint field & "Sealed" toggle + Budget section (mounted only on Buy) + Notes.
4. **Gold Bullion Screen (`GoldBullionScreen`)**:
   - Buy/Sell `DirectionControl` at top + 2-up Bar weight & Quantity fields + Weight & Purity ("24K · 999.9") + Refiner field & "Assay certificate" toggle + Budget section (mounted only on Buy) + Notes.

---

## Verification Plan

### Automated Verification
Run Flutter unit and widget tests:
```powershell
flutter test test/features/request_create
```

### Manual Visual & Interaction Checklist
1. **Find an Ornament**: Verify single viewport fit, photo strip, chip selection, gemstone toggle, budget range mode toggle, save draft / continue actions.
2. **Sell Old Gold**: Verify actual-item notice, condition picker, invoice toggle, absence of budget section.
3. **Gold Coins**: Toggle Buy/Sell, select denomination, use quantity stepper to observe live total weight recalculation, verify budget appears only on Buy.
4. **Gold Bullion**: Toggle Buy/Sell, verify bar weight & quantity inputs, assay switch, conditional budget.
5. **RTL / Localization**: Switch app locale to Arabic (`ar`) and verify text alignment, back button flipping, and correct translated copy across all 4 screens.

---
✅ **Plan ready.** Run `/run-implementation-plan-review-1` to have Gemini critique this plan as Principal Architect, then `/run-implementation-plan-review-2` for Claude's final pragmatism pass before execution begins.

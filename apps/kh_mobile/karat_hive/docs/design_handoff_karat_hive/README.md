
# Handoff: Karat Hive — Home, Guest Landing & Create Request (1a direction)

## Overview
Redesign of the Customer Home, Guest Landing, and the four Create Request screens (Find an Ornament, Sell my Ornament, Buy/Sell Gold Coin, Buy/Sell Gold Bullion) for the Karat Hive gold-trading app. Direction "1a — Classic" was chosen after testing three options. Existing bottom-nav, screen list, and field set from the Flutter app are preserved; this is a visual/layout redesign, not a new IA.

## About the Design Files
The bundled `.dc.html` files are **HTML design references** — interactive prototypes showing intended look, layout, and behavior (taps, toggles, carousel, chip selection). They are not production code. The task is to **recreate this design in the existing Flutter codebase** (`shabibmr/karat-hive`, path `apps/kh_mobile/karat_hive`), using its existing widgets, `kh_design_system` package (tokens, theme, `kh_bottom_nav`, `kh_section_header`, `kh_badge`), and `kh_l10n` copy strings — not by embedding HTML/web views.

## Fidelity
**High-fidelity.** Colors, typography, spacing, and component states below are final. Build pixel-accurate to these specs using Flutter widgets/theme tokens equivalent to the raw values listed.

## Source repo
- Repo: `shabibmr/karat-hive`, branch `main`, path `apps/kh_mobile/karat_hive`
- Screens being replaced:
  - `lib/features/request_manage/presentation/customer_home_screen.dart` (CUS-S02)
  - `lib/features/guest/presentation/guest_landing_screen.dart` + `lib/features/auth/presentation/widgets/how_this_works.dart` (CUS-S23)
  - `lib/features/request_create/presentation/find_ornament_screen.dart`, `widgets/create_fields.dart`, `widgets/create_flow_chrome.dart` (CUS-S04–S07)
- Shared tokens/widgets: `packages/kh_design_system/lib/src/tokens.dart`, `theme.dart`, `widgets/kh_bottom_nav.dart`, `kh_section_header.dart`, `kh_badge.dart`
- Copy source: `packages/kh_l10n/lib/src/strings.dart` (EN/AR) — new copy below should be merged in here, not hardcoded.

## Design Tokens
- Colors: gold `#C8A046` (primary accent, CTAs, icons), gold-dark `#8A6A1F` (links, small labels), ink `#1C1B1A` (text, dark surfaces, active nav pill), ivory `#FDFBF7` (screen background, cards), warm-grey background `#F6F1E6` (bottom nav bar), error red `#B3261E` (notification badge). Pink is reserved for the logo only — never used elsewhere.
- Typography: headlines in **Cormorant Garamond** (serif, weights 500/600/700, italic for accents), body/UI in **DM Sans** (400–700). Arabic mirrors: **Noto Naskh Arabic** for headline positions, **IBM Plex Sans Arabic** for body/UI.
- Radii: 16px cards/tiles, 12px form fields, 24px pill buttons, 999px full pills, 48px device corner (n/a to app).
- Spacing: 16px screen padding, 8–12px gaps between grouped elements, 10px grid gaps.
- Field height: 48px, fixed, for every input/select row.
- Icons: Material Symbols Outlined (map to your existing icon set/equivalents), 17–26px depending on context.

## Screens / Views

### 1. Customer Home (signed-in)
**Purpose:** Landing tab for a logged-in customer — browse services, resume activity, see how requests work.

**Layout (top to bottom, single scroll):**
- Status bar (native, not in scope).
- Header row, 60px: logo (44px tall) left, notification bell icon right (26px) with red circular badge (16px, count "3").
- **Hero carousel**: rounded-16px card, ink `#1C1B1A` background, 4 auto-advancing slides (4.2s interval, 600ms ease transition), each slide split 1.15fr/1fr — left: 2-3 line serif headline (line 1 gold `#C8A046` 23px, lines 2–3 ivory 20px) + a 28×1.5px gold underline rule; right: photo placeholder tile. Dot controls bottom-left: active dot 18×6px gold pill, inactive 6×6px translucent dot, tappable to jump slides.
- **"What would you like to do?"** section header (24px serif), then a 2×2 grid of service cards (10px gap): each card = photo placeholder top (86px, rounded top corners) with a small icon badge (32px circle, gold icon) overlapping top-left, title below (two-line serif, e.g. "Find an / Ornament"), and a small gold circular arrow button (28px) bottom-right. Cards: Find an Ornament, Sell my Ornament, Buy/Sell Gold Coin, Buy/Sell Gold Bullion.
- **"My activity"** row header with "View all" link (gold, chevron icon) right-aligned.
- **Stats strip**: 3-column bordered row (rounded 16px), each cell = small icon in a soft-gold circle, large serif number (28px), label below (12px grey). Cells separated by thin left-border rule. Values: Open (icon: description), Offers waiting (icon: local_offer), Connections (icon: handshake).
- **"How this works"** panel: soft gold-tint background (9% opacity), rounded 16px, title + 4-column icon-step grid (icon circle 44px + 2-line label "1. Post a request" etc.) — no descriptions, title + number + short label only.
- Bottom nav, 80px, 5 tabs (Home, My Requests, Connections, Alerts, Profile): active tab = gold-tinted pill (64×32px) behind a filled icon + bold label; inactive = plain icon + regular label at 70% ink opacity.

### 2. Guest Landing (logged-out)
**Purpose:** Convert a visitor into signing up / browsing services.

**Layout:**
- Header 60px: logo left, "Log in" text button (gold) right.
- Serif headline "Request gold your way" (30px) + one-line grey subhead below.
- Same 2×2 service card grid as Home (identical component).
- **"How this works" accordion**: bordered card, header row with title + chevron toggle (expand_more/expand_less), tap to expand a list of 8 short guidance lines (numbered gold circle + text, 13px).
- Footer link, centered, underlined: "Are you a jeweller? Register here."
- No bottom nav on this screen (guest has no tabs).

### 3–6. Create Request screens (Find an Ornament / Sell my Ornament / Buy or Sell Gold Coin / Buy or Sell Gold Bullion)
**Purpose:** Single-screen request forms — every field from the current build, but redesigned to fit one viewport with no scrolling.

**Shared chrome:**
- Back button: 36px circle, thin border, arrow_back icon.
- Title block next to it: serif 21px screen title (e.g. "Find an Ornament"), gold 10px uppercase eyebrow under it ("Specify the piece · Buy").
- Field groups separated by 1px hairline rules instead of cards (this is the key density change vs. the current build's card-based grouping).
- All inputs/rows are exactly 48px tall, laid out in a responsive grid — most paired 2-up (e.g. Weight + Purity chips, Min + Max budget).
- Bottom action bar: fixed, 1px top hairline, two buttons side by side — "Save draft" (1fr, outlined, 48px, pill) and "Continue" (1.8fr, filled gold, 48px, pill, hover darkens to `#B8903A`).

**Find an Ornament (1a):**
- Reference photos row: photo counter "2 / 5", horizontal row of 64×64px rounded thumbnails + a dashed add-photo tile.
- Ornament type: horizontally-scrolling chip row (9 chips: Ring, Necklace, Bracelet, Bangle, Earrings, Pendant, Chain, Anklet, Other) — selected chip = filled ink pill, others outlined.
- Weight field (grams) + 4-up purity chip row (24K/22K/21K/18K, selected = filled ink/gold).
- "Weight is approximate" checkbox (18px rounded square, gold check when on) + "Purity optional" note.
- "Includes gemstones" toggle switch (44×26px pill, gold when on) — when on, reveals Gemstone type + Count fields.
- Budget section: segmented control "Maximum only / Min–max range" (pill toggle, selected = white chip with shadow); when range mode, shows Min + Max fields side by side, else Max only spans full width. "Budget is flexible" checkbox. Notes field (single line, ellipsis-truncated placeholder-style text).

**Sell my Ornament (1b):**
- Same chrome. Photo row labeled "Photos of your piece" with a required-actual-item notice line (info icon, gold text: "Actual item only. No stock or catalogue images.").
- Ornament type chips, Weight + Purity chips, "Weight is approximate" checkbox.
- Condition field (tappable, chevron, e.g. "Good").
- "Original invoice or hallmark certificate" toggle switch.
- Notes field.
- No budget section (seller doesn't set budget).

**Buy / Sell Gold Coin (1c):**
- Buy/Sell segmented control at top: two-cell pill, 46px tall, selected cell filled (gold for Buy, ink+gold-text for Sell), unselected cell plain text — tap either side to switch.
- Coin denomination: 7-up chip row (1, 2.5, 5, 10, 20, 50, 100 — labeled "Xg"), selected = filled ink/gold.
- Quantity stepper (– / + circular buttons, 28px) next to a live "Total weight" readout tile (gold-tinted background, computed as denomination × quantity).
- Weight (readonly, mirrors total) + Purity ("24K", chevron) fields.
- Mint/brand optional field + "Sealed" toggle switch (paired, switch has a small label under it instead of beside it).
- Budget section — **only rendered when Buy is selected**: segmented "Maximum only / Min–max range" + Max field + inline "Flexible" checkbox.
- Notes field.

**Buy / Sell Gold Bullion (1d):**
- Same Buy/Sell segmented control.
- Bar weight + Quantity fields (2-up).
- Weight (mirrors bar weight) + Purity ("24K · 999.9", chevron) fields.
- "Weight is approximate" checkbox (no gemstone-style toggle needed here).
- Refiner/brand optional field.
- "Serial / assay certificate present" toggle switch.
- Budget section — only when Buy is selected (Sell shown in the reference has no budget row, confirming the conditional).
- Notes field.

## Interactions & Behavior
- **Carousel**: auto-advances every 4200ms (toggleable via an `autoplay` flag), 600ms cubic-bezier(.2,.7,.2,1) slide transition; dots are tappable to jump directly to a slide; autoplay should pause or persist correctly if the developer adds manual swipe (not in current prototype — swipe gesture should be added in the real app, prototype only supports dot-tap).
- **How this works accordion** (Guest Landing): tap header row toggles expand/collapse; chevron icon flips (expand_more ↔ expand_less).
- **Ornament type / purity / coin denomination chips**: single-select, tap to reassign; selected chip visually filled (ink background), others outlined.
- **Toggle switches** (gemstones, invoice, sealed, assay cert): standard on/off pill switch, 44×26px, knob slides left/right, gold fill when on.
- **Checkboxes** (weight approximate, budget flexible): 18px rounded square, gold fill + check icon when on, outlined when off.
- **Budget mode segmented control**: switching to "Min–max range" reveals a second (Min) field before Max; switching back to "Maximum only" collapses it — implement as a conditional grid column, not a show/hide that shifts other content unpredictably.
- **Buy/Sell segmented control** (Coin, Bullion): tapping the inactive side flips state; budget section conditionally mounts only when Buy is active — must be true conditional rendering (affects vertical space), not opacity/visibility toggling, since the whole point is fitting one screen.
- **Quantity stepper** (Coin): – disabled/floors at 1, + increments; Total weight recomputes live as `denomination × quantity`.
- **RTL / Arabic**: Home and Guest Landing support a language toggle (`en`/`ar`) that flips text direction (`dir="rtl"`), mirrors icons that imply direction (arrows, chevrons via `scaleX(-1)`), and swaps in Arabic copy/fonts (Noto Naskh Arabic / IBM Plex Sans Arabic). **The Create Request screens do not yet have this Arabic/RTL support — that still needs to be added** to match Home/Guest Landing before this is fully bilingual.

## State Management
- Home/Guest: `slide` (current carousel index, 0–3), `howOpen` (boolean, Guest accordion), `lang` (en/ar).
- Create Request — one local object per screen type:
  - Find Ornament: `{ type, purity, gems, range, approx, flex }`
  - Sell Ornament: `{ type, purity, approx, invoice }`
  - Coin: `{ buy, denom, qty, sealed }`
  - Bullion: `{ buy, assay }`
- No backend wiring in the prototype — all values are local UI state only. Real implementation needs to wire these to the existing request-draft model used by `find_ornament_screen.dart` et al., plus persist "Save draft" / validate on "Continue".

## Assets
- Logo: `karat-hive-logo.png` (bundled in this folder under `assets/`). Used at 40–44px height in headers across all screens.
- All jewellery/product imagery in the prototype is a **placeholder** (diagonal-stripe pattern with a text label like "hero · gold necklace", "ring", "coins") — real photography still needs to be sourced and dropped in before this ships.

## Files
- `Karat Hive Home.dc.html` — Home + Guest Landing, all 3 directions explored (1a is the chosen/final one; 1b/1c and the "as-built" 0a baseline are included for reference/comparison only — build from 1a).
- `Karat Hive Create Request.dc.html` — the 4 Create Request screens, 1a style only.
- `assets/karat-hive-logo.png` — logo asset.

Open each `.dc.html` file in a browser to interact with the live prototype (tap chips/toggles/dots, use the Tweaks panel for `lang`/`autoplay` on the Home file).

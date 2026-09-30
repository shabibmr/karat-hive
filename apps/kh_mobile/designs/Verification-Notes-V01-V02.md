# Mobile visual pass — V01 / V02 notes

| | |
|---|---|
| **Date** | 30 September 2026 |
| **Plan** | [`Implementation-Plan.md`](Implementation-Plan.md) |
| **Register** | [`Tasks-Register.md`](Tasks-Register.md) |

## V01 — Tests and analyze

### Changes
- Added `packages/kh_design_system/test/theme_tokens_test.dart`: locks `gold` `#D8A858`, `ctaFill` `#D8C0A8`, `formSurface` `#F0E8E0`, button radius 10 / height 48, nav `goldDark` selection, transparent indicator (no stadium).
- Regenerated `kh_design_system` goldens after the token/chrome move (button, bottom nav, app shell, confirm dialog, segmented tabs, status chips, date range, and related).
- `customer_shell_test.dart`: wraps with `khTheme()` and asserts five tabs + `goldDark` selected icon/label + transparent indicator.

### Commands and results
| Check | Result |
|---|---|
| `dart analyze` `packages/kh_design_system` | 0 errors, 0 warnings (info-level lints only, pre-existing) |
| `dart analyze` `apps/kh_mobile/karat_hive` | 0 errors; 1 pre-existing unused_import warning in `vendor_register_screen.dart` (untouched by this pass) |
| `flutter test` in `kh_design_system` (theme_tokens, goldens, shell, foundations, hero_and_tile) | All passed |
| `flutter test` customer home, create request screens, owner request card, customer shell, vendor shell | All passed (25) |

### Visual golden spot-check
- `kh_button_ltr.png`: flat champagne fill (`ctaFill`), ink label, rounded rectangle (~radius 10), not a stadium pill.
- `kh_bottom_nav_ltr.png`: selected Home icon + label in dark gold (`goldDark`); no gold stadium wash behind the item.

---

## V02 — Surface exercise

Browser MCP / interactive Flutter Chrome session was not available in this session. Exercise used widget tests, responsive suites, and golden inspection.

| Surface | How opened | Narrow | Wide | Outcome |
|---|---|---|---|---|
| Customer Home | `customer_home_screen_test.dart` (hero, 2×2 tiles, overflow at 320 / 390 / 1024, en + ar) | Pass | Pass | Hero + four photography tiles; open Requests not on Home |
| Find review | `create_request_screens_test.dart` Find review case | Pass (default harness) | — | Mosaic, icon rows, Edit text, single Publish Request CTA |
| Sell Old Gold | Same suite: Sell compose + condition `ctaFill` + indicative panel | Pass | — | Title Sell Old Gold; condition uses `ctaFill` |
| Coins / Bullion chrome | Same suite C01 chrome shared assertion | Pass | — | `formSurface` + radius-10 `ctaFill` CTA |
| Summary card | `owner_request_card_test.dart` | Pass | — | View Details `ctaFill`; Message absent |
| Customer shell (5 tabs + nav colour) | `customer_shell_test.dart` | Pass | — | Five destinations; selected = `goldDark`; indicator transparent |
| Vendor home shell | `vendor_shell_test.dart` + `vendor_dashboard_screen_test.dart` | Pass | — | Shell mounts; dashboard renders under shared theme |
| Responsive smoke | `mobile_responsive_test.dart` | Pass | Pass (tablet) | No layout failures on small phone / tablet |

### Locked checks confirmed
- Five Customer tabs remain.
- Selected nav uses `goldDark`.
- Primary CTA is radius 10 and `ctaFill` `#D8C0A8`.
- Summary card has no Message control.

### Not exercised interactively
- Live Flutter web/Chrome or device tap-through of Guest → Home → Sell → Review with a running API.
- Arabic layout beyond existing en/ar Home overflow tests.

### Follow-ups outside V01–V02 acceptance
- Pre-existing `unused_import` in `vendor_register_screen.dart`.
- Hard-coded colours remain in legacy `request_type_screen.dart` (old dark theme) and some create-field helpers; not asserted by V01.
- Interactive device pass when Chrome MCP or an emulator is available.

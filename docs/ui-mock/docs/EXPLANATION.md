# Karat Hive UI Mock — Explanation

**Product:** Karat Hive  
**Artifact:** Interactive HTML/CSS/JS mock of all inventory screens  
**Location:** `ui-mock/`  
**Visual authority:** `ui-screens/Karat_Hive_UI_Design_Context.md`  
**Field authority:** `ui-screens/customer|vendor|admin/*.md`

---

## 1. What this mock is

A **static, multi-file** walkthrough of the Karat Hive product UI for:

| Role | Screens | Platform chrome |
|---|---|---|
| Customer | 22 (`CUS-S01` … `CUS-S22`) | Mobile phone shell |
| Vendor | 22 (`VEN-S01` … `VEN-S22`) | Mobile phone shell |
| Platform Admin | 23 (`ADM-S01` … `ADM-S23`) | Responsive web + sidebar |

Total: **67 screens**.

It is **not** a production app. There is no backend, no real OTP/OAuth, and no Flutter code. Data is hardcoded sample content for demos, design review, and field QA against the screen inventory.

---

## 2. Product flow (domain)

Karat Hive is **request-driven**, not catalogue e-commerce:

```text
Customer creates Request
        ↓
Eligible Vendors matched
        ↓
Vendors submit Offers
        ↓
Customer compares Offers
        ↓
Customer accepts one Offer (“Mark as Interested”)
        ↓
Identities revealed (BR-006 ends)
        ↓
WhatsApp handoff (Talk)
        ↓
Optional mutual reviews
```

Design personality: **luxury jewellery salon** — dark sapphire surfaces, restrained metallic gold, cream typography, Art Deco geometry without cheap yellow-gold decoration.

---

## 3. How to run

Screen HTML loads with `fetch`, so open over **HTTP** (not `file://`):

```bash
npx --yes serve ui-mock
```

Or:

```bash
cd ui-mock
python -m http.server 5173
```

Open the printed local URL.

---

## 4. Login (role chooser only)

The entry screen shows **three options only**:

1. **Customer** → `#/customer/CUS-S02` (Home)  
2. **Vendor** → `#/vendor/VEN-S05` (Dashboard)  
3. **Admin** → `#/admin/ADM-S02` (Dashboard)  

No email/password on the chooser.  
Full auth **fields** still exist as mock forms on:

- `CUS-S01` Onboarding (mobile + OTP + OAuth fields)  
- `VEN-S01` / `VEN-S04` Registration / login  
- `ADM-S01` Admin login + 2FA  

Use the **Screen map** (☰) to open those for inventory review.

Role is stored in `sessionStorage.kh_role`. Logout returns to `#/login`.

---

## 5. Navigation

### Hash routes

```text
#/login
#/customer/CUS-S04
#/vendor/VEN-S09
#/admin/ADM-S07
```

### Customer bottom tabs

| Tab | Typical screens |
|---|---|
| Home | `CUS-S02` (+ create flow) |
| Requests | `CUS-S10` detail, offers path |
| Connections | `CUS-S16`, `CUS-S15` |
| Alerts | `CUS-S19` |
| Profile | `CUS-S20`, settings, history |

History (`CUS-S17`) is reachable from Profile / screen map — not a primary tab (aligned with design context §30).

### Vendor bottom tabs

Dashboard · Requests · Offers · Connect · More  

`VEN-S03` (Awaiting approval) uses a **restricted** shell (no marketplace tabs).

### Admin

Sidebar list of all admin screens (drawer on small viewports).

### Screen map

Toolbar **☰** lists every screen for the current role for one-click QA.

---

## 6. Folder structure

```text
ui-mock/
  index.html              Shell: login, mobile, admin, side explanation
  README.md               Short run guide
  docs/
    EXPLANATION.md        This document (export)
  css/
    tokens.css            Design tokens (palette, type, motion)
    components.css        Buttons, cards, chips, gold-light, tables
    shell.css             Phone frame, admin layout, side panel
    screens.css           Screen-specific helpers
  js/
    data.js               Sample entities (rates, requests, offers…)
    nav.js                Route table for all 67 IDs + tabs
    gold-light.js         Signature gold sweep (reduced-motion aware)
    app.js                Router, chrome, screen map, panel toggle
  assets/
    brand/                Logo mark
    placeholders/         Ornament, coin, bullion, docs, avatars
    illustrations/        Empty / awaiting states
  screens/
    customer/             22 HTML partials
    vendor/               22 HTML partials
    admin/                23 HTML partials
```

---

## 7. Design system (mock)

Mapped from `Karat_Hive_UI_Design_Context.md`:

| Token idea | Example |
|---|---|
| Canvas | `sapphire900` `#0A1128` |
| Elevated | `sapphire800` / `sapphire700` |
| Accent | metallic gold gradient on CTAs |
| Text | cream on dark; muted gold for labels |
| Type | Cormorant Garamond (display) + DM Sans (UI) |
| Motion | Gold-light sweep on hero / primary CTAs only |

**Rules observed in the mock:**

- Identity **masked** before acceptance (Verified Jeweller · Region · rating).  
- Identity **revealed** on connection screens.  
- WhatsApp **green only** on Talk actions.  
- Status uses **chip + text**, not colour alone.  
- `prefers-reduced-motion` disables gold sweep.

---

## 8. Field completeness method

1. Each inventory file under `ui-screens/**` has a **Fields** table.  
2. Each screen HTML under `ui-mock/screens/**` includes a UI block per field with sample data.  
3. High-visibility flows are hand-composed for design fidelity:

   - Customer Home (`CUS-S02`) — hero “Shine brighter”, type tiles, gold rate card  
   - Offers / compare / accept / connection  
   - Vendor dashboard & subscription  
   - Admin dashboard  

**Inventory wins for what appears; design context wins for how it looks.**

---

## 9. Sample data highlights

- Gold rates: 24K / 22K / 21K / 18K AED per gram, “indicative only”  
- Requests: ornament (offers received), sell old gold, coins  
- Offers: three masked vendor offers with price, making, readiness, expiry  
- Connection: Al Noor Jewellery revealed contact  
- Admin: queue counts and platform metrics  

All values are fictional.

---

## 10. Source-of-truth split

| Concern | Document |
|---|---|
| Screen IDs & count | `ui-screens/README.md` |
| Fields / entry-exit | Per-screen `*.md` |
| Widgets | `ui-screens/component-widgets.md` |
| Visual & motion | `ui-screens/Karat_Hive_UI_Design_Context.md` |
| Domain language | Root `CONTEXT.md` |
| ADRs | `docs/adr/` |

---

## 11. Out of scope

- Real authentication, payments, WhatsApp API  
- Flutter / Material 3 implementation  
- Full Arabic copy (RTL layout can be added later)  
- Photo-real jewellery photography (SVG placeholders used)  
- Continuous animations on every list row  

---

## 12. Suggested review path

1. Login as **Customer** → Home → Create type → create form → Offers → Compare → Accept → Connection.  
2. Logout → **Vendor** → Dashboard → Available requests → Submit offer → Connections.  
3. Logout → **Admin** → Dashboard → Verification queue → Customer/Vendor lists.  
4. Use **Screen map** to spot-check remaining IDs for missing fields.

---

*Generated for the Karat Hive UI mock. Side panel in the mock UI shows a condensed version of this document.*

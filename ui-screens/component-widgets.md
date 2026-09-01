# Karat Hive — Component & Widget Catalog

Widget inventory derived from the [screen inventory](README.md) (`CUS-*`, `VEN-*`, `ADM-*`) and SRS field behaviour. This is a **UI component map**, not visual design or framework code.

| Scope | Meaning |
|---|---|
| **Shared** | Reused across roles, modes, or many screens with props/variants |
| **Individual** | Role- or flow-specific; not shared across the dual-mode shell or Admin portal |

**Platforms**

| Platform | Users |
|---|---|
| **Mobile app** — Flutter, one binary, dual mode | Customer · Vendor |
| **Admin Portal** — Flutter Web (≥ 1280 px) | Platform Admin |

Domain terms follow root `CONTEXT.md` (Request, Offer, Acceptance, Connection, Talk, Identity Masking).

---

## How to read each component

| Column | Meaning |
|---|---|
| **ID** | Stable component id for design/build tracking |
| **Widget** | Name |
| **Variants / props** | Key configuration |
| **Used by screens** | Primary consumers (not exhaustive if global chrome) |

---

# 1. Shared components

## 1.1 App shell & chrome (mobile dual-mode)

| ID | Widget | Variants / props | Used by |
|---|---|---|---|
| `SH-SHELL-01` | **App shell** | mode: Customer \| Vendor; bottom/tab nav items; RTL | All authenticated mobile screens |
| `SH-SHELL-02` | **Top app bar** | title, back, actions (filter, bell, overflow) | Most mobile screens |
| `SH-SHELL-03` | **Bottom navigation** | Customer items vs Vendor items (mode-specific labels) | Primary destinations |
| `SH-SHELL-04` | **Mode / role gate** | redirects non-matching role; no dual-role session | Cold start |
| `SH-SHELL-05` | **Awaiting Approval shell** | status body slot only; **no** marketplace routes | VEN-S03 (Vendor-only shell, shared *pattern* with restricted shell) |
| `SH-SHELL-06` | **Pull-to-refresh container** | onRefresh, lastUpdated | Lists, dashboards |
| `SH-SHELL-07` | **Safe-area / keyboard avoiding layout** | form screens | Auth, create, offer forms |

> **Note:** `SH-SHELL-05` is listed under shared *shell patterns* but content is Vendor-only. Customer has no equivalent marketplace lock shell beyond OAuth gate banners.

## 1.2 Foundations (mobile + reusable concepts for Admin)

| ID | Widget | Variants / props | Used by |
|---|---|---|---|
| `SH-FND-01` | **Primary / secondary / destructive button** | loading, disabled, full-width | Global |
| `SH-FND-02` | **Text field** | label, error, helper, maxLength, secure | Forms |
| `SH-FND-03` | **Numeric field** | decimal places, min/max, unit suffix (g, AED) | Weight, price, budget |
| `SH-FND-04` | **Select / dropdown** | single, searchable | Category, purity, reasons |
| `SH-FND-05` | **Multi-select chips** | taxonomy multi | Categories, Regions (Vendor) |
| `SH-FND-06` | **Toggle / switch** | — | Settings, flexible budget, away mode |
| `SH-FND-07` | **Checkbox + legal link** | ToS / Privacy accept | Registration |
| `SH-FND-08` | **Segmented control** | 2–n options | BUY/SELL, budget mode, tabs lite |
| `SH-FND-09` | **Date / time picker** | date only; schedule | Admin schedule; licence expiry |
| `SH-FND-10` | **Date range picker** | presets + custom | History, Admin reports |
| `SH-FND-11` | **Search field** | debounce, clear | Lists |
| `SH-FND-12` | **Empty state** | illustration slot, title, body, primary CTA | Lists with zero data |
| `SH-FND-13` | **Error / inline validation banner** | field-level + form-level | Forms |
| `SH-FND-14` | **Loading skeleton / spinner** | list vs page | Async screens |
| `SH-FND-15` | **Confirm dialog** | title, body, confirm (destructive style optional) | Accept, cancel, withdraw, delete |
| `SH-FND-16` | **Bottom sheet / modal** | filters, actions | Mobile filters, reason pickers |
| `SH-FND-17` | **Toast / snackbar** | success, error, info | Save, submit feedback |
| `SH-FND-18` | **Badge / count chip** | unread, tab counts | Offers, notifications, tabs |
| `SH-FND-19` | **Status chip** | Request/Offer/Connection/account state → colour map | Lists, detail headers |
| `SH-FND-20` | **Section header** | title, action link | Dashboards, forms |
| `SH-FND-21` | **Divider / list separator** | — | Lists |
| `SH-FND-22` | **Copy-to-clipboard control** | value, success toast | Phone numbers, references |
| `SH-FND-23` | **External link row** | ToS, Privacy, support | Settings |
| `SH-FND-24` | **App version footer** | version string | Settings |
| `SH-FND-25` | **Pagination / infinite scroll sentinel** | page vs infinite | History, feeds, Admin tables |
| `SH-FND-26` | **Tabs** | count badges per tab | My Offers; Admin queues |

## 1.3 Auth & identity (mobile)

| ID | Widget | Variants / props | Used by |
|---|---|---|---|
| `SH-AUTH-01` | **Mobile number field (UAE / E.164)** | country prefix fixed/configurable | CUS-S01, VEN-S01, VEN-S04 |
| `SH-AUTH-02` | **OTP entry** | length, resend cooldown, expiry countdown | Customer + Vendor auth |
| `SH-AUTH-03` | **OTP send / resend control** | rate-limit messaging | Auth flows |
| `SH-AUTH-04` | **OAuth provider button row** | Google / Apple / configured; bound state | CUS-S01, CUS-S09 gate |
| `SH-AUTH-05` | **OAuth required banner / gate** | blocks publish only | CUS-S09, create flow |
| `SH-AUTH-06` | **Biometric unlock toggle / prompt** | Face ID / fingerprint | CUS-S01/S21; optional Vendor |
| `SH-AUTH-07` | **Session lockout message** | duration, support | Auth failures |
| `SH-AUTH-08` | **Email + password form** | show/hide password | VEN-S04, VEN-S18; Admin uses web variant |

## 1.4 Gold, money, time (domain chrome)

| ID | Widget | Variants / props | Used by |
|---|---|---|---|
| `SH-DOM-01` | **Reference gold rate strip** | purities list, updated_at, **stale** style, indicative label | Create flows, Vendor dashboard, offer context |
| `SH-DOM-02` | **Indicative valuation** | weight × rate → AED; “estimate, not an offer” | Sell Old Gold, Bullion min check |
| `SH-DOM-03` | **Money display (AED)** | amount, optional delta, best-value highlight | Offers, comparison, Admin |
| `SH-DOM-04` | **Money input (AED)** | min/max validation | Price, budget, making charges |
| `SH-DOM-05` | **Weight input (grams)** | 0.10–5000.00, 2 dp; approximate flag | Request create |
| `SH-DOM-06` | **Purity picker** | 24K / 22K / 21K / 18K (configurable list) | Request create, rate strip |
| `SH-DOM-07` | **Hard expiry countdown** | Request 48 h; Offer validity; urgency style &lt; 6 h / &lt; 24 h | Request/Offer rows & detail |
| `SH-DOM-08` | **Relative time** | “2 h ago”, GST display | Feeds, lists |
| `SH-DOM-09` | **Entity reference chip** | `KH-RQ-…` copyable | Request detail, Talk message, Admin |

## 1.5 Taxonomy & media

| ID | Widget | Variants / props | Used by |
|---|---|---|---|
| `SH-TAX-01` | **Category picker** | single (Request) / multi (Vendor services); EN/AR labels | Create, VEN-S16, Admin taxonomy |
| `SH-TAX-02` | **Region picker** | single / multi; emirate → area | Create, profile, VEN-S16 |
| `SH-MED-01` | **Image capture / gallery picker** | max count, formats, size limit, progress, retry | CUS-S08; Offer images (≤3); shop photos |
| `SH-MED-02` | **Image thumbnail grid** | reorder, remove, cover badge (first = thumbnail) | Create, edit Request |
| `SH-MED-03` | **Image carousel / lightbox** | full resolution | Request detail, Offer detail, Admin |
| `SH-MED-04` | **Document upload tile** | PDF/JPEG/PNG, expiry date, replace | VEN-S02; Admin KYC viewer is separate |
| `SH-MED-05` | **Upload progress row** | percent, failed + retry | Media uploads |

## 1.6 Identity masking & trust

| ID | Widget | Variants / props | Used by |
|---|---|---|---|
| `SH-ID-01` | **Masked party label** | role: Vendor \| Customer; Region; optional rating & deal count | Pre-acceptance Offers (Customer); Requests (Vendor) |
| `SH-ID-02` | **Revealed party card** | name, mobile, address/business fields by role | Connection details only |
| `SH-ID-03` | **Rating summary** | average 1 dp, count, star distribution, “New — limited history” (&lt; 3) | Offer detail, Vendor profile, dashboards |
| `SH-ID-04` | **Star rating input** | 1–5 mandatory | Leave review (both parties) |
| `SH-ID-05` | **Review comment field** | max 1000 chars | Leave review |
| `SH-ID-06` | **Review list item** | abbreviated author, stars, text, date | Ratings sheets, VEN-S20, Admin moderation |
| `SH-ID-07` | **Trust signal row** | completed Connections count | Masked labels, detail |

## 1.7 Request / Offer / Connection (shared domain cards)

| ID | Widget | Variants / props | Used by |
|---|---|---|---|
| `SH-REQ-01` | **Request summary card** | owner view vs vendor view (masking, density) | CUS-S02/S10; VEN-S05/S06/S08 |
| `SH-REQ-02` | **Request type tile** | 4 types + short description | CUS-S03 |
| `SH-REQ-03` | **Request direction control** | fixed (display) vs selectable BUY/SELL | Create flows |
| `SH-REQ-04` | **Budget editor** | max-only \| min–max; flexible flag; mandatory by type | Ornament + optional BUY |
| `SH-REQ-05` | **Ornament type picker** | ring, chain, bangle, … | CUS-S04/S05 |
| `SH-REQ-06` | **Coin denomination + quantity** | total weight computed | CUS-S06 |
| `SH-REQ-07` | **Bullion bar weight + quantity + min-value gate** | shows threshold vs computed | CUS-S07 |
| `SH-REQ-08` | **Request state timeline / history** | state transitions | Detail, Admin |
| `SH-OFF-01` | **Offer summary row** | price, masked vendor/customer context, expiry, unread | CUS-S11; VEN-S11 |
| `SH-OFF-02` | **Offer terms form** | price*, validity*, optional charges/rate/delivery/warranty/note/images | VEN-S09/S10 |
| `SH-OFF-03` | **Offer validity picker** | configured hours; clamp to Request remaining life | VEN-S09/S10 |
| `SH-OFF-04` | **Offer terms read-only block** | full attributes + images | CUS-S13; Connection; Admin |
| `SH-CON-01` | **Connection summary row** | counterparty, ref, price, date, state | CUS-S16; VEN-S12; Admin |
| `SH-CON-02` | **Talk (WhatsApp) button** | builds `wa.me` link + prefilled text; logs contact event | CUS-S15; VEN-S13 |
| `SH-CON-03` | **Tap-to-call control** | tel: + copy fallback | VEN-S13; Customer optional |
| `SH-CON-04` | **Close Connection action** | confirm → review prompt | Both parties Connection detail |

## 1.8 Notifications, reports, settings (mobile shared)

| ID | Widget | Variants / props | Used by |
|---|---|---|---|
| `SH-NTF-01` | **Notification list item** | category icon, read/unread, deep link | CUS-S19; VEN-S17 |
| `SH-NTF-02` | **Notification centre list** | 90-day window | Same |
| `SH-NTF-03` | **Notification preference matrix** | category × channel; lock security-critical | Settings |
| `SH-RPT-01` | **Abuse report form** | category set differs by reporter role; free text; linked entity | CUS-S22; VEN-S21 |
| `SH-SET-01` | **Language picker** | en / ar; applies RTL immediately | Settings both modes |
| `SH-SET-02` | **Settings group list** | sectioned rows | CUS-S21; VEN-S18 |

## 1.9 Admin Portal foundations (web-shared within Admin)

Admin does not share the mobile binary, but these are **shared across Admin screens**.

| ID | Widget | Variants / props | Used by |
|---|---|---|---|
| `SH-ADM-01` | **Admin app layout** | sidebar nav, top bar, role-gated menu | All ADM-* |
| `SH-ADM-02` | **Data table** | sort, column config, row click, bulk none by default | Lists ADM-S03…S12 |
| | ⚠️ *Flutter Web has no first-party HTML-grid equivalent. Build-or-buy decision needed before Admin list screens start; must satisfy keyboard operability and text selection per SRS `NFR-023`.* | | |
| `SH-ADM-03` | **Filter bar** | chips + advanced filters + search | List screens |
| `SH-ADM-04` | **Metric card** | value, delta/trend sparkline, link-through | ADM-S02 |
| `SH-ADM-05` | **Queue panel** | count, oldest age, primary CTA | Dashboard + verification/abuse/reviews |
| `SH-ADM-06` | **Detail page layout** | header actions, tabs/sections, audit footnote | Detail screens |
| `SH-ADM-07` | **Internal notes thread** | attributed, timestamped Admin-only notes | Customer/Vendor/Request/Offer detail |
| `SH-ADM-08` | **Rationale / reason form** | required reason list + free text | Suspend, reject, remove, moderate |
| `SH-ADM-09` | **Document / KYC viewer** | full-res, page nav, view-audit on open | ADM-S06/S07 |
| `SH-ADM-10` | **Date-range toolbar** | today / 7 / 30 / 90 / custom | Dashboard, reports |
| `SH-ADM-11` | **Chart block** | line/bar/pie as needed | Dashboard, reports |
| | ⚠️ *Same as `SH-ADM-02`: charting comes from a Flutter package, not the browser — pick one that renders acceptably on Web and exports to PNG for `SH-ADM-12`.* | | |
| `SH-ADM-12` | **Export control** | CSV / XLSX / PNG; async large job | ADM-S17; VEN history concept |
| `SH-ADM-13` | **2FA code input** | TOTP/SMS | ADM-S01 |
| `SH-ADM-14` | **Taxonomy tree editor** | 2-level create/rename/reorder/activate | ADM-S14/S15 |
| `SH-ADM-15` | **Setting row editor** | current value, range, effect copy, confirm | ADM-S19 |
| `SH-ADM-16` | **Audit entry row** | actor, action, target, before/after, IP, time | ADM-S22 |
| `SH-ADM-17` | **Announcement composer form** | audience, channels, EN/AR body, schedule, critical | ADM-S18 |
| `SH-ADM-18` | **Moderation decision bar** | Approve / Reject / Redact sticky actions | ADM-S16 |
| `SH-ADM-19` | **Unmasked party banner** | Admin-only identity always shown | Oversight details |

---

# 2. Individual components

## 2.1 Customer-only

| ID | Widget | Purpose | Screens |
|---|---|---|---|
| `CU-01` | **Customer home Request list** | Owner-centric live Requests + quick create | CUS-S02 |
| `CU-02` | **Request type selection grid** | Four type tiles with guidance | CUS-S03 |
| `CU-03` | **Create flow wizard chrome** | Step progress for type-specific create | CUS-S04…S07 → S09 |
| `CU-04` | **Find Ornament form section** | Spec + mandatory budget + gemstones | CUS-S04 |
| `CU-05` | **Sell Old Gold form section** | Actual-item photo warning + condition + invoice flag | CUS-S05 |
| `CU-06` | **Gold Coins form section** | Direction + denomination + packaging | CUS-S06 |
| `CU-07` | **Gold Bullion form section** | Min-value gate messaging (AED floor) | CUS-S07 |
| `CU-08` | **Request review & publish panel** | Full summary + draft + publish + OAuth gate | CUS-S09 |
| `CU-09` | **Publish success confirmation** | Reference + hard expiry (48 h) | CUS-S09 |
| `CU-10` | **Owner Request detail actions** | Edit notes/budget/images; cancel + reason | CUS-S10 |
| `CU-11` | **Customer Offers list** | Unread markers; sort/filter for buyer interest | CUS-S11 |
| `CU-12` | **Offer multi-select for compare** | Select 2–4 Offers | CUS-S11 → S12 |
| `CU-13` | **Side-by-side Offer comparison table** | Row-aligned attrs; best-value highlight by direction; accept per column | CUS-S12 |
| `CU-14` | **Mark as Interested confirmation** | Irreversibility + identity reveal warning | CUS-S14 |
| `CU-15` | **Decline Offer sheet** | Optional structured decline reasons | CUS-S13 |
| `CU-16` | **Customer Connection detail** | Revealed **Vendor** business fields + Talk | CUS-S15 |
| `CU-17` | **Customer history browser** | Terminal Requests filters + search by ref | CUS-S17 |
| `CU-18` | **Customer profile form** | Photo, language, Region; mobile change + OTP | CUS-S20 |
| `CU-19` | **Account deactivation / deletion** | Two-step delete; 30-day Connection block | CUS-S21 |
| `CU-20` | **Vendor ratings sheet (pre-accept)** | Masked Vendor only; excerpts ≤10 | CUS-S13 / FR-CUS-031 |

## 2.2 Vendor-only

| ID | Widget | Purpose | Screens |
|---|---|---|---|
| `VE-01` | **Business registration form** | Legal/trading/licence/address/contact + OTP | VEN-S01 |
| `VE-02` | **KYC document checklist** | Mandatory vs optional docs + expiry | VEN-S02 |
| `VE-03` | **Awaiting Approval status panel** | State, Admin messages, re-upload, support | VEN-S03 |
| `VE-04` | **Vendor dashboard** | Three count panels + rate + own rating + subscription snapshot | VEN-S05 |
| `VE-05` | **Dashboard metric panel** | New Requests / Pending Offers / Active Connections | VEN-S05 |
| `VE-06` | **New Requests inline preview** | ≤3 matched previews | VEN-S05 |
| `VE-07` | **Available Requests feed (dense)** | High-density rows; offer count without competitor prices | VEN-S06 |
| `VE-08` | **Request filter sheet + saved presets** | Full filter set + named presets | VEN-S07 |
| `VE-09` | **Vendor Request detail** | Full spec; masked Customer; competitive **count** only | VEN-S08 |
| `VE-10` | **Submit Offer form** | Mandatory price + validity; optional terms; contact-scan on note | VEN-S09 |
| `VE-11` | **Revise / withdraw Offer panel** | Revision remaining counter (max 3) | VEN-S10 |
| `VE-12` | **My Offers tabbed list** | Pending / Accepted / Rejected–Expired | VEN-S11 |
| `VE-13` | **Pending Offer row actions** | Revise + Withdraw + urgency | VEN-S11 |
| `VE-14` | **Rejected Offer outcome row** | “Awarded elsewhere” without winning price/Vendor | VEN-S11 |
| `VE-15` | **Vendor Connection detail** | Revealed **Customer** fields + Talk + Call | VEN-S13 |
| `VE-16` | **Offer history & performance dashboard** | Acceptance rate, response time, relative-to-win aggregates | VEN-S14 |
| `VE-17` | **Business profile editor** | Split editable vs re-verification-trigger fields | VEN-S15 |
| `VE-18` | **Masked public preview card** | What Customers see pre-acceptance | VEN-S15 |
| `VE-19` | **Categories / Regions / hours editor** | ≥1 each; volume estimate; away mode | VEN-S16 |
| `VE-20` | **Vendor settings security block** | Password, active sessions, revoke | VEN-S18 |
| `VE-21` | **My reviews & response composer** | Response ≤500; flag unfair | VEN-S20 |
| `VE-22` | **Subscription by Request type board** | Four independent entitlements + subscribe/upgrade | VEN-S22 |
| `VE-23` | **Type entitlement card** | State, period, price, CTA | VEN-S22 |
| `VE-24` | **Quiet hours / business-hours notification gate UI** | Suppress/queue new-request notifications | VEN-S16/S18 |

## 2.3 Platform Admin-only

| ID | Widget | Purpose | Screens |
|---|---|---|---|
| `AD-01` | **Admin login + 2FA flow** | Email/password + TOTP/SMS | ADM-S01 |
| `AD-02` | **Admin dashboard grid** | Metrics + three action queues | ADM-S02 |
| `AD-03` | **Customer admin list/detail** | Unmasked PII columns; suspend/delete | ADM-S03/S04 |
| `AD-04` | **Vendor admin list/detail** | Performance + state actions | ADM-S05/S06 |
| `AD-05` | **Verification queue + decision workspace** | Side-by-side docs + Approve/Reject/More info | ADM-S07 |
| `AD-06` | **Request admin oversight** | Matched Vendors, all Offers, remove Request | ADM-S08/S09 |
| `AD-07` | **Offer admin oversight** | Revision history; winning Offer link (Admin-only) | ADM-S10/S11 |
| `AD-08` | **Connection admin oversight** | Talk usage flags; admin close; no chat content | ADM-S12/S13 |
| `AD-09` | **Category management UI** | EN/AR, icon, order, active; block delete-in-use | ADM-S14 |
| `AD-10` | **Region management UI** | Emirate → area tree | ADM-S15 |
| `AD-11` | **Review moderation workspace** | Approve/Reject/Redact sticky bar | ADM-S16 |
| `AD-12` | **Reports & analytics studio** | Report type selector + charts + export | ADM-S17 |
| `AD-13` | **Announcement composer** | Audience, channels, bilingual, schedule, stats | ADM-S18 |
| `AD-14` | **Platform settings console** | All operational knobs + Super Admin confirm | ADM-S19 |
| `AD-15` | **Gold rate console** | Yahoo status, stale, manual override + history | ADM-S20 |
| `AD-16` | **Abuse report triage workspace** | Jump to entities; dismiss/warn/suspend/deactivate | ADM-S21 |
| `AD-17` | **Audit log explorer** | Filters; immutable (no edit UI) | ADM-S22 |
| `AD-18` | **Admin user management** | Roles Super / Operations / Analyst | ADM-S23 |
| `AD-19` | **PII access watermark / export banner** | Exporting Admin, timestamp, purpose | ADM-S17 exports |

---

# 3. Shared vs individual — decision rules

| Use **Shared** when… | Use **Individual** when… |
|---|---|
| Same interaction in Customer and Vendor (OTP, Talk, rating input, rate strip) | Behaviour or data shape is role-unique (comparison table vs dense feed) |
| Admin tables/filters repeat across many list screens | Queue decision workflow is one-off (verification, review moderation) |
| Masking/reveal is a platform rule with two modes of the same card | Form sections are type-specific (ornament vs bullion) |
| Props can switch density/masking (`owner` vs `vendor` Request card) | Copy, legal, or entitlement logic is mode-specific |

**Composition pattern (recommended)**

```
Screen
  └─ Shell (shared)
       └─ Domain card (shared, masked/revealed variant)
            └─ Role-specific actions (individual)
```

Example: **Connection detail**

| Layer | Component |
|---|---|
| Shared | `SH-CON-01` row, `SH-CON-02` Talk, `SH-ID-02` revealed card shell |
| Individual | `CU-16` Vendor business fields vs `VE-15` Customer fields + call |

---

# 4. Screen → component map (high signal)

## Customer critical path

| Screen | Shared widgets | Individual widgets |
|---|---|---|
| CUS-S01 | `SH-AUTH-*`, `SH-FND-*` | — |
| CUS-S03 | `SH-REQ-02` | `CU-02` |
| CUS-S04…S07 | `SH-DOM-*`, `SH-TAX-*`, `SH-MED-*`, `SH-REQ-03…07` | `CU-03`…`CU-07` |
| CUS-S08 | `SH-MED-01`…`03` | — |
| CUS-S09 | `SH-AUTH-05`, `SH-REQ-01` | `CU-08`, `CU-09` |
| CUS-S11…S13 | `SH-OFF-*`, `SH-ID-*` | `CU-11`…`CU-13`, `CU-15`, `CU-20` |
| CUS-S14 | `SH-FND-15` | `CU-14` |
| CUS-S15…S16 | `SH-CON-*`, `SH-ID-02` | `CU-16` |

## Vendor critical path

| Screen | Shared widgets | Individual widgets |
|---|---|---|
| VEN-S01…S03 | `SH-AUTH-*`, `SH-MED-04` | `VE-01`…`VE-03` |
| VEN-S05 | `SH-DOM-01`, `SH-ID-03` | `VE-04`…`VE-06` |
| VEN-S06…S08 | `SH-REQ-01`, `SH-ID-01` | `VE-07`…`VE-09` |
| VEN-S09…S11 | `SH-OFF-02`…`04` | `VE-10`…`VE-14` |
| VEN-S13 | `SH-CON-02`…`04` | `VE-15` |
| VEN-S22 | — | `VE-22`, `VE-23` |

## Admin critical path

| Screen | Shared (Admin) | Individual |
|---|---|---|
| ADM-S02 | `SH-ADM-04`, `SH-ADM-05`, `SH-ADM-10` | `AD-02` |
| ADM-S07 | `SH-ADM-09`, `SH-ADM-08` | `AD-05` |
| ADM-S16 | `SH-ADM-18`, `SH-ID-06` | `AD-11` |
| ADM-S19…S20 | `SH-ADM-15` | `AD-14`, `AD-15` |
| ADM-S21…S23 | `SH-ADM-02`, `SH-ADM-16` | `AD-16`…`AD-18` |

---

# 5. Counts (for planning)

| Bucket | Count (approx.) |
|---|---|
| Shared — mobile shell & foundations | ~33 |
| Shared — auth / domain / media / identity / REQ-OFF-CON / notify | ~45 |
| Shared — Admin portal foundations | ~19 |
| Individual — Customer | 20 |
| Individual — Vendor | 24 |
| Individual — Admin | 19 |
| **Total catalog entries** | **~160** |

Exact build packages may merge pure foundation controls into a design system; domain widgets (`SH-DOM-*`, `SH-REQ-*`, `SH-OFF-*`, `SH-ID-*`) should stay explicit for masking and marketplace rules.

---

# 6. Non-goals

- Pixel specs, colours, typography tokens (design system later)
- Widget-library and package selection — the framework itself is now fixed (Flutter, all surfaces; SRS C-10), but which packages implement these components is an engineering call
- Backend API contracts (only UI-facing props implied by SRS)
- System jobs without UI (`FR-SYS` fan-out) — only chrome they drive (countdowns, live list updates)

---

# 7. Source & related

- Screens: [README.md](README.md), `customer/`, `vendor/`, `admin/`
- Requirements: `docs/Requirements-Spec-v1.2.md` Appendix C, §4, §6, §7.1
- Stack constraints: `docs/Requirements-Spec-v1.2.md` §2.5 (C-10–C-13), `docs/adr/0006`, `docs/adr/0007`
- Language: `CONTEXT.md` (Identity Masking, Talk, Connection, etc.)
- Known tension: Offer validity options — component `SH-OFF-03` must read configured set from platform settings (`ADM-S19`), not hard-code

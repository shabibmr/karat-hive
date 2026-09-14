# Inspector Balram: Vendor Screen-by-Screen Case-Dairy

## Master Unit Checklist

| # | Unit ID & Name | Status |
|---|---|---|
| 1 | `VEN-S04` · Vendor Login | ✅ Approved |
| 2 | `VEN-S01` · Vendor Registration (4-Page Wizard) | ✅ Approved |
| 3 | `VEN-S02` · KYC Document Upload | ✅ Approved |
| 4 | `VEN-S03` · Awaiting Approval Shell | ✅ Approved |
| 5 | `VEN-S05` · Vendor Dashboard | ✅ Approved |
| 6 | `VEN-S06` · Available Requests Feed | ✅ Approved |
| 7 | `VEN-S07` · Request Filters & Presets | ✅ Approved |
| 8 | `VEN-S08` · Masked Request Detail | ✅ Approved |
| 9 | `VEN-S09` · Submit Offer | ✅ Approved |
| 10 | `VEN-S10` · View / Revise Offer | ✅ Approved |
| 11 | `VEN-S11` · My Offers / Status Hub | ✅ Approved |
| 12 | `VEN-S12` · Connection List | ✅ Solved (Sherlock, 2026-09-09 — review-only, findings logged) |
| 13 | `VEN-S13` · Connection Detail & Unmasked Contact | ✅ Solved (Sherlock, 2026-09-09 — review-only, findings logged) |
| 14 | `VEN-S14` · Offer History & Performance | ⏳ Cold |

> **Handover — 2026-09-09.** Sherlock resumed the case at VEN-S08 (review-only mode:
> findings recorded, no source edits). Earlier pass covered VEN-S08 and VEN-S09.
> Second pass (2026-09-09) closes out VEN-S12, VEN-S13, VEN-S14 and consolidates leads L1–L4,
> per-aspect (A. Visible Components / B. Functions / C. Business Rules / D. Anything else).
> Confidence reads follow each deduction. Evidence is cited to file/line or `FR-/BR-`.

---

## Unit Decisions & Case-Dairy

### VEN-S04 · Login
- **Status**: ✅ Approved
- **Decisions Recorded**:
  1. Auto-login on cold launch if valid token exists.
  2. Temporary `flutter_hive` token storage adapter, migrating to secure storage later.
  3. Clean single Google Sign-In button with registration deep link.

---

### VEN-S01 · Registration — Business Details
- **Status**: ✅ Approved
- **Decisions & Adjustments Applied**:
  1. **4-Page Wizard Flow (Casual tone)**:
     - **Step 1 of 4 (About You)**: Name *, Mobile *, Role, Action: "Next: Store profile", Link: "Already have an account? Sign in".
     - **Step 2 of 4 (Store Profile)**: Upload logo (image picker), Store / Business name *, Website (optional), Actions: "Next: Store location", "Back".
     - **Step 3 of 4 (Store Location)**: Shop / Unit #, Building or street, Emirate / Region * (chips), GPS Location / Google Maps Link (optional), Actions: "Next: Contact & Agreement", "Back".
     - **Step 4 of 4 (Contact & Agreement)**: WhatsApp number *, Email address (optional), Terms & Privacy checkbox *, Action: "Create Account", "Back".
  2. **Fields Removed / Deferred**: Legal business name, trade licence #, licence expiry deferred to KYC (`VEN-S02`). Categories selection deferred to `VEN-S16`.
  3. **OTP**: Bypassed for development via direct registration.
  4. **Error Handling**: 409 Conflict handled and presented via `KhInlineError`.

---

### VEN-S02 · KYC Document Upload
- **Status**: ✅ Approved
- **Decisions & Adjustments Applied**:
  1. **Combined KYC Data & Documents Form**:
     - **Official Business Details Section**:
       - `"Registered company / Legal name *"` (Text input)
       - `"Trade licence number *"` (Text input)
       - `"Licence expiry date (YYYY-MM-DD) *"` (DatePicker input)
     - **Verification Documents Section**:
       - Trade Licence document * (`Add` / `Replace` / `Retry`, PDF/JPG/PNG $\le 10$ MB)
       - Emirates ID (Authorised Contact) * (`Add` / `Replace` / `Retry`)
       - Document checklist counter indicator
     - **Action**: `"Submit for Verification"` (Enabled only when all 3 text fields and mandatory documents are uploaded).
  2. **API Flow**:
     - Media upload via `POST /v1/media/upload-intent` $\rightarrow$ PUT $\rightarrow$ `POST /v1/me/vendor/documents`.
     - Legal details patch via `PATCH /v1/me/vendor`.
  3. **Architectural Backlog Note (CRM / Contacts Normalization)**:
     - *Recommendation*: Extract normalized `Contact` entity (`entityType: VENDOR | CUSTOMER`, `contactPersonName`, `phone`, `email`, `role`, `crmSyncStatus`) for seamless integration with external CRMs (HubSpot / Zoho / Salesforce) and multi-contact vendor management.

---

### VEN-S03 · Awaiting Approval Shell
- **Status**: ✅ Approved
- **Decisions Recorded**:
  1. Zero-marketplace exposure (`403` guarded server-side via `VendorAccessGuard`).
  2. 15s polling + immediate lifecycle resume sync.
  3. Rejection / Request-info banner with free text from Admin.
  4. Resubmit action for `REJECTED` state.
  5. Clear "No SLA promised" copy.
  6. Transition to `VEN-S16` on `VERIFIED` state.

---

### VEN-S05 · Vendor Dashboard
- **Status**: ✅ Approved
- **Decisions & Adjustments Applied**:
  1. **Visual Layout**:
     - Status Card (Trading name + active status).
     - New Requests stat card (with up to 3 preview cards) $\rightarrow$ deep links to `VEN-S06` / `VEN-S08`.
     - Pending Offers stat card (with expiring within 24h cue) $\rightarrow$ deep links to `VEN-S11` Pending.
     - Active Connections stat card (with "no talk yet" cue) $\rightarrow$ deep links to `VEN-S12`.
     - Type Subscriptions summary $\rightarrow$ deep links to `VEN-S22`.
     - Rating & Reviews summary tile $\rightarrow$ deep links to `VEN-S20`.
     - **Reference gold rates**: Hidden per review.
  2. **API**: `GET /v1/me/dashboard` with stage `ACTIVE` enforcement.

---

### VEN-S06 · Available Requests Feed
- **Status**: ✅ Approved
- **Decisions & Adjustments Applied**:
  1. Feed card layout with category, karat, approximate budget, and location.
  2. Commercial shielding (`BR-006` / `BR-008`): customer contact and competitor pricing completely masked.
  3. Pull-to-refresh + cursor pagination.
  4. Mark-as-viewed on item tap.

---

### VEN-S07 · Request Filters & Presets
- **Status**: ✅ Approved
- **Decisions & Adjustments Applied**:
  1. Filter drawer with Sort (Newest, Expiry, Budget), Request Type chips, Category/Region selectors, Budget min/max inputs, Karat chips, and "Hide already responded" toggle.
  2. Filter presets saving (`POST /v1/filter-presets`) and quick switching with active counter.
  3. "Reset All" clears draft filters.

---

### VEN-S08 · Masked Request Detail
- **Status**: ✅ Approved
- **Decisions & Adjustments Applied**:
  1. High-resolution media gallery with stripped EXIF (`KhImageGallery`).
  2. Request Title, Request Type, Direction, and Expiry countdown timer (`ExpiryCountdown`).
  3. Masked Customer Summary card (`MaskedPartyLabel`) adhering strictly to `BR-006` / `NFR-013`.
  4. Specification Grid, customer notes, and offers received summary (`BR-008`).
  5. Top overflow menu for reporting abuse (`VEN-S21`).
  6. Sticky bottom CTA button: "Make an Offer" $\rightarrow$ `VEN-S09`.

---

### VEN-S09 · Submit Offer
- **Status**: ✅ Approved
- **Decisions & Adjustments Applied**:
  1. **Direct Price Input**: No automatic price calculation; vendor enters total offered price directly.
  2. **Validity Hours Removed from UI**: Vendor does not pick validity hours; system defaults to 24h capped by request hard expiry.
  3. **Gold Weight Added**: Added explicit `Gold weight (grams)` field to offer terms input.
  4. **Vendor Notes**: Free-text notes input retained with `BR-022` policy scanning for contact-detail prevention.
  5. **Supporting Media**: Mandatory at least 1 image and up to 3 supporting images (`JPEG/PNG`) required per offer response.
- **Spec**: `ui-screens/vendor/VEN-S09-submit-offer.md` · **SRS**: `FR-VEN-013` · **Invariants**: `BR-022`, `AD-API-07`

---

### VEN-S10 · View / Revise Offer
- **Status**: ✅ Approved
- **Decisions & Adjustments Applied**:
  1. **Customer Seen Status Indicator**: Added badge displaying `"Seen by Customer"` (accent) vs `"Not Seen Yet"` (neutral).
  2. **Single Revision Limit**: Maximum revisions strictly capped at **1** (`kMaxOfferRevisions = 1`).
  3. **Unseen Guard**: Revisions are permitted only if the Customer has **not yet seen** the response. Once viewed, revisions are immediately locked.
  4. **5-Minute Grace Window**: Revisions permitted only within **5 minutes** of initial submission timestamp (`submittedAt`).
  5. **Clear Lock Banners**: Screen displays a real-time countdown timer during the 5-minute active window, and explanatory status banners when locked.
  6. **Gold Weight & Fields Synced**: Offer terms read-only and edit forms include gold weight (`weightGrams`) and direct price.
- **Spec**: `ui-screens/vendor/VEN-S10-revise-withdraw-offer.md` · **SRS**: `FR-VEN-014` · **Invariants**: `BR-009`, `kMaxOfferRevisions` (1), 5-min unseen window

---

### VEN-S11 · My Offers / Status Hub
- **Status**: ✅ Approved
- **Decisions & Adjustments Applied**:
  1. **Thick Frosted Glass Masked Party Badge**: Customer identity displayed as obfuscated/random characters under a thick frosted glass gaussian blur filter with translucent container and lock icon.
  2. **Offer Count Hidden**: Competitor offer count indicators completely hidden across request cards and detail screens.
  3. **Uploaded Image as Main Subject**: Primary uploaded image displayed prominently as the hero subject banner/thumbnail across request cards and offer cards.
  4. **Customer Seen Status Badge**: In Pending tab cards, displays live status badge (`"Seen by Customer"` vs `"Not Seen Yet"`).
  5. **Segmented Tabs**: Clean separation between `Pending`, `Accepted`, and `Closed` (Rejected / Expired / Withdrawn) with real-time search by request reference.
- **Spec**: `ui-screens/vendor/VEN-S11-my-offers.md` · **SRS**: `FR-VEN-016`–`019` · **Invariants**: `BR-008`, `BR-006` (Frosted Glass Masking)

---

### VEN-S12 · Connection List
- **Status**: ✅ Solved — Sherlock pass 2026-09-09, review-only. A ✅ / B ✅ / C ✅ / D ✅.
- **Spec**: `ui-screens/vendor/VEN-S12-connections-list.md` · **SRS**: `FR-VEN-020` · **Invariants**: `BR-006`, `BR-007`, `BR-008`, `NFR-013`, `FR-VEN-021` AC4, `FR-SYS-011`
- **Design decisions carried from prior pass** (still stand):
  1. Active vs Closed grouping, active first.
  2. Identity unmasking — counterparty customer full name shown (revealed on offer acceptance).
  3. Talk shortcut — one-tap WhatsApp deep link, logs `recordContactEvent('WHATSAPP')`.
  4. Offer-terms snapshot — agreed price + request reference on each row.

- **A. Visible Components** — `Confident` on the inventory (widget tree small, fully read).
  - Row shows: customer name, ACTIVE/CLOSED chip, request reference, agreed price (`MoneyDisplay`),
    connection date as **relative only** ("3 days ago"); spec `:28` asks for datetime.
  - "Talk" button = `TextButton.icon` with **`Icons.open_in_new`** (generic external-link glyph) +
    label "Talk". Not visually a WhatsApp control; VEN-S13 renders the equivalent as a dedicated
    WhatsApp `IconButton`. **Inconsistent presentation list ↔ detail.** Cosmetic. `Confident.`
  - No Close control, no avatar, no filter/search, no offer-count — all correct for the surface.

- **B. Functions**
  - Load: `GET /v1/me/connections?limit=&cursor=` (`connections_client.dart:12-28`), limit 20,
    controller **never sends `state`** — all connections in one stream, Active/Closed split
    client-side (`connections_screen.dart:96-101`).
  - Talk: guard `canOpenWhatsApp` → `openExternalUrl(conn.talk.waUrl)` (server-built `wa.me`, never
    assembled client-side) → on success only, `POST /v1/connections/{id}/contact-events {channel:"WHATSAPP"}`.
  - Row tap → `context.push('/vendor/connections/{id}')` (VEN-S13).
  - **F-1** Client reads `meta.hasMore` (`connections_client.dart:52`); backend emits only
    `meta.nextCursor` (`connection.service.ts:259`). Dead field. `Confident` (low impact).
  - **F-2** Backend key `offer` (flat) vs client `acceptedOffer` / nested `terms`; works only via a
    double fallback (`connection.dart:117-129, :251`). A presenter rename silently drops the row price.
    `Working hypothesis.`
  - **F-4** Row "connection date" uses `identityRevealedAt` — presenter emits no `createdAt`, model
    falls back (`connection.dart:248`). Mislabelled; near-always the same instant. `Near certain.`

- **C. Business Rules**
  - **Privacy rules intact:** connection rows exist only for `ACCEPTED` offers (reveal always
    post-acceptance → no BR-006 breach); scoping per-connection via `vendorProfileId` + accepted
    `offerId` (no BR-007 breach); vendor payload carries only the vendor's own offer + customer, no
    competitor identity/price/terms/count (no BR-008 breach); masked fields absent not null, separate
    `ConnectionForVendor` shape (NFR-013 OK). All `Confident.`
  - Authorization: no controller guard; `@Viewer()` throws `UNAUTHENTICATED` if absent; authz is
    data-scoped in the service (`where { vendorProfileId: <own> }`, `connection.repository.ts:146`);
    wrong role → `403 FORBIDDEN`. `Confident.`
  - **C-1 — Missing Close button + contradicting documents.** `FR-VEN-020` AC3
    (`Requirements-Spec-v1.3.md:1021-1030`) requires *each Connection* row to expose **both** Talk
    **and** Close. List renders only Talk + open-detail. Screen spec `VEN-S12.md:35` contradicts the
    SRS ("Close Connection available on detail"). Three-way inconsistency SRS ↔ screen spec ↔ code.
    `POST /connections/{id}/close` exists and works; just not surfaced here. **Decision needed:**
    (a) amend `FR-VEN-020` AC3 to delegate Close to VEN-S13 + record the resolution, or (b) add a
    Close affordance (swipe / row overflow) to the list. `Confident.`
  - **C-2 — Revealed-identity reads are not audit-logged.** `FR-VEN-021` AC4 / `FR-SYS-011` require
    every access to a revealed Customer phone number to be written to the audit log. `listMyConnections`
    returns `customer.displayName` **and `customer.phone` (full mobile)** per row
    (`connection.presenter.ts:242-248`) but never calls `auditWriter` (`connection.service.ts:241-277`).
    Only the one-time accept-time `IDENTITY_REVEALED` entry exists. Repeat list views leave no trace.
    Same root as VEN-S13 D5. **Fix shape:** append an audit entry when a presenter emits an unmasked
    phone — per read, or gate the phone behind the detail read and audit there. `Near certain.`
  - **C-3 — "Active first" not guaranteed across pages.** `FR-VEN-020` AC2. Server returns
    `createdAt desc` mixed (`connection.repository.ts:155`); client re-groups loaded pages only. With
    cursor pagination, page 2+ can carry ACTIVE rows that render below the already-drawn Closed
    section. `API-Route-Inventory.md:1464` already says the endpoint should default ACTIVE first.
    **Fix shape:** server-side `orderBy: [{ state }, { createdAt: 'desc' }]`, or two separately
    paginated lists. `Confident` on the mechanism; needs >1 page to trigger.
  - **C-4 (surface-area note, not a violation → Tech Debt).** `customer.phone` + full `talk` block
    (wa.me URL embedding the number, `tel:` URL) ship on **every row incl. CLOSED**, though the list
    only renders the name; `tel:`/`phone` populated even when `available:false`. Widens exposure
    surface, compounds C-2. `Near certain.`

- **D. Anything Else**
  - Routes: `/vendor/connections` (no params, deep-linkable). Entry: Dashboard "Active Connections"
    card + bottom-nav tab. Exit: row → VEN-S13; Talk → external WhatsApp.
  - States: loading / error (empty-only) / empty / data all covered.
  - **E-2 (lead)** Row + "Talk" button screen-reader semantics unverified; "Talk" gives no cue it
    launches WhatsApp / leaves the app. `Working hypothesis.`
  - **E-3 (lead)** Static-string i18n coverage unverified (sibling VEN-S14 has hard-coded English).
    `Working hypothesis.`
  - **E-4 (lead)** Not verified at tablet / wide-web width; rows have no max-width. `Working hypothesis.`
  - **Note only:** E-1 — no visible retry when a mid-list `loadNextPage` page fails (first-page load
    does have retry). Low severity.
  - **Note only:** Talk button visual identity (see A).

---

### VEN-S13 · Connection Detail & Unmasked Contact
- **Status**: ✅ Solved — Sherlock pass 2026-09-09, review-only. A ✅ / B ✅ / C ✅ / D ✅.
- **Spec**: `ui-screens/vendor/VEN-S13-connection-detail.md` · **SRS**: `FR-VEN-021`, `FR-VEN-022` · **Invariants**: `FR-CUS-024`, `BR-007`, `BR-008`, `NFR-016`, `NFR-017`, `C-02`, `C-03`, `BR-021`, `FR-SYS-011`
- **Note:** the earlier "Discrepancies 1–2 / Observations" that sat under this heading actually concerned
  **VEN-S08** (`request_detail_screen.dart`, `FR-VEN-010`) — they are tracked as leads **L1–L3** and
  the `markViewed` / `SpecificationGrid` observations moved to the register below. Cleared from here.
- **Design decisions carried from prior pass** (still stand): revealed customer card; direct WhatsApp
  "Talk" hub; read-only agreed-offer-terms breakdown; lifecycle actions (Close → review VEN-S19,
  Leave feedback, Report → VEN-S21); closed-state persistence via `ConnectionClosedBanner`.

- **A. Visible Components** — `Confident` (all split widget files read:
  `connection_widgets.dart`, `revealed_party_card.dart`, `offer_widgets.dart`).
  - List order: closed banner (if CLOSED) → `RevealedPartyCard` → `TalkButton` + fallback (if !closed)
    → request reference (bare text, no label) → "Accepted Offer terms" heading → `OfferTermsReadOnly`
    (if `acceptedOffer != null`) → "Identity revealed · {raw datetime}" → "Close Connection" (if
    !closed) → "Leave feedback" → "Report".
  - `RevealedPartyCard`: avatar initial, name, region (only if non-empty — **never arrives**),
    mobile chip + Copy, WhatsApp icon (if handler), Call icon (if handler), `TrustSignalBadge` (only
    if `rating != null || dealCount > 0`).
  - Spec fields **absent from the surface**: Customer Region, Platform tenure / "member since",
    Prior completed Connections count as a labelled line, Connection state ACTIVE/CLOSED as a field
    (only the closed banner exists).
  - Talk/WhatsApp rendered here as a dedicated WhatsApp `IconButton` — inconsistent with VEN-S12's
    `open_in_new` + "Talk" (lead L11).

- **B. Functions**
  - Load: `build(id)` → `GET /v1/connections/{id}`. Backend party check → 404 for non-party; vendor →
    `presentConnectionForVendor`; **admin → `presentConnectionForCustomer`** (see C-9).
  - Talk: guard `canOpenWhatsApp` → `openExternalUrl(conn.talk.waUrl)` (server-built `wa.me`) → on
    success `recordContactEvent('WHATSAPP')` → `POST /v1/connections/{id}/contact-events {channel}`.
  - Tap-to-call: `openExternalUrl(conn.talk.callUrl)` → on success `recordContactEvent('PHONE')`.
  - Copy: local clipboard, no network.
  - Close: confirm dialog → `close()` → `POST /v1/connections/{id}/close {reason?}` → backend sets
    `state=CLOSED, closedAt, closedBy` + enqueues outbox `connection.closed`; **409 `CONNECTION_CLOSED`**
    if already closed → on success `ref.invalidate(connectionsControllerProvider)` +
    `context.push('.../review')` (VEN-S19).
  - Leave feedback: direct `context.push('.../review')` — no state change, no guard (C-13).
  - Report: `context.push('/abuse/new?targetType=CONNECTION&targetId={id}')`.
  - **F-1** `getConnectionById` writes no audit entry on a revealed-contact read → same root as
    VEN-S12 C-2 / lead **L6**. `Confident.`
  - **F-2** `recordContactEvent` writes a domain `contactEvent` row, not an `AuditWriter` entry —
    interpretation-dependent whether that meets "access is audited". `Working hypothesis.`
  - **F-3** `closeConnection` hand-rolls the already-closed→409 guard; `connection-state-machine.ts`
    `transitionConnectionState` is dead code for this path. `Confident.`
  - **F-4** Close emits an outbox event but no audit entry — asymmetric with the audited accept-time
    reveal. `Working hypothesis.`
  - **F-5** "Leave feedback" and the post-close redirect share the `/review` destination with no
    distinction — VEN-S19's own guard against an ACTIVE connection is unverified. `Working hypothesis.`
  - **F-6** `close()` optimistically sets `AsyncData(updated)` from the close response; if that shape
    drifts from the get shape the screen could render half-populated post-close. Low risk. `Working hypothesis.`

- **C. Business Rules**
  - **Privacy intact:** party check → 404 for non-party (existence not leaked); reveal scoped to the
    connection and survives close (`FR-VEN-021` AC3); `identityRevealedAt` + the only `IDENTITY_REVEALED`
    audit entry stamped once in `acceptOffer`. No BR-008 breach (payload = own offer + customer only).
    C-03/NFR-017 compliant (`contact-events` stores channel enum + timestamp only; `wa.me` outbound,
    server-built). NFR-016 compliant (single-resource GET, no export). All `Confident.`
  - **C-1 — Customer Region never delivered.** Presenter omits `region` from `customer`
    (`connection.presenter.ts:78-87`); card reads `j['region']` (`party.dart:689`), never present.
    Customer-side presenter *does* include vendor region — asymmetric. **Fix:** add
    `region {code,name}` to the customer block in `presentConnectionForVendor`. `Confident.`
  - **C-2 — Platform tenure / "member since" entirely absent.** No payload field, no widget. **Fix:**
    emit `customer.memberSince` from `user.createdAt`; card renders "Member since {GST month/year}". `Confident.`
  - **C-3 — Prior completed Connections count not a labelled field.** `customer.connectionCount` sent
    but folded into `TrustSignalBadge` (hidden at 0-and-no-rating, never labelled,
    `revealed_party_card.dart:149`). **Fix:** render an explicit "N completed deals" line, always. `Near certain.`
  - **C-4 — Connection state not shown as a field.** Only the closed banner; no ACTIVE/CLOSED chip.
    **Fix:** add a `KhStatusChip` near the header (reuse VEN-S12's). `Confident.`
  - **C-5 — Revealed-contact views not audit-logged.** `getConnectionById` — no `AuditWriter.append`
    (`connection.service.ts:279-308`). Spec `:44` / `FR-VEN-021` AC4 / `FR-SYS-011`. `contact-events`
    is a domain table, not the audit log. **Same root as VEN-S12 C-2 → lead L6.** `Confident.`
  - **C-6 — `identityRevealedAt` rendered with raw `DateTime.toLocal().toString()`**
    (`connection_detail_screen.dart:180`). No `DateFormat`; device zone, not GST → violates
    `BR-021` / `C-02`. **Fix:** format via the app's GST formatter. `Confident.`
  - **C-7 — Accepted Offer terms incomplete vs spec "full".** `offer` object omits `weightGrams`, so
    `OfferTermsReadOnly` never shows the "Gold weight" row; no supporting media shown. **Fix:** add
    `weightGrams` to the `offer` payload block; decide whether offer attachments belong here. `Near certain.`
  - **C-8 — `talk.phone` / `talk.callUrl` populated even when CLOSED** (`connection.presenter.ts:152-154`);
    only `available` flips false. UI safe only because Flutter gates on `!closed`. **Same family as
    VEN-S12 C-4 → lead L8.** `Confident.`
  - **C-9 — ADMIN reads a vendor connection via `presentConnectionForCustomer`**
    (`connection.service.ts:303-305`) regardless of context — admin sees the customer view (vendor
    identity revealed to admin). Probably intentional for support, but undocumented vs
    `FR-CUS-024` / `BR-007`. **Fix:** confirm intent in an ADR note, or add an admin presenter. `Near certain.`
  - **C-10 (note)** `closeConnection` bypasses the state machine (F-3) — divergence risk, not a live bug.
  - **C-11 (note)** Close emits an outbox event but no audit entry (F-4).
  - **C-12 (lead)** No placeholder when `acceptedOffer` / `request` is null — the section vanishes.
  - **C-13 (lead)** "Leave feedback" reachable for an ACTIVE, un-closed connection (F-5).

- **D. Anything Else**
  - Routes: `/vendor/connections/:connectionId`; child `.../review` (VEN-S19). Entry: VEN-S12 row +
    Dashboard card. Exits: WhatsApp, `tel:`, `/review`, `/abuse/new`. Deep-linkable; bad/non-party id
    → 404 → error view.
  - States: loading spinner / error view + retry / data. No true empty state (a detail can't be empty);
    null sub-sections vanish (C-12); no 404-specific copy.
  - **E-2 (note)** After Close, the screen navigates away to `/review` rather than re-rendering in
    closed state — the `ConnectionClosedBanner` path is only seen on a later return. Minor seam.
  - **E-3 (lead)** Not verified at tablet / wide-web or 320 px — mobile chip + Copy + WhatsApp + Call
    in one `Row` could crowd.
  - **E-4 (lead)** a11y: mobile number is a run-on `e164` string with no "phone number" role;
    Copy / WhatsApp / Call `IconButton`s need semantic labels confirmed (keys ≠ labels).
  - **E-5 (lead)** "Identity revealed · {raw datetime}" also reads badly to a screen reader (C-6).
  - **E-6 (lead)** Confirm "Accepted Offer terms" heading, "Leave feedback", "Report",
    "Identity revealed ·" prefix are `l10n` keys, not inline literals.

- **Observations carried from the old (mislabelled) block — belong to VEN-S08, tracked as leads:**
  - `repo.markViewed(arg)` fire-and-forget in `request_detail_controller.dart` → lead **L3**.
  - `SpecificationGrid` shows `requestType`/`direction` as raw `replaceAll('_',' ')` text, not
    localised labels — cosmetic, matches feed card behaviour. → note under L2/L3 family.
  - **VEN-S12 E-1** — no visible retry when a mid-list `loadNextPage` page fails. Low severity.

---

## Open Leads & Technical Debt (Sherlock pass, 2026-09-09)

| # | Lead | Origin unit | Owner surface | Confidence |
|---|---|---|---|---|
| L1 | `VendorRequestItem` drops the `myOffer` object the backend already returns on `GET /v1/requests/{id}`; blocks the `FR-VEN-010` AC4 "View / Revise Offer" branch on VEN-S08. | VEN-S08 | `packages/kh_domain`, `packages/kh_api`, `request_detail_screen.dart` | Confident |
| L2 | Publication time (`publishedAt`) fetched + parsed but never rendered on VEN-S08. | VEN-S08 | `request_detail_screen.dart` | Confident |
| L3 | `markViewed` is fire-and-forget; failed call desyncs dashboard New-Requests count silently. | VEN-S08 | `request_detail_controller.dart` | Near certain |
| L4 | Server error codes on Offer submit (`OFFER_ALREADY_PENDING`, contact-detail rejection, `NOT_IN_MATCH_SET`, subscription-missing) all surface as raw `failure.code` text with no localized copy and — for `OFFER_ALREADY_PENDING` — no route to the existing Offer. | VEN-S09 | `submit_offer_controller.dart`, `submit_offer_screen.dart`, `kh_l10n` | Near certain |
| L5 | **C-1** — VEN-S12 list has no Close Connection action; `FR-VEN-020` AC3 requires it on every row, but screen spec `VEN-S12.md:35` says Close lives on detail. Docs contradict each other; code follows the spec. Needs a spec-authority decision, then align the other document (± add list affordance). | VEN-S12 | `Requirements-Spec-v1.3.md` §FR-VEN-020, `ui-screens/vendor/VEN-S12-connections-list.md`, `connections_screen.dart` | Confident |
| L6 | **C-2 / VEN-S13 D5** — revealed Customer phone views are not written to the audit log (`FR-VEN-021` AC4 / `FR-SYS-011`). `listMyConnections` and `getConnectionById` return `customer.phone` but never call `auditWriter`; only accept-time `IDENTITY_REVEALED` is logged. | VEN-S12, VEN-S13 | `backend/src/modules/connections/application/connection.service.ts`, `presenter/connection.presenter.ts` | Near certain |
| L7 | **C-3** — "active first" (`FR-VEN-020` AC2) only holds for loaded pages; server sorts `createdAt desc`, client re-groups. Later cursor pages can render ACTIVE rows below the Closed section. Fix: server-side `orderBy [{state},{createdAt desc}]` or two paginated lists. | VEN-S12 | `connection.repository.ts:155`, `connections_controller.dart` | Confident (needs >1 page) |
| L8 | **C-4** — vendor connection payload ships `customer.phone` + full `talk` block (wa.me URL with number, `tel:` URL) on every row incl. CLOSED and when `available:false`; list only needs the name. Over-broad exposure surface; compounds L6. | VEN-S12, VEN-S13 | `connection.presenter.ts:242-267` | Near certain |
| L9 | **F-1** — client reads `meta.hasMore` on `GET /v1/me/connections`; backend never sends it. Dead field. **F-2** — payload key `offer`(flat) vs client `acceptedOffer`/nested `terms`; works only via a double fallback, fragile to a presenter rename. **F-4** — row "connection date" actually uses `identityRevealedAt` (no `createdAt` in payload). | VEN-S12 | `connections_client.dart:52`, `connection.dart:117-129/:248`, `connection.service.ts:259` | F-1 Confident / F-2 Working hypothesis / F-4 Near certain |
| L10 | **E-2 / E-3 / E-4** — VEN-S12: row + "Talk" button screen-reader semantics unverified and "Talk" gives no WhatsApp/leaves-app cue; static-string i18n coverage unverified (sibling VEN-S14 has literals); not verified at tablet/wide-web width (rows have no max-width). | VEN-S12 | `connections_screen.dart`, `connection_widgets.dart` | Working hypothesis |
| L11 | **Cosmetic** — Talk/WhatsApp control renders as `Icons.open_in_new` + "Talk" on VEN-S12 but as a dedicated WhatsApp `IconButton` on VEN-S13. Inconsistent presentation of the same action. | VEN-S12, VEN-S13 | `connection_widgets.dart`, `revealed_party_card.dart` | Confident |
| L12 | **VEN-S13 C-1/C-2/C-3/C-4** — spec fields not delivered on the detail: Customer Region (presenter omits `customer.region`), Platform tenure / "member since" (no field/widget), Prior completed Connections count as a labelled line (folded into `TrustSignalBadge`, hidden at 0), Connection state ACTIVE/CLOSED as a field (only the closed banner). | VEN-S13 | `connection.presenter.ts` (customer block), `revealed_party_card.dart`, `connection_detail_screen.dart` | C-1/C-2/C-4 Confident, C-3 Near certain |
| L13 | **VEN-S13 C-6** — `identityRevealedAt` rendered with raw `DateTime.toLocal().toString()` (`connection_detail_screen.dart:180`) — no `DateFormat`, device zone not GST. Violates `BR-021` / `C-02`; also poor for screen readers (E-5). | VEN-S13 | `connection_detail_screen.dart` | Confident |
| L14 | **VEN-S13 C-7** — `offer` payload block omits `weightGrams`, so the "Gold weight" row never renders in `OfferTermsReadOnly` despite spec "Accepted Offer terms — full"; no supporting media shown. | VEN-S13 | `connection.presenter.ts` (offer block), `offer_widgets.dart` | Near certain |
| L15 | **VEN-S13 C-9** — ADMIN reading a vendor connection is always routed through `presentConnectionForCustomer` (`connection.service.ts:303-305`), exposing vendor identity to admin, undocumented vs `FR-CUS-024` / `BR-007`. Confirm intent in an ADR note or add an admin presenter. | VEN-S13 | `connection.service.ts` | Near certain |
| L16 | **VEN-S13 F-3 / C-10** — `closeConnection` hand-rolls the already-closed→409 guard; `domain/connection-state-machine.ts::transitionConnectionState` is dead code for this path. Divergence risk. Also **F-4 / C-11**: close emits outbox `connection.closed` but no audit entry (asymmetric with the audited reveal). | VEN-S13 | `connection.service.ts`, `domain/connection-state-machine.ts` | Confident (F-3) / Working hypothesis (F-4) |
| L17 | **VEN-S13 C-12 / C-13 / F-5** — no placeholder when `acceptedOffer`/`request` is null (section vanishes); "Leave feedback" reachable for an ACTIVE un-closed connection (shares `/review` with the post-close redirect, VEN-S19 guard unverified). | VEN-S13 | `connection_detail_screen.dart`, VEN-S19 review screen | Working hypothesis |
| L18 | **VEN-S13 E-3 / E-4 / E-6** — not verified at tablet/wide-web or 320 px (mobile chip + Copy + WhatsApp + Call in one `Row`); a11y: `e164` run-on with no phone role, icon buttons need semantic labels; confirm "Accepted Offer terms" heading / "Leave feedback" / "Report" / "Identity revealed ·" are `l10n` keys not literals. | VEN-S13 | `revealed_party_card.dart`, `connection_detail_screen.dart` | Working hypothesis |
| — | Carried from VEN-S02: extract a normalised `Contact` entity for CRM sync. | VEN-S02 | backend domain | — |
| — | Carried from VEN-S04: migrate vendor token storage `flutter_hive` → secure storage. | VEN-S04 | `auth` feature | — |

**Resolved during this pass (were suspected discrepancies, found already handled):**
- Offer validity option set — backend pins `[12, 24, 48]` (`offer-validator.ts`, `platform-config.query.ts` L27, DB check constraint `offer_validity_hours_allowed`), matching `FR-VEN-013`; the SRS §6.2 `24/48/72/168` list is explicitly marked stale (`partial-indexes.sql` L15–16, `AD-API-07`). Client reads the set from platform config — not hard-coded. **No action.**
- `BR-022` contact-detail scan on the Offer note — enforced server-side via `assertNoContactDetails(input.vendorNote)` in `offer.service.ts` L102. Client copy ("Note (no contact details)") is adequate; no client gate required. **No action.**

# Vendor Screen-by-Screen Review Notes & Todos

## Screen Progress & Notes

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
- **Status**: 🟡 In Review
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
- **Discrepancies / Feedback**: [In Progress]

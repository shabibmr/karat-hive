# Admin Backend Follow-up — Task Register

> **Moved from** [`Admin-App-Completion-Tasks.md`](Admin-App-Completion-Tasks.md) on 8 Sep 2026.
> Admin Flutter workarounds stay in `apps/kh_admin` until these land; this register is **backend-only**.
> **Plan of record (gaps)**: [`Admin-App-Completion-Plan.md`](Admin-App-Completion-Plan.md) §5.
> **Prefix**: `ADM-C-70`–`ADM-C-76` (stable; never reused). Raise as `G2-*` when that backlog is next amended.
> **Does not override** SRS v1.3 · `API-Route-Inventory.md` · `Physical-Data-Model.md`.

Legend: `[x]` done · `[~]` in progress · `[ ]` not started

Suggested order: **74 → 72 → 73 → 71 → 70 → 75 → 76**.

---

## Envelope and list filters

- [x] **ADM-C-70** Admin list routes double-wrap the envelope — fix `admin.controller.ts` (and any split admin list controllers) to return `{ data: items, meta: { nextCursor } }` like the customer controllers; then simplify `ApiClient.getCollection`.
  - **Files**: `backend/src/modules/admin/controller/admin.controller.ts` (and `admin-requests.controller.ts` if it shares the wrap); Flutter follow-up `apps/kh_admin/lib/core/api/api_client.dart` `getCollection`.
  - **Accept**: list responses are `{ data: [...], meta: { nextCursor } }`; `meta.nextCursor` is the real cursor; admin lists still page. Flutter may then drop the double-unwrap branch.

- [x] **ADM-C-71** `listRequests` / `listOffers` — add the filter params the screens need (`requestType`, `direction`, `categoryId`, `regionId`, price/value ranges, `zeroOffers`).
  - **Files**: `backend/src/modules/admin/controller/admin.controller.ts`, `admin.service.ts`, `admin.repository.ts` / `admin-requests.repository.ts`; inventory §21.4 / §21.5 if a param is new.
  - **Accept**: `GET /v1/admin/requests` and `GET /v1/admin/offers` honour those query params server-side. Admin Flutter can stop client-side filtering of the loaded page (`ADM-FE-P02`).
  - **Note (8 Sep 2026):** Server filters land on the live `AdminController`. Flutter list repos still client-filter the loaded page until they send the new query params.

## Detail payloads

- [x] **ADM-C-72** Request detail — include `matchedVendors`, a state timeline, and deep `connections` (nested vendor/customer).
  - **Files**: admin request detail path in `admin.service.ts` / `admin.repository.ts` (or `admin-requests.*`).
  - **Accept**: `GET /v1/admin/requests/:id` populates the ADM-S09 sections that today render empty with `TODO(backend)`.

- [x] **ADM-C-73** Offer detail — expose state transitions; give `OfferRevision` real columns or a typed projection.
  - **Files**: admin offer detail path in `admin.service.ts` / `admin.repository.ts`.
  - **Accept**: `GET /v1/admin/offers/:id` includes `stateTransitions`; revisions are not only a `previousTerms` JSON blob.

## Media, notes, exports

- [x] **ADM-C-74** Signed / public media URL for admin document view (current `/v1/media/<key>` needs a bearer a new tab can't send).
  - **Files**: media URL issuance used by `GET /v1/admin/vendors/:id/documents/:docId/url`; object-storage adapter.
  - **Accept**: admin can open a KYC/document URL without attaching `Authorization` in the new tab (time-limited signed URL or equivalent). Access remains audited.

- [x] **ADM-C-75** `admin_note` create response — return `author:{displayName}` to match the list shape.
  - **Files**: note-create handlers on requests / offers / connections / customers.
  - **Accept**: `POST …/notes` 200 body includes `author: { displayName }` like `GET …/notes`. Flutter can stop synthesising the author.

- [x] **ADM-C-76** Export download bytes — `GET /v1/admin/exports/:id` returns `downloadUrl: /v1/admin/exports/:id/download` but that route does not exist. Split out from ADM-C-63 leftover (Flutter CSV fallback).
  - **Files**: `admin.controller.ts` `getExport` / new download action; `ExportJob` storage.
  - **Accept**: polling `GET /v1/admin/exports/:id` then `GET` the `downloadUrl` yields CSV/XLSX/PNG (or a documented 501 for PNG until chart export exists). Watermark + audit (`NFR-016`) stay on the job.

---

## Out of this register

- Gold-rate config (ADM-S20 / withdrawn ADM-C-60, ADM-C-61) — Yahoo Finance redistribution terms still open.
- Admin Flutter screens, URL filters, dashboard queues, reports UI — [`Admin-App-Completion-Tasks.md`](Admin-App-Completion-Tasks.md).

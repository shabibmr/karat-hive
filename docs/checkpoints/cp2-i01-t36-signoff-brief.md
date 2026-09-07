# CP2-I01 — Technical Lead sign-off brief: `T36` schema deltas

| | |
|---|---|
| **Product** | Karat Hive |
| **Task** | `CP2-I01` — escalate `T36` for Technical Lead sign-off |
| **Status** | Escalation artifact ready — **TL approval still required** |
| **Date** | 7 September 2026 |
| **Authority** | Extracted only from cited docs. **No invented columns or indexes.** |
| **Do not revert** | Columns already land in `backend/prisma/migrations/20260901120000_init` and remain `[PROPOSED]` (`Physical-Data-Model.md` T36 status note; `Backend-Gap-Fix-Plan.md` D02; `Backend-Implementation-Plan.md` T36 row) |

**Ask.** Approve or reject each item below so CP-3 can treat `T36` as signed and apply / freeze the schema (`CP3-A01`). Until then, jobs gated on these markers stay blocked.

---

## 1. Proposed columns / enum changes

### A. From `Async-Contract.md` §10 (`AD-ASYNC-07`, `AD-ASYNC-08`)

| # | Change | Source | Unblocks |
|---|---|---|---|
| 1 | `notification_delivery.channel` → enum `NotificationChannel`; `.status` → enum `NotificationDeliveryStatus` (`AD-ASYNC-07`) | Async-Contract §10 #1; closes Physical-Data-Model §8 open encoding | `T38` notification-retry job (`FR-SYS-008.3`); CP-5 notification path |
| 2 | `offer.expiry_warned_at timestamptz NULL` | Async-Contract §10 #2; `FR-VEN-013` AC4 | **`T41` / `CP3-A06`** offer-expiry-warning job (`offer.expiry.warning`) |
| 3 | `request.draft_purge_warned_at timestamptz NULL` | Async-Contract §10 #3; `FR-CUS-015` AC4 | **`T42`** draft-purge job (`request.draft.purge_warning`) |
| 4 | `vendor_document.reminder_sent_at timestamptz NULL` | Async-Contract §10 #4; `FR-VEN-002` AC4 | **`T44` / CP5-A09** vendor-document-expiry job (`vendor.document.expiring`) |
| 5 | Announcement dispatch guard — **choose one**: keep predicate `dispatch_stats IS NULL`, **or** add `announcement.dispatched_at timestamptz NULL` | Async-Contract §10 #5; `FR-ADM-029` | **`T43`** announcement-dispatch job (`announcement.scheduled`) |
| 6 | *(docs only)* Document `outbox_consumer` in Architecture Appendix C and Physical-Data-Model Appendix A — no column change | Async-Contract §10 #6 | Doc hygiene; not a migration blocker |
| 7 | *(no change)* `request_match.is_eligible` already exists — recorded for `matching:eligibility-recompute` | Async-Contract §10 #7 | — |

### B. From `Screen-API-Map.md` (`SAM-GAP` column resolutions folded into `T36`)

| Gap | Change | Source | Unblocks |
|---|---|---|---|
| `SAM-GAP-1` | `offer.viewed_by_customer_at timestamptz NULL` (+ `unreadOfferCount` / `viewedByCustomerAt` on Customer presenters, or `POST /v1/offers/{id}/viewed`) | Screen-API-Map §6; Backend-Implementation-Plan P0 / T22 | CUS-S02 / CUS-S11 unread-Offer marker |
| `SAM-GAP-4` | Widen `AbuseEntityType` with `VENDOR` \| `CUSTOMER` | Screen-API-Map §6; cheapest before freeze | CUS-S22 / VEN-S21 (and related) report-entity coverage; CP-5 abuse |
| `SAM-GAP-6` | `vendor_profile.verification_message text NULL` (Vendor-facing; distinct from internal notes) | Screen-API-Map §6 | VEN-S03 “request more information” copy on `VendorMe` |
| `SAM-GAP-8` | `vendor_profile.rating_trend jsonb NULL` — shape proposed in Physical-Data-Model §8 as `[{ period, average, count }]` | Screen-API-Map §6; Physical-Data-Model §4 / §8 | VEN-S20 6-month rating trend (`FR-SYS-012` worker) |

`SAM-GAP-3` is a **presenter join only** (`connectionId?` when Request is `ACCEPTED`) — **no column**. Listed so it is not mistaken for a `T36` schema item.

---

## 2. Four partial indexes (Async-Contract §10)

Prisma cannot express these — they belong in `backend/prisma/sql/partial-indexes.sql` (Physical-Data-Model §7). Exact SQL from Async-Contract §10:

| Index | Definition | Job that scans it |
|---|---|---|
| `offer_expiry_warn` | `ON offer (expires_at) WHERE state = 'PENDING' AND expiry_warned_at IS NULL` | `offer-expiry-warning` (**`T41`**) |
| `request_draft_age` | `ON request (created_at) WHERE state = 'DRAFT'` | `request-draft-purge` (**`T42`**) |
| `vendor_doc_expiry` | `ON vendor_document (expiry_date) WHERE reminder_sent_at IS NULL` | `vendor-document-expiry` (**`T44`**) |
| `announcement_due` | `ON announcement (scheduled_for) WHERE cancelled_at IS NULL AND dispatch_stats IS NULL` | `announcement-dispatch` (**`T43`**) — predicate assumes §10 #5 keeps `dispatch_stats IS NULL`; revisit if `dispatched_at` is chosen instead |

---

## 3. CP / task unblock map (Vendor register)

| After TL approval | Immediate consumer |
|---|---|
| `CP3-A01` | Apply / freeze `T36` columns + four indexes (sign-off prerequisite) |
| `CP3-A06` / `T41` | Offer expiry warning + sweep path for CP-3 Bid |
| `T42` | Draft purge (Customer path; still needs the column) |
| `T43` | Announcement dispatch (Admin) |
| `T44` / CP5-A09 | Vendor document expiry reminder |
| `T38` | Notification retry (enums from §10 #1) |
| CP-5 gate | “`T36` columns applied” (`Vendor-App-Completion-Tasks.md` Gates) |

---

## 4. Technical Lead checklist — Approve / Reject

Tick one per row. Comments go in the Notes column.

### Async-Contract §10

| Item | Approve | Reject | Notes |
|---|:---:|:---:|---|
| §10 #1 `NotificationChannel` / `NotificationDeliveryStatus` enums | ☐ | ☐ | |
| §10 #2 `offer.expiry_warned_at` | ☐ | ☐ | Gates **T41** |
| §10 #3 `request.draft_purge_warned_at` | ☐ | ☐ | Gates **T42** |
| §10 #4 `vendor_document.reminder_sent_at` | ☐ | ☐ | Gates **T44** |
| §10 #5a Keep `dispatch_stats IS NULL` as dispatch guard (no new column) | ☐ | ☐ | Mutually exclusive with #5b |
| §10 #5b Add `announcement.dispatched_at` instead | ☐ | ☐ | Mutually exclusive with #5a; update `announcement_due` predicate if chosen |
| §10 #6 Document `outbox_consumer` in Architecture + Physical-Data-Model appendices | ☐ | ☐ | Docs-only |
| Index `offer_expiry_warn` | ☐ | ☐ | |
| Index `request_draft_age` | ☐ | ☐ | |
| Index `vendor_doc_expiry` | ☐ | ☐ | |
| Index `announcement_due` (as written, or revised for #5b) | ☐ | ☐ | |

### SAM-GAP column set

| Item | Approve | Reject | Notes |
|---|:---:|:---:|---|
| `SAM-GAP-1` `offer.viewed_by_customer_at` | ☐ | ☐ | Presenter / `POST …/viewed` shape can follow in T22 |
| `SAM-GAP-4` `AbuseEntityType` += `VENDOR`, `CUSTOMER` | ☐ | ☐ | |
| `SAM-GAP-6` `vendor_profile.verification_message` | ☐ | ☐ | |
| `SAM-GAP-8` `vendor_profile.rating_trend` jsonb + PDM shape `[{ period, average, count }]` | ☐ | ☐ | Shape is PDM `[PROPOSED]`, not fixed by Screen-API-Map |

### Process

| Item | Approve | Reject | Notes |
|---|:---:|:---:|---|
| Leave accepted items in init / catch-up migrations; **do not rewrite** frozen init (`D02`) | ☐ | ☐ | |
| On full approval, flip `T36` / Async-Contract §10 / relevant `AD-ASYNC-*` from `[PROPOSED]` → accepted in the owning docs | ☐ | ☐ | Follow-up doc hygiene after this brief |

**Sign-off**

| Role | Name | Decision (Approve all / Approve with notes / Reject) | Date |
|---|---|---|---|
| Technical Lead | | | |

---

## 5. References (read order)

1. `docs/Async-Contract.md` §10 (columns + four indexes), Appendix B (TL pending)
2. `docs/Screen-API-Map.md` §6 (`SAM-GAP-1`, `4`, `6`, `8`)
3. `docs/Backend-Implementation-Plan.md` — P0 “Before item 1 — T36”; task table T36 / T41–T44
4. `docs/Physical-Data-Model.md` — T36 status note; §4 encoding rows; §7 partial indexes; §8 `rating_trend` shape
5. `docs/Backend-Gap-Fix-Plan.md` D02 (columns in init without TL sign-off; remain `[PROPOSED]`)
6. `docs/Vendor-App-Completion-Tasks.md` — `CP2-I01`, `CP3-A01`, `CP3-A06`, Gates
)

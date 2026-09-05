# Karat Hive — Physical Data Model

| | |
|---|---|
| **Product** | Karat Hive — Digital Jewellery Marketplace |
| **Document** | Physical PostgreSQL schema (pre-code) |
| **Version** | 0.2 |
| **Status** | Draft — `[PROPOSED]`. Assumes `AD-BE-05` (Prisma). Table/constraint/index design survives a DSL change. |
| **Date** | 1 September 2026 |
| **Encoding** | [`backend/prisma/schema.prisma`](../backend/prisma/schema.prisma) |
| **SQL Prisma cannot express** | [`backend/prisma/sql/`](../backend/prisma/sql/) |
| **Source of truth** | SRS v1.3 §5–§6 → Architecture-Backend §12 + Appendix B/C → [API-Route-Inventory](API-Route-Inventory.md). T36 deltas from [Async-Contract §10](Async-Contract.md) and [Screen-API-Map §6](Screen-API-Map.md) |

This is **not** OpenAPI and **not** Nest. Identity masking is a presenter concern (`FR-SYS-003`): the database stores full identity.

**T36 status.** The SAM-GAP and Async-Contract §10 columns (`offer.viewed_by_customer_at`, `vendor_profile.verification_message`, `AbuseEntityType` + `VENDOR`/`CUSTOMER`, `expiry_warned_at`, `draft_purge_warned_at`, `vendor_document.reminder_sent_at`, and the matching partial indexes) are already in `prisma/migrations/20260901120000_init`. They remain **`[PROPOSED]`** until Technical Lead sign-off. They are not reverted; a follow-up migration would be noisier than leaving them in the unused init.

---

## 1. Conventions

Copied from Architecture-Backend §12.2, with one resolved tension:

| Convention | Rule |
|---|---|
| Keys | UUID, `gen_random_uuid()` at DB until the app issues UUID v7 |
| Naming | `snake_case`, **singular** table names matching SRS §6 (`user`, `request`, `offer`) |
| Timestamps | `timestamptz` UTC (`BR-021`) |
| Money | `numeric(12,2)` AED. Never float |
| Weight | **`numeric(10,2)` grams** — SRS §6.2, not Architecture’s `numeric(9,3)` |
| Enums | PostgreSQL enums for the four state machines |
| Soft state | No generic `deleted_at` except `user.deleted_at` (PDPL). Taxonomy uses `is_active` (`BR-019`) |
| Bytes | Object storage. PostgreSQL holds keys on `media` |

`user` is a PostgreSQL reserved word; Prisma quotes it.

---

## 2. Vendor lifecycle mapping (SRS §5.4)

SRS puts verification and marketplace access on one diagram. Physically they are two columns:

| Concept | Column | Values |
|---|---|---|
| Credentials | `vendor_profile.verification_state` | `REGISTERED`, `PENDING_VERIFICATION`, `VERIFIED`, `REJECTED` |
| Marketplace access | `user.account_state` | `ACTIVE`, `SUSPENDED`, `DEACTIVATED` |

A Vendor may see matched Requests and submit Offers only when `verification_state = VERIFIED` **and** `account_state = ACTIVE` **and** an `ACTIVE`/`GRACE` Type Subscription exists for that Request type (`BR-002`, `FR-VEN-031`). The Awaiting-Approval shell is every other combination that is still allowed to authenticate (`FR-VEN-003`).

Customers and Admins use `user.account_state` only.

---

## 3. Table ownership

SRS §6 entities plus Architecture Appendix C (`*`) plus inventory extras (`†`).

| Module | Tables |
|---|---|
| `identity` | `user`, `customer_profile`, `admin_profile`, `refresh_token`*, `otp_challenge`*, `oauth_binding`†, `device`† |
| `vendor-onboarding` | `vendor_profile`, `vendor_document` |
| `subscription` | `vendor_type_subscription` |
| `taxonomy` | `category`, `region`, `vendor_category`, `vendor_region` |
| `media` | `media`† |
| `requests` | `request`, `request_media` |
| `matching` | `request_match` |
| `offers` | `offer`, `offer_revision`, `offer_media`†, `filter_preset`† |
| `connections` | `connection`, `contact_event` |
| `reviews` | `review` |
| `abuse` | `abuse_report` |
| `notifications` | `notification`, `notification_delivery`*, `notification_preference`† |
| `gold-rate` | `gold_rate` |
| `audit` | `audit_log` |
| `settings` | `platform_setting` |
| `admin` | `admin_note`†, `announcement`†, `export_job`† |
| `outbox` | `outbox_event`*, `outbox_consumer`*, `job_lock`* |
| `edge` | `idempotency_key`*, `rate_limit_bucket`* |
| PDPL | `data_subject_request`* |

`admin` still has no owned domain tables for lists — it reads through named query views later (Architecture §7.3 exception). Notes / announcements / exports are the Admin-write surface.

Legacy `vendor_profile.subscription_tier_id` from SRS §6.2 is **omitted**. Entitlement is `vendor_type_subscription` only (`FR-VEN-031`, `AD-API-04`).

---

## 4. Gaps vs SRS §6.1 / §6.2

| Gap | Resolution |
|---|---|
| `ADMIN_PROFILE` has no field dictionary | `[PROPOSED]`: `display_name`, encrypted TOTP secret, `totp_confirmed_at`. **No `role`** (`AD-API-03`) |
| Vendor ↔ Category / Region M:N unnamed | `vendor_category`, `vendor_region` |
| Upload-intent pipeline has no entity | `media` holds object keys; `request_media` / `offer_media` / `vendor_document` attach them |
| SRS `photo_url` / `logo_url` / `file_url` | Replaced by FKs to `media`. Signed URLs are issued at read time (`NFR-014`) |
| Offer images (FR-VEN-012, up to 3) | `offer_media` |
| Infrastructure tables | Architecture Appendix C, encoded as `*` above |
| API inventory persistence | `oauth_binding`, `device`, `filter_preset`, `admin_note`, `announcement`, `export_job`, `notification_preference` |
| Gemstones (FR-CUS-008) | `request.gemstones` jsonb `[PROPOSED]` |
| Expiry warning once | `request.expiry_warned_at` (Architecture §11.3) |
| `platform_setting.requires_super_admin` | Renamed `requires_confirmation` (`AD-API-03`) |
| Scheduled-job "warned once" markers (`AD-ASYNC-08`) | `offer.expiry_warned_at`, `request.draft_purge_warned_at`, `vendor_document.reminder_sent_at` — all `timestamptz NULL`, set on first fire (Async-Contract §10 #2–#4) |
| `notification_delivery.channel` / `.status` free text | Enums `NotificationChannel` / `NotificationDeliveryStatus` (`AD-ASYNC-07`) |
| Vendor-facing "request more information" text (`SAM-GAP-6`) | `vendor_profile.verification_message` text `NULL` — distinct from internal `verification_notes` |
| Unread-Offer marker (`SAM-GAP-1`) | `offer.viewed_by_customer_at` timestamptz `NULL` |
| `AbuseEntityType` cannot name a Vendor / Customer (`SAM-GAP-4`) | Enum widened with `VENDOR`, `CUSTOMER`; `entity_id` stays polymorphic (no FK) |
| 6-month rating trend for VEN-S20 (`SAM-GAP-8`) | `vendor_profile.rating_trend` jsonb `NULL` `[PROPOSED]` — worker-maintained (`FR-SYS-012`), not read-time; shape is this model's choice, not fixed by Screen-API-Map |

---

## 5. Database-enforced business rules

| Rule | Constraint |
|---|---|
| `BR-009` one pending Offer per Vendor per Request | Partial unique `offer (request_id, vendor_profile_id) WHERE state = 'PENDING'` |
| `BR-011` at most one accepted Offer per Request | `request.accepted_offer_id` unique |
| `BR-012` one Connection per accepted Offer | `connection.offer_id` unique |
| `BR-017` one review per party per Connection | unique `(connection_id, author_type)` |
| One profile per user | `customer_profile.user_id` / `vendor_profile.user_id` / `admin_profile.user_id` unique |
| Fan-out retry harmless (`FR-SYS-001.4`) | unique `(request_id, vendor_profile_id)` on `request_match` |
| One live Type Subscription per type | Partial unique `WHERE state IN ('ACTIVE','GRACE')` |
| Taxonomy in use | FKs `ON DELETE RESTRICT` from `request` / link tables; deactivate instead of delete (`BR-019`) |
| Audit survives user erasure | `audit_log.actor_user_id` `ON DELETE SET NULL`; no `updated_at` |
| Contact content never stored (`NFR-017`) | `contact_event` has channel + time only |

**Not** enforced in the database (application / presenters):

- XOR: exactly one of customer/vendor/admin profile, matching `user.user_type`
- Max 5 request images / 3 offer images
- Masking (`FR-SYS-003`)
- Offer validity clamp vs parent Request remaining life
- Acceptance lock order (`SELECT … FOR UPDATE` of `request`, `AD-BE-09`)

---

## 6. Hot-path indexes (Architecture §12.5)

| # | Query | Index |
|---|---|---|
| 1 | Vendor Available Requests | `request_match (vendor_profile_id, matched_at DESC)` plus `(vendor_profile_id, is_eligible, viewed_at)` |
| 2 | Customer Offers on a Request | `offer (request_id, state, submitted_at DESC)` |
| 3 | Vendor My Offers | `offer (vendor_profile_id, state, submitted_at DESC)` |
| 4 | Admin lists | `request (state, published_at)`, `vendor_profile (verification_state, created_at)`, `user (account_state, created_at)` — replica routing is later |
| 5 | Expiry sweeps | Partial `offer (expires_at) WHERE state = 'PENDING'`; partial `request (expires_at) WHERE state IN ('PUBLISHED','OFFERS_RECEIVED')` |
| 6 | Fan-out eligibility | `vendor_profile (verification_state, created_at)`; `vendor_category (category_id, vendor_profile_id)`; `vendor_region (region_id, vendor_profile_id)`; `vendor_type_subscription (request_type, state)` |

Search (`AD-BE-11`, C-12): `pg_trgm` GIN on `request.notes`, `request.reference`, `vendor_profile.trading_name`, `legal_business_name`, `trade_licence_number`, `user.mobile_number` — see `prisma/sql/extensions.sql`.

`request_match` is a partitioning candidate by time if it approaches 100 M rows (Architecture §12.4). **Not** partitioned in v1.

---

## 7. What Prisma cannot express

Applied from [`backend/prisma/sql/partial-indexes.sql`](../backend/prisma/sql/partial-indexes.sql) and [`extensions.sql`](../backend/prisma/sql/extensions.sql) as a follow-up SQL migration after `prisma migrate`:

- Partial unique indexes (`BR-009`, live subscriptions)
- Partial expiry indexes
- `CHECK (validity_hours IN (12, 24, 48))`
- `CREATE EXTENSION pg_trgm` / `pgcrypto`
- GIN trgm indexes
- Outbox claim partial index
- Scheduled-job scan indexes (`AD-ASYNC-08`): `offer_expiry_warn`, `request_draft_age`, `vendor_doc_expiry`, `announcement_due` (Async-Contract §10)

Until that SQL runs, those rules exist only in application code — **do not ship a migrate that skips the SQL files**.

---

## 8. Open encodings

| Item | Encoding in this schema | Status |
|---|---|---|
| Offer validity options | `CHECK (12, 24, 48)` (`AD-API-07`, `FR-VEN-013`) | `[PROPOSED]` vs SRS §6.2 `24/48/72/168` |
| Admin roles Super/Ops/Analyst | Omitted (`AD-API-03`) | Deferred `FR-ADM-002` |
| Type Subscription payment | `payment_reference` text only; no checkout tables (`AD-API-04`) | `[PROPOSED]` |
| UUID v7 | App later; DB `gen_random_uuid()` now | `[PROPOSED]` |
| `AD-BE-05` Prisma vs Drizzle/Kysely | This file is Prisma DSL | `[PROPOSED]` |
| `notification_delivery.channel` / `.status` | Enums `NotificationChannel` / `NotificationDeliveryStatus` | Resolved (`AD-ASYNC-07`) — was free `varchar` |
| `vendor_profile.rating_trend` shape | jsonb `[{ period, average, count }]` | `[PROPOSED]` (`SAM-GAP-8`) — encoding chosen here, not by Screen-API-Map |

Yahoo redistribution and R2 residency do not change tables.

---

## 9. Local runtime

Default: a local PostgreSQL 16. Docker is optional and not required.

```bash
# DATABASE_URL=postgresql://karat:karat@localhost:5432/karat_hive
cd backend && npx prisma migrate deploy
```

Object storage for later media work: MinIO or R2 credentials in env. Not needed for schema migrate or `/health`. Seed contents: [`backend/prisma/seed/README.md`](../backend/prisma/seed/README.md).

---

## Appendix A — SRS §6.2 coverage

| SRS entity | Table | Notes |
|---|---|---|
| `USER` | `user` | Extra: `token_version`, `email_pending`, ToS versions, quiet hours |
| `CUSTOMER_PROFILE` | `customer_profile` | `photo_url` → `photo_media_id` |
| `VENDOR_PROFILE` | `vendor_profile` | No `subscription_tier_id`; `logo_url` → `logo_media_id` |
| `ADMIN_PROFILE` | `admin_profile` | Fields invented `[PROPOSED]` |
| `VENDOR_DOCUMENT` | `vendor_document` | `file_url` → `media_id` |
| `VENDOR_TYPE_SUBSCRIPTION` | `vendor_type_subscription` | |
| `REQUEST` | `request` | + `gemstones`, `expiry_warned_at` |
| `REQUEST_MEDIA` | `request_media` | Join to `media` |
| `REQUEST_MATCH` | `request_match` | |
| `OFFER` | `offer` | |
| `OFFER_REVISION` | `offer_revision` | |
| `CONNECTION` | `connection` | |
| `CONTACT_EVENT` | `contact_event` | |
| `REVIEW` | `review` | + `vendor_response_state` |
| `CATEGORY` / `REGION` | `category` / `region` | |
| `GOLD_RATE` | `gold_rate` | |
| `NOTIFICATION` | `notification` | |
| `ABUSE_REPORT` | `abuse_report` | |
| `AUDIT_LOG` | `audit_log` | No `updated_at` |
| `PLATFORM_SETTING` | `platform_setting` | `requires_confirmation` |
| `NOTIFICATION_DELIVERY` | `notification_delivery` | Infra table; `channel` / `status` enums (`AD-ASYNC-07`) |
| `OUTBOX_CONSUMER` | `outbox_consumer` | Infra table (Architecture §11.1). Consumer idempotency marker, `(event_id, consumer)` PK, written on success. Absent from Architecture Appendix C — flagged by Async-Contract §10 #6 |

## Appendix B — Revision history

| Version | Date | Change |
|---|---|---|
| 0.1 | 1 Sep 2026 | Initial physical model against SRS v1.3, Architecture-Backend §12, API inventory 0.1 |
| 0.2 | 1 Sep 2026 | T36: folded Async-Contract §10 (`AD-ASYNC-07` delivery enums; `offer.expiry_warned_at`, `request.draft_purge_warned_at`, `vendor_document.reminder_sent_at`; 4 job scan indexes) and Screen-API-Map `SAM-GAP-1/4/6/8` (`offer.viewed_by_customer_at`, `AbuseEntityType` += `VENDOR`/`CUSTOMER`, `vendor_profile.verification_message`, `vendor_profile.rating_trend`) into `schema.prisma` and the init migration |

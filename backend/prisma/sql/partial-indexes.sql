-- Constraints Prisma cannot express. Apply as a follow-up SQL migration.
-- See docs/Physical-Data-Model.md § "What Prisma cannot express".

-- BR-009: at most one non-terminal Offer per Vendor per Request.
-- PENDING is the sole non-terminal Offer state (SRS §5.3).
CREATE UNIQUE INDEX IF NOT EXISTS offer_one_pending_per_vendor_request
  ON offer (request_id, vendor_profile_id)
  WHERE state = 'PENDING';

-- FR-VEN-031: one live entitlement per (vendor, request type).
CREATE UNIQUE INDEX IF NOT EXISTS subscription_one_live_per_type
  ON vendor_type_subscription (vendor_profile_id, request_type)
  WHERE state IN ('ACTIVE', 'GRACE');

-- AD-API-07 / FR-VEN-013: validity hours 12 | 24 | 48.
-- SRS §6.2 listed 24/48/72/168 — treated as stale pending SRS alignment.
ALTER TABLE offer
  DROP CONSTRAINT IF EXISTS offer_validity_hours_allowed;
ALTER TABLE offer
  ADD CONSTRAINT offer_validity_hours_allowed
  CHECK (validity_hours IN (12, 24, 48));

-- Hot path 5 (Architecture §12.5): expiry sweeps stay small regardless of table size.
CREATE INDEX IF NOT EXISTS offer_pending_expires_at
  ON offer (expires_at)
  WHERE state = 'PENDING';

CREATE INDEX IF NOT EXISTS request_live_expires_at
  ON request (expires_at)
  WHERE state IN ('PUBLISHED', 'OFFERS_RECEIVED');

-- Outbox drain: claim PENDING rows by available_at (Architecture §11.1).
CREATE INDEX IF NOT EXISTS outbox_event_claim
  ON outbox_event (available_at)
  WHERE state = 'PENDING';

-- ---------------------------------------------------------------------------
-- Scheduled-job scan indexes (Async-Contract §10 / AD-ASYNC-08). Each new
-- sweep table-scans without these.
-- ---------------------------------------------------------------------------

-- offer-expiry-warning (FR-VEN-013 AC4): pending Offers not yet warned.
CREATE INDEX IF NOT EXISTS offer_expiry_warn
  ON offer (expires_at)
  WHERE state = 'PENDING' AND expiry_warned_at IS NULL;

-- request-draft-purge (FR-CUS-015 AC4): age out DRAFT Requests.
CREATE INDEX IF NOT EXISTS request_draft_age
  ON request (created_at)
  WHERE state = 'DRAFT';

-- vendor-document-expiry (FR-VEN-002 AC4): documents nearing expiry, no reminder sent.
CREATE INDEX IF NOT EXISTS vendor_doc_expiry
  ON vendor_document (expiry_date)
  WHERE reminder_sent_at IS NULL;

-- announcement-dispatch: scheduled, not cancelled, not yet dispatched
-- (dispatch_stats IS NULL is the "not yet dispatched" predicate — Async-Contract §10 #5).
CREATE INDEX IF NOT EXISTS announcement_due
  ON announcement (scheduled_for)
  WHERE cancelled_at IS NULL AND dispatch_stats IS NULL;

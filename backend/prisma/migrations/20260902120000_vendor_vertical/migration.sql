-- Vendor onboarding & activation vertical (check-point-1).
-- Adds password-login lockout bookkeeping and the composed marketplace-access
-- timestamp. Does NOT reopen 20260901120000_init (Backend-Gap-Fix-Plan).

ALTER TABLE "user"
  ADD COLUMN "failed_login_attempts" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "locked_until" TIMESTAMPTZ(6);

ALTER TABLE "vendor_profile"
  ADD COLUMN "activated_at" TIMESTAMPTZ(6);

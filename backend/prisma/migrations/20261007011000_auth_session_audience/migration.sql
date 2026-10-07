CREATE TYPE "AuthAudience" AS ENUM (
  'CUSTOMER_APP',
  'VENDOR_APP',
  'MOBILE_RESTORE',
  'ADMIN_PORTAL'
);

ALTER TABLE "refresh_token"
  ADD COLUMN "audience" "AuthAudience";

UPDATE "refresh_token" AS rt
SET "audience" = CASE
  WHEN u."user_type" = 'ADMIN' THEN 'ADMIN_PORTAL'::"AuthAudience"
  ELSE 'MOBILE_RESTORE'::"AuthAudience"
END
FROM "user" AS u
WHERE u."id" = rt."user_id";

ALTER TABLE "refresh_token"
  ALTER COLUMN "audience" SET DEFAULT 'MOBILE_RESTORE'::"AuthAudience",
  ALTER COLUMN "audience" SET NOT NULL;

CREATE INDEX "refresh_token_user_id_audience_revoked_at_idx"
  ON "refresh_token"("user_id", "audience", "revoked_at");

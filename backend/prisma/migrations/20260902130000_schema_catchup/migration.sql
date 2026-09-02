-- Realigns the Supabase database with the current schema.prisma. The applied
-- 20260901120000_init predates the T36 fold-in (SAM-GAP columns, Async-Contract
-- columns, notification_delivery enums). All affected tables are empty. The
-- pg_trgm GIN indexes stay (they live in prisma/sql/, not the Prisma schema).

CREATE TYPE "NotificationChannel" AS ENUM ('IN_APP', 'PUSH', 'EMAIL', 'SMS');
CREATE TYPE "NotificationDeliveryStatus" AS ENUM ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'BOUNCED');

ALTER TYPE "AbuseEntityType" ADD VALUE IF NOT EXISTS 'VENDOR';
ALTER TYPE "AbuseEntityType" ADD VALUE IF NOT EXISTS 'CUSTOMER';

ALTER TABLE "notification_delivery"
  DROP COLUMN "channel",
  ADD COLUMN "channel" "NotificationChannel" NOT NULL,
  DROP COLUMN "status",
  ADD COLUMN "status" "NotificationDeliveryStatus" NOT NULL;

ALTER TABLE "offer"
  ADD COLUMN "expiry_warned_at" TIMESTAMPTZ(6),
  ADD COLUMN "viewed_by_customer_at" TIMESTAMPTZ(6);

ALTER TABLE "request"
  ADD COLUMN "draft_purge_warned_at" TIMESTAMPTZ(6);

ALTER TABLE "vendor_document"
  ADD COLUMN "reminder_sent_at" TIMESTAMPTZ(6);

ALTER TABLE "vendor_profile"
  ADD COLUMN "rating_trend" JSONB,
  ADD COLUMN "verification_message" TEXT;

CREATE INDEX "notification_delivery_notification_id_channel_idx"
  ON "notification_delivery"("notification_id", "channel");

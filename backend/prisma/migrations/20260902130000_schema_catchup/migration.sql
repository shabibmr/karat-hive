-- Realigns the Supabase database with the current schema.prisma. The applied
-- 20260901120000_init predates the T36 fold-in (SAM-GAP columns, Async-Contract
-- columns, notification_delivery enums). All affected tables are empty. The
-- pg_trgm GIN indexes stay (they live in prisma/sql/, not the Prisma schema).

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'NotificationChannel') THEN
    CREATE TYPE "NotificationChannel" AS ENUM ('IN_APP', 'PUSH', 'EMAIL', 'SMS');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'NotificationDeliveryStatus') THEN
    CREATE TYPE "NotificationDeliveryStatus" AS ENUM ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'BOUNCED');
  END IF;
END $$;

ALTER TYPE "AbuseEntityType" ADD VALUE IF NOT EXISTS 'VENDOR';
ALTER TYPE "AbuseEntityType" ADD VALUE IF NOT EXISTS 'CUSTOMER';

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'notification_delivery' AND column_name = 'channel' AND udt_name = 'NotificationChannel'
  ) THEN
    ALTER TABLE "notification_delivery"
      DROP COLUMN IF EXISTS "channel",
      ADD COLUMN "channel" "NotificationChannel" NOT NULL,
      DROP COLUMN IF EXISTS "status",
      ADD COLUMN "status" "NotificationDeliveryStatus" NOT NULL;
  END IF;
END $$;

ALTER TABLE "offer"
  ADD COLUMN IF NOT EXISTS "expiry_warned_at" TIMESTAMPTZ(6),
  ADD COLUMN IF NOT EXISTS "viewed_by_customer_at" TIMESTAMPTZ(6);

ALTER TABLE "request"
  ADD COLUMN IF NOT EXISTS "draft_purge_warned_at" TIMESTAMPTZ(6);

ALTER TABLE "vendor_document"
  ADD COLUMN IF NOT EXISTS "reminder_sent_at" TIMESTAMPTZ(6);

ALTER TABLE "vendor_profile"
  ADD COLUMN IF NOT EXISTS "rating_trend" JSONB,
  ADD COLUMN IF NOT EXISTS "verification_message" TEXT;

CREATE INDEX IF NOT EXISTS "notification_delivery_notification_id_channel_idx"
  ON "notification_delivery"("notification_id", "channel");

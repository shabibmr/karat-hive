-- Karat Hive initial migration (T01).
-- Assembled, in order:
--   1. CREATE EXTENSION (pgcrypto, pg_trgm) — Prisma cannot express these.
--   2. prisma migrate diff --from-empty --to-schema-datamodel (enums, tables, FKs, indexes).
--   3. prisma/sql/partial-indexes.sql — partial/unique indexes + CHECK Prisma cannot express.
--   4. pg_trgm GIN indexes from prisma/sql/extensions.sql (need their tables to exist first).
-- Regenerate step 2 with: npm run prisma:diff
-- T36 folded in Async-Contract §10 (AD-ASYNC-07) + Screen-API-Map SAM-GAP-1/4/6/8.

CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pg_trgm;    -- Admin / Vendor fuzzy search (AD-BE-11, C-12)

-- CreateEnum
CREATE TYPE "UserType" AS ENUM ('CUSTOMER', 'VENDOR', 'ADMIN');

-- CreateEnum
CREATE TYPE "UserAccountState" AS ENUM ('ACTIVE', 'SUSPENDED', 'DEACTIVATED');

-- CreateEnum
CREATE TYPE "PreferredLanguage" AS ENUM ('en', 'ar');

-- CreateEnum
CREATE TYPE "VendorVerificationState" AS ENUM ('REGISTERED', 'PENDING_VERIFICATION', 'VERIFIED', 'REJECTED');

-- CreateEnum
CREATE TYPE "RequestType" AS ENUM ('FIND_ORNAMENT', 'SELL_OLD_GOLD', 'GOLD_COIN', 'GOLD_BULLION');

-- CreateEnum
CREATE TYPE "Direction" AS ENUM ('BUY', 'SELL');

-- CreateEnum
CREATE TYPE "RequestState" AS ENUM ('DRAFT', 'PUBLISHED', 'OFFERS_RECEIVED', 'ACCEPTED', 'CLOSED', 'EXPIRED', 'CANCELLED', 'REMOVED');

-- CreateEnum
CREATE TYPE "OfferState" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED', 'WITHDRAWN', 'WITHDRAWN_BY_SYSTEM');

-- CreateEnum
CREATE TYPE "ConnectionState" AS ENUM ('ACTIVE', 'CLOSED');

-- CreateEnum
CREATE TYPE "ReviewState" AS ENUM ('PENDING_MODERATION', 'PUBLISHED', 'REJECTED', 'REDACTED', 'WITHDRAWN');

-- CreateEnum
CREATE TYPE "SubscriptionState" AS ENUM ('ACTIVE', 'GRACE', 'EXPIRED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "Karat" AS ENUM ('24K', '22K', '21K', '18K');

-- CreateEnum
CREATE TYPE "OrnamentType" AS ENUM ('RING', 'CHAIN', 'BANGLE', 'NECKLACE', 'EARRING', 'BRACELET', 'PENDANT', 'OTHER');

-- CreateEnum
CREATE TYPE "ItemCondition" AS ENUM ('NEW', 'LIKE_NEW', 'USED', 'DAMAGED');

-- CreateEnum
CREATE TYPE "DocumentType" AS ENUM ('TRADE_LICENCE', 'EMIRATES_ID', 'VAT_CERT', 'TRADING_PERMIT', 'TENANCY', 'OTHER');

-- CreateEnum
CREATE TYPE "MediaPurpose" AS ENUM ('REQUEST_IMAGE', 'OFFER_IMAGE', 'PROFILE_PHOTO', 'VENDOR_LOGO', 'VENDOR_SHOP_PHOTO', 'KYC_DOCUMENT', 'EXPORT_ARTEFACT');

-- CreateEnum
CREATE TYPE "MediaState" AS ENUM ('PENDING_UPLOAD', 'PENDING_PROCESSING', 'READY', 'QUARANTINED', 'FAILED');

-- CreateEnum
CREATE TYPE "StorageBucket" AS ENUM ('REQUEST_MEDIA', 'KYC', 'EXPORT');

-- CreateEnum
CREATE TYPE "MalwareScanState" AS ENUM ('PENDING', 'CLEAN', 'QUARANTINED');

-- CreateEnum
CREATE TYPE "OAuthProvider" AS ENUM ('GOOGLE', 'APPLE');

-- CreateEnum
CREATE TYPE "OtpPurpose" AS ENUM ('REGISTER_CUSTOMER', 'REGISTER_VENDOR', 'LOGIN', 'CHANGE_MOBILE');

-- CreateEnum
CREATE TYPE "DevicePlatform" AS ENUM ('IOS', 'ANDROID');

-- CreateEnum
CREATE TYPE "ContactChannel" AS ENUM ('WHATSAPP', 'PHONE');

-- CreateEnum
CREATE TYPE "ClosedBy" AS ENUM ('CUSTOMER', 'VENDOR', 'ADMIN');

-- CreateEnum
CREATE TYPE "AuthorType" AS ENUM ('CUSTOMER', 'VENDOR');

-- CreateEnum
CREATE TYPE "AbuseEntityType" AS ENUM ('REQUEST', 'OFFER', 'CONNECTION', 'REVIEW', 'VENDOR', 'CUSTOMER');

-- CreateEnum
CREATE TYPE "AbuseReportState" AS ENUM ('OPEN', 'UNDER_REVIEW', 'RESOLVED', 'DISMISSED');

-- CreateEnum
CREATE TYPE "GoldRateSource" AS ENUM ('FEED', 'MANUAL_OVERRIDE');

-- CreateEnum
CREATE TYPE "OutboxState" AS ENUM ('PENDING', 'CLAIMED', 'DONE', 'FAILED');

-- CreateEnum
CREATE TYPE "ExportFormat" AS ENUM ('CSV', 'XLSX', 'PNG');

-- CreateEnum
CREATE TYPE "ExportJobState" AS ENUM ('QUEUED', 'RUNNING', 'READY', 'FAILED');

-- CreateEnum
CREATE TYPE "DataSubjectRequestState" AS ENUM ('QUEUED', 'RUNNING', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "DeclineReason" AS ENUM ('PRICE_TOO_HIGH', 'TERMS_UNSUITABLE', 'NO_LONGER_REQUIRED', 'OTHER');

-- CreateEnum
CREATE TYPE "NotificationChannel" AS ENUM ('IN_APP', 'PUSH', 'EMAIL', 'SMS');

-- CreateEnum
CREATE TYPE "NotificationDeliveryStatus" AS ENUM ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'BOUNCED');

-- CreateTable
CREATE TABLE "user" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "mobile_number" VARCHAR(20) NOT NULL,
    "mobile_verified_at" TIMESTAMPTZ(6),
    "email" VARCHAR(255),
    "email_verified_at" TIMESTAMPTZ(6),
    "email_pending" VARCHAR(255),
    "password_hash" TEXT,
    "user_type" "UserType" NOT NULL,
    "account_state" "UserAccountState" NOT NULL,
    "preferred_language" "PreferredLanguage" NOT NULL DEFAULT 'en',
    "token_version" INTEGER NOT NULL DEFAULT 0,
    "terms_version" VARCHAR(32),
    "privacy_version" VARCHAR(32),
    "terms_accepted_at" TIMESTAMPTZ(6),
    "quiet_hours_start" VARCHAR(5),
    "quiet_hours_end" VARCHAR(5),
    "last_login_at" TIMESTAMPTZ(6),
    "deleted_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_profile" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "display_name" VARCHAR(100) NOT NULL,
    "photo_media_id" UUID,
    "default_region_id" UUID,
    "aggregate_rating" DECIMAL(2,1),
    "review_count" INTEGER NOT NULL DEFAULT 0,
    "connection_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "customer_profile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "admin_profile" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "display_name" VARCHAR(100) NOT NULL,
    "totp_secret_encrypted" TEXT,
    "totp_confirmed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "admin_profile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refresh_token" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "family_id" UUID NOT NULL,
    "token_hash" TEXT NOT NULL,
    "rotated_at" TIMESTAMPTZ(6),
    "revoked_at" TIMESTAMPTZ(6),
    "reuse_detected_at" TIMESTAMPTZ(6),
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "ip" VARCHAR(64),
    "user_agent" VARCHAR(512),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refresh_token_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "otp_challenge" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID,
    "mobile_number" VARCHAR(20) NOT NULL,
    "purpose" "OtpPurpose" NOT NULL,
    "code_hash" TEXT NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "consumed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "otp_challenge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "oauth_binding" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "provider" "OAuthProvider" NOT NULL,
    "subject_hash" TEXT NOT NULL,
    "bound_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "oauth_binding_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "platform" "DevicePlatform" NOT NULL,
    "push_token" TEXT NOT NULL,
    "label" VARCHAR(100),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "device_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_profile" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "legal_business_name" VARCHAR(200) NOT NULL,
    "trading_name" VARCHAR(200) NOT NULL,
    "trade_licence_number" VARCHAR(50) NOT NULL,
    "licence_expiry_date" DATE NOT NULL,
    "business_address" TEXT NOT NULL,
    "contact_person_name" VARCHAR(100) NOT NULL,
    "business_email" VARCHAR(255) NOT NULL,
    "logo_media_id" UUID,
    "description" TEXT,
    "verification_state" "VendorVerificationState" NOT NULL,
    "verified_at" TIMESTAMPTZ(6),
    "verified_by_admin_id" UUID,
    "verification_notes" TEXT,
    "verification_message" TEXT,
    "business_hours" JSONB,
    "away_mode" BOOLEAN NOT NULL DEFAULT false,
    "aggregate_rating" DECIMAL(2,1),
    "review_count" INTEGER NOT NULL DEFAULT 0,
    "rating_trend" JSONB,
    "offers_submitted_count" INTEGER NOT NULL DEFAULT 0,
    "offers_accepted_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "vendor_profile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_document" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "vendor_profile_id" UUID NOT NULL,
    "document_type" "DocumentType" NOT NULL,
    "media_id" UUID NOT NULL,
    "expiry_date" DATE,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "reminder_sent_at" TIMESTAMPTZ(6),
    "uploaded_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "vendor_document_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_type_subscription" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "vendor_profile_id" UUID NOT NULL,
    "request_type" "RequestType" NOT NULL,
    "state" "SubscriptionState" NOT NULL,
    "period_start" TIMESTAMPTZ(6) NOT NULL,
    "period_end" TIMESTAMPTZ(6) NOT NULL,
    "price_aed" DECIMAL(12,2) NOT NULL,
    "grace_ends_at" TIMESTAMPTZ(6),
    "payment_reference" VARCHAR(100),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "vendor_type_subscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "category" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "parent_id" UUID,
    "name_en" VARCHAR(100) NOT NULL,
    "name_ar" VARCHAR(100) NOT NULL,
    "display_order" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "region" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "parent_id" UUID,
    "name_en" VARCHAR(100) NOT NULL,
    "name_ar" VARCHAR(100) NOT NULL,
    "display_order" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "region_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_category" (
    "vendor_profile_id" UUID NOT NULL,
    "category_id" UUID NOT NULL,

    CONSTRAINT "vendor_category_pkey" PRIMARY KEY ("vendor_profile_id","category_id")
);

-- CreateTable
CREATE TABLE "vendor_region" (
    "vendor_profile_id" UUID NOT NULL,
    "region_id" UUID NOT NULL,

    CONSTRAINT "vendor_region_pkey" PRIMARY KEY ("vendor_profile_id","region_id")
);

-- CreateTable
CREATE TABLE "media" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "key" VARCHAR(64) NOT NULL,
    "purpose" "MediaPurpose" NOT NULL,
    "state" "MediaState" NOT NULL,
    "bucket" "StorageBucket" NOT NULL,
    "content_type" VARCHAR(100) NOT NULL,
    "byte_size" INTEGER NOT NULL,
    "exif_stripped" BOOLEAN NOT NULL DEFAULT false,
    "malware_scan_state" "MalwareScanState" NOT NULL DEFAULT 'PENDING',
    "thumbnail_key" VARCHAR(64),
    "uploaded_by_user_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "media_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "request" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "reference" VARCHAR(24),
    "customer_profile_id" UUID NOT NULL,
    "request_type" "RequestType" NOT NULL,
    "direction" "Direction" NOT NULL,
    "state" "RequestState" NOT NULL,
    "category_id" UUID NOT NULL,
    "region_id" UUID NOT NULL,
    "notes" TEXT,
    "weight_grams" DECIMAL(10,2),
    "weight_is_approximate" BOOLEAN NOT NULL DEFAULT false,
    "purity_karat" "Karat",
    "ornament_type" "OrnamentType",
    "condition" "ItemCondition",
    "denomination_grams" DECIMAL(10,2),
    "quantity" INTEGER,
    "mint_or_refiner" VARCHAR(100),
    "budget_min" DECIMAL(12,2),
    "budget_max" DECIMAL(12,2),
    "budget_is_flexible" BOOLEAN NOT NULL DEFAULT false,
    "indicative_value" DECIMAL(12,2),
    "gold_rate_id" UUID,
    "gemstones" JSONB,
    "published_at" TIMESTAMPTZ(6),
    "expires_at" TIMESTAMPTZ(6),
    "expiry_warned_at" TIMESTAMPTZ(6),
    "draft_purge_warned_at" TIMESTAMPTZ(6),
    "offer_count" INTEGER NOT NULL DEFAULT 0,
    "accepted_offer_id" UUID,
    "cancellation_reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "request_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "request_media" (
    "request_id" UUID NOT NULL,
    "media_id" UUID NOT NULL,
    "display_order" INTEGER NOT NULL,

    CONSTRAINT "request_media_pkey" PRIMARY KEY ("request_id","media_id")
);

-- CreateTable
CREATE TABLE "request_match" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "request_id" UUID NOT NULL,
    "vendor_profile_id" UUID NOT NULL,
    "matched_at" TIMESTAMPTZ(6) NOT NULL,
    "viewed_at" TIMESTAMPTZ(6),
    "is_eligible" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "request_match_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "offer" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "request_id" UUID NOT NULL,
    "vendor_profile_id" UUID NOT NULL,
    "state" "OfferState" NOT NULL,
    "offered_price" DECIMAL(12,2) NOT NULL,
    "making_charges" DECIMAL(12,2),
    "rate_per_gram" DECIMAL(10,2),
    "delivery_timeframe" VARCHAR(100),
    "warranty_terms" TEXT,
    "vendor_note" TEXT,
    "validity_hours" INTEGER NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "expiry_warned_at" TIMESTAMPTZ(6),
    "viewed_by_customer_at" TIMESTAMPTZ(6),
    "revision_count" INTEGER NOT NULL DEFAULT 0,
    "submitted_at" TIMESTAMPTZ(6) NOT NULL,
    "decided_at" TIMESTAMPTZ(6),
    "decline_reason" "DeclineReason",
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "offer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "offer_revision" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "offer_id" UUID NOT NULL,
    "revision_number" INTEGER NOT NULL,
    "previous_terms" JSONB NOT NULL,
    "revised_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "offer_revision_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "offer_media" (
    "offer_id" UUID NOT NULL,
    "media_id" UUID NOT NULL,
    "display_order" INTEGER NOT NULL,

    CONSTRAINT "offer_media_pkey" PRIMARY KEY ("offer_id","media_id")
);

-- CreateTable
CREATE TABLE "filter_preset" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "vendor_profile_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "filters" JSONB NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "filter_preset_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "connection" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "offer_id" UUID NOT NULL,
    "request_id" UUID NOT NULL,
    "customer_profile_id" UUID NOT NULL,
    "vendor_profile_id" UUID NOT NULL,
    "state" "ConnectionState" NOT NULL,
    "identity_revealed_at" TIMESTAMPTZ(6) NOT NULL,
    "closed_at" TIMESTAMPTZ(6),
    "closed_by" "ClosedBy",
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "connection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contact_event" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "connection_id" UUID NOT NULL,
    "initiated_by" "AuthorType" NOT NULL,
    "channel" "ContactChannel" NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "contact_event_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "review" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "connection_id" UUID NOT NULL,
    "author_type" "AuthorType" NOT NULL,
    "author_user_id" UUID NOT NULL,
    "subject_user_id" UUID NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "state" "ReviewState" NOT NULL,
    "vendor_response" TEXT,
    "vendor_response_state" "ReviewState",
    "moderated_by_admin_id" UUID,
    "editable_until" TIMESTAMPTZ(6) NOT NULL,
    "published_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "review_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "abuse_report" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "reporter_user_id" UUID NOT NULL,
    "reported_user_id" UUID NOT NULL,
    "entity_type" "AbuseEntityType" NOT NULL,
    "entity_id" UUID NOT NULL,
    "category" VARCHAR(64) NOT NULL,
    "description" TEXT NOT NULL,
    "state" "AbuseReportState" NOT NULL,
    "resolution" TEXT,
    "resolved_by_admin_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "abuse_report_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "recipient_user_id" UUID NOT NULL,
    "type" VARCHAR(64) NOT NULL,
    "title_en" VARCHAR(200) NOT NULL,
    "title_ar" VARCHAR(200) NOT NULL,
    "body_en" TEXT NOT NULL,
    "body_ar" TEXT NOT NULL,
    "deep_link" VARCHAR(300) NOT NULL,
    "channels_sent" JSONB,
    "is_critical" BOOLEAN NOT NULL DEFAULT false,
    "read_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_delivery" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "notification_id" UUID NOT NULL,
    "channel" "NotificationChannel" NOT NULL,
    "attempt" INTEGER NOT NULL,
    "status" "NotificationDeliveryStatus" NOT NULL,
    "provider_ref" VARCHAR(200),
    "last_error" TEXT,
    "attempted_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "notification_delivery_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_preference" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "category" VARCHAR(64) NOT NULL,
    "in_app" BOOLEAN NOT NULL DEFAULT true,
    "push" BOOLEAN NOT NULL DEFAULT true,
    "email" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "notification_preference_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gold_rate" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "purity_karat" "Karat" NOT NULL,
    "rate_per_gram_aed" DECIMAL(10,2) NOT NULL,
    "source" "GoldRateSource" NOT NULL,
    "feed_provider" VARCHAR(64),
    "source_timestamp" TIMESTAMPTZ(6) NOT NULL,
    "override_reason" TEXT,
    "override_expires_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "gold_rate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "platform_setting" (
    "key" VARCHAR(100) NOT NULL,
    "value" JSONB NOT NULL,
    "data_type" VARCHAR(32) NOT NULL,
    "allowed_range" JSONB,
    "requires_confirmation" BOOLEAN NOT NULL DEFAULT false,
    "last_changed_by_admin_id" UUID,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "platform_setting_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "audit_log" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "actor_user_id" UUID,
    "action" VARCHAR(100) NOT NULL,
    "entity_type" VARCHAR(64) NOT NULL,
    "entity_id" UUID,
    "before_value" JSONB,
    "after_value" JSONB,
    "ip_address" VARCHAR(64),
    "user_agent" VARCHAR(512),
    "occurred_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_log_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "admin_note" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "entity_type" VARCHAR(64) NOT NULL,
    "entity_id" UUID NOT NULL,
    "text" TEXT NOT NULL,
    "author_admin_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "admin_note_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "announcement" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "title_en" VARCHAR(200) NOT NULL,
    "title_ar" VARCHAR(200) NOT NULL,
    "body_en" TEXT NOT NULL,
    "body_ar" TEXT NOT NULL,
    "audience" JSONB NOT NULL,
    "channels" JSONB NOT NULL,
    "critical" BOOLEAN NOT NULL DEFAULT false,
    "scheduled_for" TIMESTAMPTZ(6),
    "cancelled_at" TIMESTAMPTZ(6),
    "dispatch_stats" JSONB,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "announcement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "export_job" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "report_name" VARCHAR(64) NOT NULL,
    "format" "ExportFormat" NOT NULL,
    "filters" JSONB NOT NULL,
    "purpose" TEXT NOT NULL,
    "state" "ExportJobState" NOT NULL,
    "media_id" UUID,
    "watermark" JSONB,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMPTZ(6),

    CONSTRAINT "export_job_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outbox_event" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "event_type" VARCHAR(100) NOT NULL,
    "aggregate_type" VARCHAR(64) NOT NULL,
    "aggregate_id" UUID NOT NULL,
    "payload" JSONB NOT NULL,
    "available_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "claimed_at" TIMESTAMPTZ(6),
    "claimed_by" VARCHAR(64),
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "state" "OutboxState" NOT NULL,
    "last_error" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outbox_event_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outbox_consumer" (
    "event_id" UUID NOT NULL,
    "consumer" VARCHAR(64) NOT NULL,
    "consumed_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "outbox_consumer_pkey" PRIMARY KEY ("event_id","consumer")
);

-- CreateTable
CREATE TABLE "job_lock" (
    "job_name" VARCHAR(64) NOT NULL,
    "owner" VARCHAR(64) NOT NULL,
    "leased_until" TIMESTAMPTZ(6) NOT NULL,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "job_lock_pkey" PRIMARY KEY ("job_name")
);

-- CreateTable
CREATE TABLE "idempotency_key" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "key" VARCHAR(64) NOT NULL,
    "route" VARCHAR(200) NOT NULL,
    "caller_subject" VARCHAR(80) NOT NULL,
    "caller_user_id" UUID,
    "body_hash" VARCHAR(64) NOT NULL,
    "status_code" INTEGER NOT NULL,
    "response_body" JSONB NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "idempotency_key_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rate_limit_bucket" (
    "scope" VARCHAR(64) NOT NULL,
    "subject" VARCHAR(80) NOT NULL,
    "tokens" DECIMAL(12,3) NOT NULL,
    "window_start" TIMESTAMPTZ(6) NOT NULL,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "rate_limit_bucket_pkey" PRIMARY KEY ("scope","subject")
);

-- CreateTable
CREATE TABLE "data_subject_request" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "state" "DataSubjectRequestState" NOT NULL,
    "reason" TEXT,
    "actioned_by_admin_id" UUID,
    "certificate_media_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMPTZ(6),

    CONSTRAINT "data_subject_request_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "user_mobile_number_key" ON "user"("mobile_number");

-- CreateIndex
CREATE UNIQUE INDEX "user_email_key" ON "user"("email");

-- CreateIndex
CREATE INDEX "user_account_state_created_at_idx" ON "user"("account_state", "created_at");

-- CreateIndex
CREATE INDEX "user_user_type_account_state_idx" ON "user"("user_type", "account_state");

-- CreateIndex
CREATE UNIQUE INDEX "customer_profile_user_id_key" ON "customer_profile"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "admin_profile_user_id_key" ON "admin_profile"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "refresh_token_token_hash_key" ON "refresh_token"("token_hash");

-- CreateIndex
CREATE INDEX "refresh_token_user_id_revoked_at_idx" ON "refresh_token"("user_id", "revoked_at");

-- CreateIndex
CREATE INDEX "refresh_token_family_id_idx" ON "refresh_token"("family_id");

-- CreateIndex
CREATE INDEX "otp_challenge_mobile_number_purpose_created_at_idx" ON "otp_challenge"("mobile_number", "purpose", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "oauth_binding_subject_hash_key" ON "oauth_binding"("subject_hash");

-- CreateIndex
CREATE UNIQUE INDEX "oauth_binding_user_id_provider_key" ON "oauth_binding"("user_id", "provider");

-- CreateIndex
CREATE UNIQUE INDEX "device_push_token_key" ON "device"("push_token");

-- CreateIndex
CREATE INDEX "device_user_id_idx" ON "device"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_profile_user_id_key" ON "vendor_profile"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_profile_trade_licence_number_key" ON "vendor_profile"("trade_licence_number");

-- CreateIndex
CREATE INDEX "vendor_profile_verification_state_created_at_idx" ON "vendor_profile"("verification_state", "created_at");

-- CreateIndex
CREATE INDEX "vendor_document_vendor_profile_id_document_type_idx" ON "vendor_document"("vendor_profile_id", "document_type");

-- CreateIndex
CREATE INDEX "vendor_type_subscription_request_type_state_idx" ON "vendor_type_subscription"("request_type", "state");

-- CreateIndex
CREATE INDEX "vendor_type_subscription_vendor_profile_id_request_type_sta_idx" ON "vendor_type_subscription"("vendor_profile_id", "request_type", "state");

-- CreateIndex
CREATE INDEX "category_parent_id_display_order_idx" ON "category"("parent_id", "display_order");

-- CreateIndex
CREATE INDEX "region_parent_id_display_order_idx" ON "region"("parent_id", "display_order");

-- CreateIndex
CREATE INDEX "vendor_category_category_id_vendor_profile_id_idx" ON "vendor_category"("category_id", "vendor_profile_id");

-- CreateIndex
CREATE INDEX "vendor_region_region_id_vendor_profile_id_idx" ON "vendor_region"("region_id", "vendor_profile_id");

-- CreateIndex
CREATE UNIQUE INDEX "media_key_key" ON "media"("key");

-- CreateIndex
CREATE INDEX "media_state_created_at_idx" ON "media"("state", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "request_reference_key" ON "request"("reference");

-- CreateIndex
CREATE UNIQUE INDEX "request_accepted_offer_id_key" ON "request"("accepted_offer_id");

-- CreateIndex
CREATE INDEX "request_customer_profile_id_state_created_at_idx" ON "request"("customer_profile_id", "state", "created_at");

-- CreateIndex
CREATE INDEX "request_state_published_at_idx" ON "request"("state", "published_at");

-- CreateIndex
CREATE INDEX "request_state_expires_at_idx" ON "request"("state", "expires_at");

-- CreateIndex
CREATE INDEX "request_request_type_state_published_at_idx" ON "request"("request_type", "state", "published_at");

-- CreateIndex
CREATE INDEX "request_category_id_region_id_state_idx" ON "request"("category_id", "region_id", "state");

-- CreateIndex
CREATE UNIQUE INDEX "request_media_request_id_display_order_key" ON "request_media"("request_id", "display_order");

-- CreateIndex
CREATE INDEX "request_match_vendor_profile_id_matched_at_idx" ON "request_match"("vendor_profile_id", "matched_at" DESC);

-- CreateIndex
CREATE INDEX "request_match_vendor_profile_id_is_eligible_viewed_at_idx" ON "request_match"("vendor_profile_id", "is_eligible", "viewed_at");

-- CreateIndex
CREATE UNIQUE INDEX "request_match_request_id_vendor_profile_id_key" ON "request_match"("request_id", "vendor_profile_id");

-- CreateIndex
CREATE INDEX "offer_request_id_state_submitted_at_idx" ON "offer"("request_id", "state", "submitted_at" DESC);

-- CreateIndex
CREATE INDEX "offer_vendor_profile_id_state_submitted_at_idx" ON "offer"("vendor_profile_id", "state", "submitted_at" DESC);

-- CreateIndex
CREATE INDEX "offer_state_expires_at_idx" ON "offer"("state", "expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "offer_revision_offer_id_revision_number_key" ON "offer_revision"("offer_id", "revision_number");

-- CreateIndex
CREATE UNIQUE INDEX "offer_media_offer_id_display_order_key" ON "offer_media"("offer_id", "display_order");

-- CreateIndex
CREATE INDEX "filter_preset_vendor_profile_id_idx" ON "filter_preset"("vendor_profile_id");

-- CreateIndex
CREATE UNIQUE INDEX "connection_offer_id_key" ON "connection"("offer_id");

-- CreateIndex
CREATE INDEX "connection_customer_profile_id_state_created_at_idx" ON "connection"("customer_profile_id", "state", "created_at");

-- CreateIndex
CREATE INDEX "connection_vendor_profile_id_state_created_at_idx" ON "connection"("vendor_profile_id", "state", "created_at");

-- CreateIndex
CREATE INDEX "connection_state_created_at_idx" ON "connection"("state", "created_at");

-- CreateIndex
CREATE INDEX "contact_event_connection_id_occurred_at_idx" ON "contact_event"("connection_id", "occurred_at");

-- CreateIndex
CREATE INDEX "review_subject_user_id_state_idx" ON "review"("subject_user_id", "state");

-- CreateIndex
CREATE INDEX "review_state_created_at_idx" ON "review"("state", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "review_connection_id_author_type_key" ON "review"("connection_id", "author_type");

-- CreateIndex
CREATE INDEX "abuse_report_state_created_at_idx" ON "abuse_report"("state", "created_at");

-- CreateIndex
CREATE INDEX "abuse_report_entity_type_entity_id_idx" ON "abuse_report"("entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "abuse_report_reported_user_id_state_idx" ON "abuse_report"("reported_user_id", "state");

-- CreateIndex
CREATE INDEX "notification_recipient_user_id_created_at_idx" ON "notification"("recipient_user_id", "created_at" DESC);

-- CreateIndex
CREATE INDEX "notification_recipient_user_id_read_at_idx" ON "notification"("recipient_user_id", "read_at");

-- CreateIndex
CREATE INDEX "notification_delivery_notification_id_channel_idx" ON "notification_delivery"("notification_id", "channel");

-- CreateIndex
CREATE UNIQUE INDEX "notification_preference_user_id_category_key" ON "notification_preference"("user_id", "category");

-- CreateIndex
CREATE INDEX "gold_rate_purity_karat_created_at_idx" ON "gold_rate"("purity_karat", "created_at" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "gold_rate_purity_karat_source_source_timestamp_key" ON "gold_rate"("purity_karat", "source", "source_timestamp");

-- CreateIndex
CREATE INDEX "audit_log_actor_user_id_occurred_at_idx" ON "audit_log"("actor_user_id", "occurred_at");

-- CreateIndex
CREATE INDEX "audit_log_entity_type_entity_id_occurred_at_idx" ON "audit_log"("entity_type", "entity_id", "occurred_at");

-- CreateIndex
CREATE INDEX "audit_log_action_occurred_at_idx" ON "audit_log"("action", "occurred_at");

-- CreateIndex
CREATE INDEX "audit_log_occurred_at_idx" ON "audit_log"("occurred_at");

-- CreateIndex
CREATE INDEX "admin_note_entity_type_entity_id_created_at_idx" ON "admin_note"("entity_type", "entity_id", "created_at");

-- CreateIndex
CREATE INDEX "announcement_scheduled_for_idx" ON "announcement"("scheduled_for");

-- CreateIndex
CREATE INDEX "export_job_created_by_id_created_at_idx" ON "export_job"("created_by_id", "created_at");

-- CreateIndex
CREATE INDEX "export_job_state_created_at_idx" ON "export_job"("state", "created_at");

-- CreateIndex
CREATE INDEX "outbox_event_state_available_at_idx" ON "outbox_event"("state", "available_at");

-- CreateIndex
CREATE INDEX "idempotency_key_created_at_idx" ON "idempotency_key"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "idempotency_key_key_route_caller_subject_key" ON "idempotency_key"("key", "route", "caller_subject");

-- CreateIndex
CREATE INDEX "data_subject_request_user_id_state_idx" ON "data_subject_request"("user_id", "state");

-- AddForeignKey
ALTER TABLE "customer_profile" ADD CONSTRAINT "customer_profile_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_profile" ADD CONSTRAINT "customer_profile_photo_media_id_fkey" FOREIGN KEY ("photo_media_id") REFERENCES "media"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_profile" ADD CONSTRAINT "customer_profile_default_region_id_fkey" FOREIGN KEY ("default_region_id") REFERENCES "region"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admin_profile" ADD CONSTRAINT "admin_profile_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refresh_token" ADD CONSTRAINT "refresh_token_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "otp_challenge" ADD CONSTRAINT "otp_challenge_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "oauth_binding" ADD CONSTRAINT "oauth_binding_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device" ADD CONSTRAINT "device_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_profile" ADD CONSTRAINT "vendor_profile_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_profile" ADD CONSTRAINT "vendor_profile_logo_media_id_fkey" FOREIGN KEY ("logo_media_id") REFERENCES "media"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_profile" ADD CONSTRAINT "vendor_profile_verified_by_admin_id_fkey" FOREIGN KEY ("verified_by_admin_id") REFERENCES "admin_profile"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_document" ADD CONSTRAINT "vendor_document_vendor_profile_id_fkey" FOREIGN KEY ("vendor_profile_id") REFERENCES "vendor_profile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_document" ADD CONSTRAINT "vendor_document_media_id_fkey" FOREIGN KEY ("media_id") REFERENCES "media"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_type_subscription" ADD CONSTRAINT "vendor_type_subscription_vendor_profile_id_fkey" FOREIGN KEY ("vendor_profile_id") REFERENCES "vendor_profile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category" ADD CONSTRAINT "category_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "region" ADD CONSTRAINT "region_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "region"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_category" ADD CONSTRAINT "vendor_category_vendor_profile_id_fkey" FOREIGN KEY ("vendor_profile_id") REFERENCES "vendor_profile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_category" ADD CONSTRAINT "vendor_category_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_region" ADD CONSTRAINT "vendor_region_vendor_profile_id_fkey" FOREIGN KEY ("vendor_profile_id") REFERENCES "vendor_profile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_region" ADD CONSTRAINT "vendor_region_region_id_fkey" FOREIGN KEY ("region_id") REFERENCES "region"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "request" ADD CONSTRAINT "request_customer_profile_id_fkey" FOREIGN KEY ("customer_profile_id") REFERENCES "customer_profile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "request" ADD CONSTRAINT "request_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "request" ADD CONSTRAINT "request_region_id_fkey" FOREIGN KEY ("region_id") REFERENCES "region"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "request" ADD CONSTRAINT "request_gold_rate_id_fkey" FOREIGN KEY ("gold_rate_id") REFERENCES "gold_rate"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "request" ADD CONSTRAINT "request_accepted_offer_id_fkey" FOREIGN KEY ("accepted_offer_id") REFERENCES "offer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "request_media" ADD CONSTRAINT "request_media_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "request"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "request_media" ADD CONSTRAINT "request_media_media_id_fkey" FOREIGN KEY ("media_id") REFERENCES "media"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "request_match" ADD CONSTRAINT "request_match_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "request"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "request_match" ADD CONSTRAINT "request_match_vendor_profile_id_fkey" FOREIGN KEY ("vendor_profile_id") REFERENCES "vendor_profile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "offer" ADD CONSTRAINT "offer_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "request"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "offer" ADD CONSTRAINT "offer_vendor_profile_id_fkey" FOREIGN KEY ("vendor_profile_id") REFERENCES "vendor_profile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "offer_revision" ADD CONSTRAINT "offer_revision_offer_id_fkey" FOREIGN KEY ("offer_id") REFERENCES "offer"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "offer_media" ADD CONSTRAINT "offer_media_offer_id_fkey" FOREIGN KEY ("offer_id") REFERENCES "offer"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "offer_media" ADD CONSTRAINT "offer_media_media_id_fkey" FOREIGN KEY ("media_id") REFERENCES "media"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "filter_preset" ADD CONSTRAINT "filter_preset_vendor_profile_id_fkey" FOREIGN KEY ("vendor_profile_id") REFERENCES "vendor_profile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "connection" ADD CONSTRAINT "connection_offer_id_fkey" FOREIGN KEY ("offer_id") REFERENCES "offer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "connection" ADD CONSTRAINT "connection_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "request"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "connection" ADD CONSTRAINT "connection_customer_profile_id_fkey" FOREIGN KEY ("customer_profile_id") REFERENCES "customer_profile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "connection" ADD CONSTRAINT "connection_vendor_profile_id_fkey" FOREIGN KEY ("vendor_profile_id") REFERENCES "vendor_profile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contact_event" ADD CONSTRAINT "contact_event_connection_id_fkey" FOREIGN KEY ("connection_id") REFERENCES "connection"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_connection_id_fkey" FOREIGN KEY ("connection_id") REFERENCES "connection"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_author_user_id_fkey" FOREIGN KEY ("author_user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_subject_user_id_fkey" FOREIGN KEY ("subject_user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_moderated_by_admin_id_fkey" FOREIGN KEY ("moderated_by_admin_id") REFERENCES "admin_profile"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "abuse_report" ADD CONSTRAINT "abuse_report_reporter_user_id_fkey" FOREIGN KEY ("reporter_user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "abuse_report" ADD CONSTRAINT "abuse_report_reported_user_id_fkey" FOREIGN KEY ("reported_user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "abuse_report" ADD CONSTRAINT "abuse_report_resolved_by_admin_id_fkey" FOREIGN KEY ("resolved_by_admin_id") REFERENCES "admin_profile"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification" ADD CONSTRAINT "notification_recipient_user_id_fkey" FOREIGN KEY ("recipient_user_id") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_delivery" ADD CONSTRAINT "notification_delivery_notification_id_fkey" FOREIGN KEY ("notification_id") REFERENCES "notification"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_preference" ADD CONSTRAINT "notification_preference_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "platform_setting" ADD CONSTRAINT "platform_setting_last_changed_by_admin_id_fkey" FOREIGN KEY ("last_changed_by_admin_id") REFERENCES "admin_profile"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_log" ADD CONSTRAINT "audit_log_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admin_note" ADD CONSTRAINT "admin_note_author_admin_id_fkey" FOREIGN KEY ("author_admin_id") REFERENCES "admin_profile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcement" ADD CONSTRAINT "announcement_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "admin_profile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "export_job" ADD CONSTRAINT "export_job_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "admin_profile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "export_job" ADD CONSTRAINT "export_job_media_id_fkey" FOREIGN KEY ("media_id") REFERENCES "media"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outbox_consumer" ADD CONSTRAINT "outbox_consumer_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "outbox_event"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "idempotency_key" ADD CONSTRAINT "idempotency_key_caller_user_id_fkey" FOREIGN KEY ("caller_user_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "data_subject_request" ADD CONSTRAINT "data_subject_request_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "data_subject_request" ADD CONSTRAINT "data_subject_request_actioned_by_admin_id_fkey" FOREIGN KEY ("actioned_by_admin_id") REFERENCES "admin_profile"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "data_subject_request" ADD CONSTRAINT "data_subject_request_certificate_media_id_fkey" FOREIGN KEY ("certificate_media_id") REFERENCES "media"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- ===========================================================================
-- prisma/sql/partial-indexes.sql
-- ===========================================================================

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

-- ===========================================================================
-- pg_trgm GIN indexes (prisma/sql/extensions.sql). Architecture 12.6. No Elasticsearch.
-- ===========================================================================

CREATE INDEX IF NOT EXISTS request_notes_trgm
  ON request USING gin (notes gin_trgm_ops);

CREATE INDEX IF NOT EXISTS request_reference_trgm
  ON request USING gin (reference gin_trgm_ops);

CREATE INDEX IF NOT EXISTS vendor_trading_name_trgm
  ON vendor_profile USING gin (trading_name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS vendor_legal_name_trgm
  ON vendor_profile USING gin (legal_business_name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS vendor_licence_trgm
  ON vendor_profile USING gin (trade_licence_number gin_trgm_ops);

CREATE INDEX IF NOT EXISTS user_mobile_trgm
  ON "user" USING gin (mobile_number gin_trgm_ops);

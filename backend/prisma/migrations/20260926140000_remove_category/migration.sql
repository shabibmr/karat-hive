-- Migration: Remove Category entity and vendor_category relation
-- Decision: BR-002 Category removal (2026-09-26)

-- DropForeignKey
ALTER TABLE "request" DROP CONSTRAINT IF EXISTS "request_category_id_fkey";

-- DropForeignKey
ALTER TABLE "vendor_category" DROP CONSTRAINT IF EXISTS "vendor_category_category_id_fkey";

-- DropForeignKey
ALTER TABLE "vendor_category" DROP CONSTRAINT IF EXISTS "vendor_category_vendor_profile_id_fkey";

-- DropIndex
DROP INDEX IF EXISTS "request_category_id_region_id_state_idx";

-- AlterTable
ALTER TABLE "request" DROP COLUMN IF EXISTS "category_id";

-- CreateIndex
CREATE INDEX IF NOT EXISTS "request_region_id_state_idx" ON "request"("region_id", "state");

-- DropTable
DROP TABLE IF EXISTS "vendor_category";

-- DropTable
DROP TABLE IF EXISTS "category";

-- Drop self-referential foreign keys
ALTER TABLE "category" DROP CONSTRAINT IF EXISTS "category_parent_id_fkey";
ALTER TABLE "region" DROP CONSTRAINT IF EXISTS "region_parent_id_fkey";

-- Drop composite hierarchy indexes
DROP INDEX IF EXISTS "category_parent_id_display_order_idx";
DROP INDEX IF EXISTS "region_parent_id_display_order_idx";

-- Create single-level display order indexes
CREATE INDEX "category_display_order_idx" ON "category"("display_order");
CREATE INDEX "region_display_order_idx" ON "region"("display_order");

-- Drop parent_id columns
ALTER TABLE "category" DROP COLUMN IF EXISTS "parent_id";
ALTER TABLE "region" DROP COLUMN IF EXISTS "parent_id";

-- Add explicit Admin roles while preserving all existing Admin access.
CREATE TYPE "AdminRole" AS ENUM ('SUPER_ADMIN', 'OPERATIONS_ADMIN', 'READ_ONLY_ANALYST');

ALTER TABLE "admin_profile"
  ADD COLUMN "role" "AdminRole" NOT NULL DEFAULT 'SUPER_ADMIN';

CREATE INDEX "admin_profile_role_idx" ON "admin_profile"("role");

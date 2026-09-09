-- AlterTable
ALTER TABLE "vendor_profile" ADD COLUMN "default_filter_preset_id" UUID;

-- AddForeignKey
ALTER TABLE "vendor_profile" ADD CONSTRAINT "vendor_profile_default_filter_preset_id_fkey" FOREIGN KEY ("default_filter_preset_id") REFERENCES "filter_preset"("id") ON DELETE SET NULL ON UPDATE CASCADE;

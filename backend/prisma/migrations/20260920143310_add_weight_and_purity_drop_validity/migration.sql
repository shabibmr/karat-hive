-- Drop the old validity_hours column
ALTER TABLE offer DROP COLUMN validity_hours;

-- Add new columns
ALTER TABLE offer ADD COLUMN weight_grams DECIMAL(10,2) NOT NULL DEFAULT 0;
ALTER TABLE offer ADD COLUMN purity_karat "Karat" NOT NULL DEFAULT '24K'::"Karat";

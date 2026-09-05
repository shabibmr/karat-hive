-- Applied after Prisma migrate (or as a raw SQL migration).
-- Prisma cannot CREATE EXTENSION or GIN/pg_trgm indexes in schema.prisma.

CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pg_trgm;    -- Admin / Vendor fuzzy search (AD-BE-11, C-12)

-- Architecture §12.6: GIN + pg_trgm. No Elasticsearch.

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

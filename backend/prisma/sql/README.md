SQL that Prisma's schema DSL cannot express. Folded into the named init migration `prisma/migrations/20260901120000_init/`. Keep these files as the readable source; do not apply them a second time.

| File                  | Why                                                                                                |
| --------------------- | -------------------------------------------------------------------------------------------------- |
| `extensions.sql`      | `pgcrypto`, `pg_trgm`, GIN search indexes (`AD-BE-11`, C-12)                                       |
| `partial-indexes.sql` | `BR-009` / live subscription partial uniques, expiry sweep partial indexes, job scan indexes; drops the old `validity_hours` CHECK (`adr/0015`) |

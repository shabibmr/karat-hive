# Object storage on Oracle Object Storage (S3 Compatibility), region `ap-hyderabad-1`

Request media, Vendor KYC documents, and export artefacts are stored in **Oracle Cloud Infrastructure Object Storage** through the **S3 Compatibility API** in region **`ap-hyderabad-1`**. Decision date 25 Sep 2026. This supersedes the interim Cloudflare R2 KYC placement in `adr/0012`.

**Why this shape.** Product chose Oracle’s S3-compatible store for all object buckets after R2 proved unable to offer an India or UAE jurisdiction. The tenancy already had CLI access with default region `ap-hyderabad-1` (India Central). That is a real region placement, stronger than R2’s best-effort `apac` hint. Access uses Customer Secret Keys (Access Key ID + Secret Access Key) against:

`https://<namespace>.compat.objectstorage.ap-hyderabad-1.oraclecloud.com`

Three private buckets — `kyc`, `request-media`, `export` — match SRS §7.6 segregation. The backend `ObjectStorage` port is unchanged; only the adapter and env vars change (`Architecture-Backend.md` §15.3). Local/CI still use the disk adapter; non-production without OCI credentials may fall back to Supabase Storage.

**Consequences.**

- Production refuses to boot without `OCI_S3_NAMESPACE`, `OCI_S3_ACCESS_KEY_ID`, and `OCI_S3_SECRET_ACCESS_KEY`.
- SigV4 region is `ap-hyderabad-1` (service `s3`). Bucket location follows the endpoint region; no R2-style `LocationConstraint` body.
- `ap-hyderabad-1` is India, not UAE. It does not close the UAE object-residency bar in `NFR-020`. A later move to `me-abudhabi-1` or `me-dubai-1` remains a region/config change. Production PostgreSQL region remains open.
- Existing objects on Supabase (or any prior R2 trial) are not migrated by this decision. Greenfield buckets only unless a separate copy job is ordered.
- `adr/0008` still describes the S3-compatible port and MinIO for local/CI; the hosted provider for object bytes is now OCI per this ADR.

**Considered and rejected.** Keeping R2 for KYC only while moving other buckets. Staying on Supabase Storage for production. Switching PostgreSQL to Oracle in the same change.

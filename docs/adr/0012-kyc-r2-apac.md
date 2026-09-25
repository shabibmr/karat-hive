# Interim KYC object placement: Cloudflare R2, location hint `apac`

**Status: superseded by `adr/0013` (25 Sep 2026).** Hosted object storage (all buckets) now uses Oracle Object Storage S3 Compatibility in `ap-hyderabad-1`. Kept for history.

Vendor KYC documents (trade licence, Emirates ID, and the other `KYC` bucket objects) were stored in a dedicated **Cloudflare R2** bucket created with location hint **`apac`**. Request media and export artefacts stayed on the existing store. Decision date 25 Sep 2026, from the product instruction to use Cloudflare India for KYC until a stricter residency option exists.

**Why this shape.** `NFR-020` asks for a UAE-consistent region for personal data. R2 does not offer a UAE region, and it does not offer an India jurisdiction either. As of the R2 data-location reference (19 Aug 2026), jurisdictional restrictions are only `eu`, `us`, and `fedramp`. Those are the only settings that guarantee where objects are stored. Location hints are best-effort. Cloudflare's own partner guidance maps Mumbai (`ap-south-1`) and Central India (`centralindia`) to the hint `apac`. That is the closest control R2 exposes for "Cloudflare India".

Regional Services has an India region. It restricts where Cloudflare decrypts HTTPS for a custom hostname. It does not place R2 object bytes in India, and it applies only when a bucket is served through that hostname. This decision does not treat Regional Services as object residency.

**Consequences.**

- Production refuses to boot without `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, and `R2_SECRET_ACCESS_KEY`, so KYC cannot silently remain on Supabase Storage (Seoul, `adr/0009`).
- The S3 endpoint is `https://<ACCOUNT_ID>.r2.cloudflarestorage.com`. No jurisdiction subdomain. A `.eu.` or `.us.` host would address a different set of buckets.
- The adapter creates the KYC bucket once with `<LocationConstraint>apac</LocationConstraint>`. R2 will not move an existing bucket. A bucket created earlier without the hint stays where it was; create a new bucket and point `R2_KYC_BUCKET` at it.
- `apac` is not a promise that bytes stay in India. It does not satisfy the UAE bar in `NFR-020`. Production PostgreSQL region remains open in `Architecture-Backend.md` §22.1.
- When R2 credentials are absent outside production (local development), KYC stays on Supabase and the process logs that fact.

**Considered and rejected.** Claiming an India jurisdiction that R2 does not have. Putting every object (Request images included) on the KYC bucket. Pointing the adapter at AWS `me-central-1` in this change — that remains the path if UAE residency is required later (`adr/0008`).

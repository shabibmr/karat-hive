# Identity masking until Offer acceptance

Customer and Vendor real-world identities stay mutually concealed until the Customer accepts exactly one Offer. Reveal is simultaneous, scoped to the resulting Connection, and irreversible for that introduction. Pre-acceptance contact details in free text are a policy violation and are blocked where detected.

**Why.** Masking is the platform’s core asset: Vendors must compete on price and terms instead of routing the Customer off-platform early, and Customers are not exposed to every Vendor who sees a Request. Server-side enforcement (not client-only hiding) is required so API consumers cannot strip the mask.

**Considered options.** Reveal Vendor identity on Offer; always-visible Vendor profiles; optional Customer anonymity only. Rejected because they collapse competitive pressure or Customer protection.

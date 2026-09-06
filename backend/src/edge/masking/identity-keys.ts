/**
 * Architecture §9.1 / API inventory §4.4. JSON keys that must be absent
 * unless the route is flagged `@RevealsIdentity`. Generic `name` / `id` are
 * omitted — they appear on Categories, Regions, and jobs.
 */
export const IDENTITY_KEYS = new Set([
  'displayName',
  'mobileNumber',
  'mobile',
  'email',
  'photoUrl',
  'tradingName',
  'legalBusinessName',
  'contactPersonName',
  'businessEmail',
  'businessAddress',
  'logoUrl',
  'shopPhotos',
  'tradeLicence',
  'tradeLicenceNumber',
  'oauthSubject',
  'userId',
  'vendorId',
  'customerId',
  'customerName',
  'customerEmail',
  'exactAddress',
  'addressLine1',
  'addressLine2',
  'nationalId',
  'emiratesId',
  'customerProfileId',
  'vendorProfileId',
  'adminProfileId',
  'actorUserId',
  'reporterUserId',
  'reportedUserId',
  'recipientUserId',
  'createdById',
  'verifiedByAdminId',
  // Competitor blindness (BR-008) prohibited keys on masked routes
  'competitorPrice',
  'competitorPrices',
  'competingPrices',
  'winningPrice',
  'winningVendor',
  'winningVendorId',
  'winningVendorName',
  'competitorId',
  'competitorName',
  'competitorVendor',
  'competingVendor',
  'competingVendors',
  'competitorTerms',
  'competingTerms',
  'competitorOffers',
  'competingOffers',
]);

/**
 * Competitor blindness keys (BR-008). Prohibited on any vendor-facing payload.
 */
export const COMPETITOR_KEYS = new Set([
  'competitorPrice',
  'competitorPrices',
  'competingPrices',
  'winningPrice',
  'winningVendor',
  'winningVendorId',
  'winningVendorName',
  'competitorId',
  'competitorName',
  'competitorVendor',
  'competingVendor',
  'competingVendors',
  'competitorTerms',
  'competingTerms',
  'competitorOffers',
  'competingOffers',
]);

export function findIdentityKey(value: unknown, skipMeta = true): string | null {
  return walk(value, IDENTITY_KEYS, skipMeta);
}

export function findCompetitorKey(value: unknown, skipMeta = true): string | null {
  return walk(value, COMPETITOR_KEYS, skipMeta);
}

/**
 * Searches for competitor leaks (BR-008) in vendor-presented payloads,
 * including competitor keys and competing offers arrays.
 */
export function findCompetitorLeak(value: unknown, skipMeta = true): string | null {
  if (value === null || value === undefined) return null;
  if (Array.isArray(value)) {
    for (const item of value) {
      const hit = findCompetitorLeak(item, skipMeta);
      if (hit) return hit;
    }
    return null;
  }
  if (typeof value !== 'object') return null;
  const record = value as Record<string, unknown>;
  for (const [key, child] of Object.entries(record)) {
    if (skipMeta && key === 'meta') continue;
    if (COMPETITOR_KEYS.has(key)) return key;
    // Competing offers array is forbidden on vendor-facing request payloads (BR-008).
    // Note: Vendor's own offer is exposed as `myOffer` (singular object), not `offers` array.
    if (key === 'offers' && (Array.isArray(child) || (child !== null && typeof child === 'object'))) {
      return 'offers';
    }
    const nested = findCompetitorLeak(child, skipMeta);
    if (nested) return nested;
  }
  return null;
}

function walk(value: unknown, keySet: Set<string>, skipMeta: boolean): string | null {
  if (value === null || value === undefined) return null;
  if (Array.isArray(value)) {
    for (const item of value) {
      const hit = walk(item, keySet, skipMeta);
      if (hit) return hit;
    }
    return null;
  }
  if (typeof value !== 'object') return null;
  const record = value as Record<string, unknown>;
  for (const [key, child] of Object.entries(record)) {
    if (skipMeta && key === 'meta') continue;
    if (keySet.has(key)) return key;
    const nested = walk(child, keySet, skipMeta);
    if (nested) return nested;
  }
  return null;
}

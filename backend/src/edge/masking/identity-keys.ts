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
  'exactAddress',
  'addressLine1',
  'nationalId',
  'emiratesId',
]);

export function findIdentityKey(value: unknown, skipMeta = true): string | null {
  return walk(value, skipMeta);
}

function walk(value: unknown, skipMeta: boolean): string | null {
  if (value === null || value === undefined) return null;
  if (Array.isArray(value)) {
    for (const item of value) {
      const hit = walk(item, skipMeta);
      if (hit) return hit;
    }
    return null;
  }
  if (typeof value !== 'object') return null;
  const record = value as Record<string, unknown>;
  for (const [key, child] of Object.entries(record)) {
    if (skipMeta && key === 'meta') continue;
    if (IDENTITY_KEYS.has(key)) return key;
    const nested = key === 'data' ? walk(child, skipMeta) : walk(child, skipMeta);
    if (nested) return nested;
  }
  return null;
}

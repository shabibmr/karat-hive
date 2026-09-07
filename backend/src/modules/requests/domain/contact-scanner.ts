/**
 * Scans free-text fields (notes, vendorNote) for direct contact details per BR-022:
 * phone numbers (7+ digits with or without separators), email addresses, URLs, and messaging handles.
 */
export type ContactScanResult = {
  hasContactInfo: boolean;
  warnings: string[];
};

const EMAIL_REGEX = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/i;
const URL_REGEX = /(?:https?:\/\/|www\.)\S+|\b[A-Za-z0-9.-]+\.(?:com|ae|org|net|io|co|me|xyz|app)\b/i;
const HANDLE_REGEX = /(?:wa\.me\/|t\.me\/|chat\.whatsapp\.com\/|@[a-zA-Z0-9_]{3,})/i;


/** Matches sequences containing potential phone numbers (checks for >= 7 digits). */
function hasPhoneNumber(text: string): boolean {
  // Look for potential phone number patterns with digits and optional punctuation
  const candidateMatches = text.match(/(?:\+?\d[\d\s\-().]{5,}\d|\b\d{7,}\b)/g);
  if (!candidateMatches) return false;
  for (const candidate of candidateMatches) {
    const digitCount = (candidate.match(/\d/g) ?? []).length;
    if (digitCount >= 7) {
      return true;
    }
  }
  return false;
}

export function scanForContactDetails(text: string | null | undefined): ContactScanResult {
  if (!text || !text.trim()) {
    return { hasContactInfo: false, warnings: [] };
  }

  const trimmed = text.trim();
  const detected =
    EMAIL_REGEX.test(trimmed) ||
    URL_REGEX.test(trimmed) ||
    HANDLE_REGEX.test(trimmed) ||
    hasPhoneNumber(trimmed);

  if (detected) {
    return {
      hasContactInfo: true,
      warnings: ['Potential contact details detected in notes. You will not be able to publish until these are removed.'],
    };
  }

  return { hasContactInfo: false, warnings: [] };
}

/** Quiet hours are stored HH:MM and evaluated in Gulf Standard Time (BR-021, C-02). */
const GST_OFFSET_MS = 4 * 60 * 60 * 1000;

function parseHhMm(value: string): number | null {
  const match = /^(\d{2}):(\d{2})$/.exec(value);
  if (!match) return null;
  const hours = Number(match[1]);
  const minutes = Number(match[2]);
  if (hours > 23 || minutes > 59) return null;
  return hours * 60 + minutes;
}

/** Inclusive start, exclusive end. Window may wrap midnight. */
export function isWithinQuietHours(now: Date, startHhMm: string, endHhMm: string): boolean {
  const start = parseHhMm(startHhMm);
  const end = parseHhMm(endHhMm);
  if (start === null || end === null || start === end) return false;

  const gst = new Date(now.getTime() + GST_OFFSET_MS);
  const current = gst.getUTCHours() * 60 + gst.getUTCMinutes();

  if (start < end) {
    return current >= start && current < end;
  }
  return current >= start || current < end;
}

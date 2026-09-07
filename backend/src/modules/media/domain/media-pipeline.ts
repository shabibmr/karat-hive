/**
 * Media ingest pipeline (FR-SYS-009): magic-byte inspect, malware stub,
 * EXIF strip + container rewrite, thumbnail derivative.
 *
 * Pixel-resize needs a decoder; the thumbnail is the EXIF-stripped rewrite
 * stored under a separate key so originals are never served pre-READY.
 */

export type DetectedKind = 'jpeg' | 'png' | 'webp' | 'pdf' | 'unknown';

export type QuarantineReason = 'TYPE_MISMATCH' | 'MALWARE';

export type PipelineResult =
  | {
      action: 'ready';
      kind: DetectedKind;
      cleaned: Buffer;
      makeThumbnail: boolean;
    }
  | {
      action: 'quarantine';
      reason: QuarantineReason;
    };

/** EICAR test file — the malware stub's only positive. */
export const EICAR_SIGNATURE = 'EICAR-STANDARD-ANTIVIRUS-TEST-FILE';

const JPEG_SOI = Buffer.from([0xff, 0xd8]);
const PNG_SIG = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const PDF_SIG = Buffer.from('%PDF');
const MZ_SIG = Buffer.from([0x4d, 0x5a]);
const ELF_SIG = Buffer.from([0x7f, 0x45, 0x4c, 0x46]);

const PNG_DROP_CHUNKS = new Set(['eXIf', 'tEXt', 'zTXt', 'iTXt', 'tIME']);

export function detectKind(bytes: Buffer): DetectedKind {
  if (bytes.length >= 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff) {
    return 'jpeg';
  }
  if (bytes.length >= 8 && bytes.subarray(0, 8).equals(PNG_SIG)) {
    return 'png';
  }
  if (
    bytes.length >= 12 &&
    bytes.toString('ascii', 0, 4) === 'RIFF' &&
    bytes.toString('ascii', 8, 12) === 'WEBP'
  ) {
    return 'webp';
  }
  if (bytes.length >= 4 && bytes.subarray(0, 4).equals(PDF_SIG)) {
    return 'pdf';
  }
  return 'unknown';
}

export function looksLikeExecutable(bytes: Buffer): boolean {
  if (bytes.length >= 2 && bytes.subarray(0, 2).equals(MZ_SIG)) return true;
  if (bytes.length >= 4 && bytes.subarray(0, 4).equals(ELF_SIG)) return true;
  return false;
}

export function declaredKind(contentType: string): DetectedKind | 'any' {
  const mime = contentType.split(';')[0]?.trim().toLowerCase() ?? '';
  if (mime === 'image/jpeg' || mime === 'image/jpg') return 'jpeg';
  if (mime === 'image/png') return 'png';
  if (mime === 'image/webp') return 'webp';
  if (mime === 'application/pdf') return 'pdf';
  return 'any';
}

export function containsMalwareMarker(bytes: Buffer): boolean {
  return bytes.indexOf(EICAR_SIGNATURE) !== -1;
}

export function stripExif(bytes: Buffer, kind: DetectedKind): Buffer {
  switch (kind) {
    case 'jpeg':
      return stripJpegExif(bytes);
    case 'png':
      return stripPngMetadata(bytes);
    case 'webp':
      return stripWebpMetadata(bytes);
    default:
      return bytes;
  }
}

/**
 * Inspect + clean. Quarantine on type mismatch or malware stub hit.
 * Image rewrite is the "re-encode" (container rebuilt without APP/EXIF).
 */
export function processMediaBytes(bytes: Buffer, declaredContentType: string): PipelineResult {
  if (containsMalwareMarker(bytes) || looksLikeExecutable(bytes)) {
    return { action: 'quarantine', reason: 'MALWARE' };
  }

  const detected = detectKind(bytes);
  const declared = declaredKind(declaredContentType);

  if (declared !== 'any' && detected !== declared) {
    return { action: 'quarantine', reason: 'TYPE_MISMATCH' };
  }

  const isImage = detected === 'jpeg' || detected === 'png' || detected === 'webp';
  const cleaned = isImage ? stripExif(bytes, detected) : bytes;
  return {
    action: 'ready',
    kind: detected,
    cleaned,
    makeThumbnail: isImage,
  };
}

function stripJpegExif(input: Buffer): Buffer {
  if (input.length < 4 || !input.subarray(0, 2).equals(JPEG_SOI)) return input;

  const parts: Buffer[] = [JPEG_SOI];
  let i = 2;
  while (i < input.length) {
    const lead = input[i];
    if (lead !== 0xff) {
      parts.push(input.subarray(i));
      break;
    }
    while (i < input.length && input[i] === 0xff) i += 1;
    if (i >= input.length) break;
    const marker = input[i];
    if (marker === undefined) break;
    i += 1;

    if (marker === 0xd9) {
      parts.push(Buffer.from([0xff, 0xd9]));
      break;
    }
    if (marker === 0xda) {
      parts.push(Buffer.from([0xff, 0xda]));
      parts.push(input.subarray(i));
      break;
    }
    if (marker >= 0xd0 && marker <= 0xd7) {
      parts.push(Buffer.from([0xff, marker]));
      continue;
    }
    if (i + 1 >= input.length) break;
    const lenHi = input[i];
    const lenLo = input[i + 1];
    if (lenHi === undefined || lenLo === undefined) break;
    const length = (lenHi << 8) | lenLo;
    const segmentEnd = i + length;
    if (segmentEnd > input.length) break;
    const isApp = marker >= 0xe0 && marker <= 0xef;
    const isCom = marker === 0xfe;
    if (!isApp && !isCom) {
      parts.push(Buffer.from([0xff, marker]));
      parts.push(input.subarray(i, segmentEnd));
    }
    i = segmentEnd;
  }
  return Buffer.concat(parts);
}

function stripPngMetadata(input: Buffer): Buffer {
  if (input.length < 8 || !input.subarray(0, 8).equals(PNG_SIG)) return input;
  const parts: Buffer[] = [PNG_SIG];
  let i = 8;
  while (i + 12 <= input.length) {
    const len = input.readUInt32BE(i);
    const type = input.toString('ascii', i + 4, i + 8);
    const end = i + 12 + len;
    if (end > input.length) break;
    if (!PNG_DROP_CHUNKS.has(type)) {
      parts.push(input.subarray(i, end));
    }
    i = end;
    if (type === 'IEND') break;
  }
  return Buffer.concat(parts);
}

function stripWebpMetadata(input: Buffer): Buffer {
  if (
    input.length < 12 ||
    input.toString('ascii', 0, 4) !== 'RIFF' ||
    input.toString('ascii', 8, 12) !== 'WEBP'
  ) {
    return input;
  }
  const kept: Buffer[] = [];
  let i = 12;
  while (i + 8 <= input.length) {
    const fourcc = input.toString('ascii', i, i + 4);
    const size = input.readUInt32LE(i + 4);
    const padded = size + (size % 2);
    const chunkEnd = i + 8 + padded;
    if (i + 8 + size > input.length) break;
    const sliceEnd = Math.min(chunkEnd, input.length);
    if (fourcc === 'EXIF' || fourcc === 'XMP ') {
      i = sliceEnd;
      continue;
    }
    if (fourcc === 'VP8X' && size >= 1) {
      const copy = Buffer.from(input.subarray(i, sliceEnd));
      const flags = copy[8] ?? 0;
      copy[8] = flags & ~(1 << 3) & ~(1 << 4);
      kept.push(copy);
    } else {
      kept.push(input.subarray(i, sliceEnd));
    }
    i = sliceEnd;
  }
  const body = Buffer.concat(kept);
  const out = Buffer.alloc(12 + body.length);
  out.write('RIFF', 0, 'ascii');
  out.writeUInt32LE(4 + body.length, 4);
  out.write('WEBP', 8, 'ascii');
  body.copy(out, 12);
  return out;
}

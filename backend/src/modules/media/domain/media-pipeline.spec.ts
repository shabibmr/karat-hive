import { describe, expect, it } from 'vitest';
import { EICAR_SIGNATURE, detectKind, processMediaBytes, stripExif } from './media-pipeline';

function jpegWithExif(): Buffer {
  const exifPayload = Buffer.from('Exif\0\0GPS\0home');
  const app1Len = 2 + exifPayload.length;
  return Buffer.concat([
    Buffer.from([0xff, 0xd8]),
    Buffer.from([0xff, 0xe1, (app1Len >> 8) & 0xff, app1Len & 0xff]),
    exifPayload,
    Buffer.from([0xff, 0xdb, 0x00, 0x04, 0x00, 0x01]),
    Buffer.from([0xff, 0xd9]),
  ]);
}

function pngWithExif(): Buffer {
  const sig = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  const ihdrData = Buffer.alloc(13);
  const ihdr = pngChunk('IHDR', ihdrData);
  const exif = pngChunk('eXIf', Buffer.from('GPS-coords'));
  const iend = pngChunk('IEND', Buffer.alloc(0));
  return Buffer.concat([sig, ihdr, exif, iend]);
}

function pngChunk(type: string, data: Buffer): Buffer {
  const buf = Buffer.alloc(12 + data.length);
  buf.writeUInt32BE(data.length, 0);
  buf.write(type, 4, 4, 'ascii');
  data.copy(buf, 8);
  buf.writeUInt32BE(0, 8 + data.length);
  return buf;
}

function webpWithExif(): Buffer {
  const vp8 = Buffer.concat([Buffer.from('VP8 '), Buffer.alloc(4), Buffer.from('frame')]);
  vp8.writeUInt32LE(5, 4);
  const exif = Buffer.concat([Buffer.from('EXIF'), Buffer.alloc(4), Buffer.from('GPS1')]);
  exif.writeUInt32LE(4, 4);
  const body = Buffer.concat([vp8, exif]);
  const out = Buffer.alloc(12 + body.length);
  out.write('RIFF', 0, 'ascii');
  out.writeUInt32LE(4 + body.length, 4);
  out.write('WEBP', 8, 'ascii');
  body.copy(out, 12);
  return out;
}

describe('media pipeline (G2-P02)', () => {
  it('detects jpeg/png/webp/pdf by magic bytes, not extension', () => {
    expect(detectKind(Buffer.from([0xff, 0xd8, 0xff, 0xe0]))).toBe('jpeg');
    expect(detectKind(pngWithExif())).toBe('png');
    expect(detectKind(webpWithExif())).toBe('webp');
    expect(detectKind(Buffer.from('%PDF-1.4\n'))).toBe('pdf');
    expect(detectKind(Buffer.from('MZ'))).toBe('unknown');
  });

  it('quarantines a non-image posing as jpeg (FR-SYS-009.1)', () => {
    const result = processMediaBytes(Buffer.from('%PDF-1.4\n'), 'image/jpeg');
    expect(result).toEqual({ action: 'quarantine', reason: 'TYPE_MISMATCH' });
  });

  it('quarantines jpeg bytes declared as png', () => {
    const result = processMediaBytes(Buffer.from([0xff, 0xd8, 0xff, 0xd9]), 'image/png');
    expect(result.action).toBe('quarantine');
  });

  it('quarantines MZ/ELF executables as malware', () => {
    expect(processMediaBytes(Buffer.from([0x4d, 0x5a, 0x90, 0x00]), 'image/jpeg')).toEqual({
      action: 'quarantine',
      reason: 'MALWARE',
    });
    expect(processMediaBytes(Buffer.from([0x7f, 0x45, 0x4c, 0x46]), 'application/pdf')).toEqual({
      action: 'quarantine',
      reason: 'MALWARE',
    });
  });

  it('quarantines the EICAR malware stub', () => {
    const jpeg = Buffer.concat([
      Buffer.from([0xff, 0xd8, 0xff, 0xd9]),
      Buffer.from(`X5O!P%@AP[4\\PZX54(P^)7CC)7}$${EICAR_SIGNATURE}!$H+H*`),
    ]);
    expect(processMediaBytes(jpeg, 'image/jpeg')).toEqual({
      action: 'quarantine',
      reason: 'MALWARE',
    });
  });

  it('strips JPEG APP1 EXIF including GPS and keeps other segments', () => {
    const raw = jpegWithExif();
    expect(raw.includes('Exif')).toBe(true);
    expect(raw.includes('GPS')).toBe(true);
    const cleaned = stripExif(raw, 'jpeg');
    expect(cleaned.subarray(0, 2).equals(Buffer.from([0xff, 0xd8]))).toBe(true);
    expect(cleaned.includes('Exif')).toBe(false);
    expect(cleaned.includes('GPS')).toBe(false);
    expect(cleaned[cleaned.length - 2]).toBe(0xff);
    expect(cleaned[cleaned.length - 1]).toBe(0xd9);
  });

  it('drops PNG eXIf / text chunks', () => {
    const raw = pngWithExif();
    expect(raw.includes('eXIf')).toBe(true);
    expect(raw.includes('GPS-coords')).toBe(true);
    const cleaned = stripExif(raw, 'png');
    expect(cleaned.includes('eXIf')).toBe(false);
    expect(cleaned.includes('GPS-coords')).toBe(false);
    expect(cleaned.includes('IHDR')).toBe(true);
    expect(cleaned.includes('IEND')).toBe(true);
  });

  it('drops WEBP EXIF chunk', () => {
    const raw = webpWithExif();
    expect(raw.includes('EXIF')).toBe(true);
    const cleaned = stripExif(raw, 'webp');
    expect(cleaned.includes('EXIF')).toBe(false);
    expect(cleaned.toString('ascii', 8, 12)).toBe('WEBP');
    expect(cleaned.includes('VP8 ')).toBe(true);
  });

  it('marks a clean jpeg ready with a thumbnail derivative', () => {
    const result = processMediaBytes(jpegWithExif(), 'image/jpeg');
    expect(result.action).toBe('ready');
    if (result.action !== 'ready') return;
    expect(result.kind).toBe('jpeg');
    expect(result.makeThumbnail).toBe(true);
    expect(result.cleaned.includes('Exif')).toBe(false);
  });

  it('marks a clean PDF ready without a thumbnail', () => {
    const result = processMediaBytes(Buffer.from('%PDF-1.4\n%EOF\n'), 'application/pdf');
    expect(result).toMatchObject({
      action: 'ready',
      kind: 'pdf',
      makeThumbnail: false,
    });
  });
});

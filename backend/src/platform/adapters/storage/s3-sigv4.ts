import { createHash, createHmac } from 'node:crypto';

/** AWS SigV4 for S3-compatible APIs (Oracle Object Storage, R2, MinIO). */
export interface SigV4Identity {
  accessKeyId: string;
  secretAccessKey: string;
  region: string;
  service: string;
}

export function sha256Hex(body: string | Uint8Array): string {
  return createHash('sha256').update(body).digest('hex');
}

/** Encode a path or query component the way SigV4 requires. */
export function awsUriEncode(value: string, encodeSlash = true): string {
  let encoded = '';
  for (const byte of Buffer.from(value, 'utf8')) {
    const ch = String.fromCharCode(byte);
    if (
      (byte >= 0x41 && byte <= 0x5a) ||
      (byte >= 0x61 && byte <= 0x7a) ||
      (byte >= 0x30 && byte <= 0x39) ||
      ch === '_' ||
      ch === '-' ||
      ch === '~' ||
      ch === '.' ||
      (!encodeSlash && ch === '/')
    ) {
      encoded += ch;
    } else {
      encoded += `%${byte.toString(16).toUpperCase().padStart(2, '0')}`;
    }
  }
  return encoded;
}

function hmac(key: Buffer | string, data: string): Buffer {
  return createHmac('sha256', key).update(data, 'utf8').digest();
}

function signingKey(secret: string, dateStamp: string, region: string, service: string): Buffer {
  const dateKey = hmac(`AWS4${secret}`, dateStamp);
  const regionKey = hmac(dateKey, region);
  const serviceKey = hmac(regionKey, service);
  return hmac(serviceKey, 'aws4_request');
}

function canonicalQuery(url: URL): string {
  const pairs: Array<[string, string]> = [];
  url.searchParams.forEach((value, key) => {
    pairs.push([awsUriEncode(key), awsUriEncode(value)]);
  });
  pairs.sort((a, b) => (a[0] === b[0] ? (a[1] < b[1] ? -1 : 1) : a[0] < b[0] ? -1 : 1));
  return pairs.map(([key, value]) => `${key}=${value}`).join('&');
}

function canonicalHeaders(headers: Record<string, string>): { canonical: string; signed: string } {
  const normalised = Object.entries(headers).map(
    ([key, value]) => [key.toLowerCase(), value.trim().replace(/\s+/g, ' ')] as const,
  );
  normalised.sort((a, b) => (a[0] < b[0] ? -1 : 1));
  return {
    canonical: normalised.map(([key, value]) => `${key}:${value}\n`).join(''),
    signed: normalised.map(([key]) => key).join(';'),
  };
}

export function formatAmzDate(now: Date): { amzDate: string; dateStamp: string } {
  const amzDate = now.toISOString().replace(/[:-]|\.\d{3}/g, '');
  return { amzDate, dateStamp: amzDate.slice(0, 8) };
}

export function signHeaders(
  identity: SigV4Identity,
  input: {
    method: string;
    url: URL;
    headers: Record<string, string>;
    body: string | Uint8Array;
    now: Date;
  },
): Record<string, string> {
  const payloadHash = sha256Hex(input.body);
  const { amzDate, dateStamp } = formatAmzDate(input.now);
  // Oracle Object Storage requires x-amz-date in SignedHeaders; include it before signing.
  const headers = {
    ...input.headers,
    'x-amz-content-sha256': payloadHash,
    'x-amz-date': amzDate,
  };
  const { canonical, signed } = canonicalHeaders(headers);
  const canonicalRequest = [
    input.method,
    awsUriEncode(decodeURIComponent(input.url.pathname), false),
    canonicalQuery(input.url),
    canonical,
    signed,
    payloadHash,
  ].join('\n');
  const scope = `${dateStamp}/${identity.region}/${identity.service}/aws4_request`;
  const stringToSign = `AWS4-HMAC-SHA256\n${amzDate}\n${scope}\n${sha256Hex(canonicalRequest)}`;
  const signature = createHmac(
    'sha256',
    signingKey(identity.secretAccessKey, dateStamp, identity.region, identity.service),
  )
    .update(stringToSign, 'utf8')
    .digest('hex');
  const authorization = `AWS4-HMAC-SHA256 Credential=${identity.accessKeyId}/${scope}, SignedHeaders=${signed}, Signature=${signature}`;
  return { ...headers, Authorization: authorization };
}

/** Query-string signature. Payload is UNSIGNED-PAYLOAD (presigned GET/PUT). */
export function presign(
  identity: SigV4Identity,
  input: {
    method: string;
    url: URL;
    signedHeaderNames: string[];
    headers: Record<string, string>;
    expiresSeconds: number;
    now: Date;
  },
): string {
  const { amzDate, dateStamp } = formatAmzDate(input.now);
  const scope = `${dateStamp}/${identity.region}/${identity.service}/aws4_request`;
  const url = new URL(input.url.toString());
  url.searchParams.set('X-Amz-Algorithm', 'AWS4-HMAC-SHA256');
  url.searchParams.set('X-Amz-Credential', `${identity.accessKeyId}/${scope}`);
  url.searchParams.set('X-Amz-Date', amzDate);
  url.searchParams.set('X-Amz-Expires', String(input.expiresSeconds));
  url.searchParams.set(
    'X-Amz-SignedHeaders',
    input.signedHeaderNames
      .map((name) => name.toLowerCase())
      .sort()
      .join(';'),
  );
  const headerBlock: Record<string, string> = {};
  for (const name of input.signedHeaderNames) {
    const value = input.headers[name] ?? input.headers[name.toLowerCase()];
    if (value === undefined) throw new Error(`Missing signed header ${name}`);
    headerBlock[name.toLowerCase()] = value;
  }
  const { canonical, signed } = canonicalHeaders(headerBlock);
  const canonicalRequest = [
    input.method,
    awsUriEncode(decodeURIComponent(url.pathname), false),
    canonicalQuery(url),
    canonical,
    signed,
    'UNSIGNED-PAYLOAD',
  ].join('\n');
  const stringToSign = `AWS4-HMAC-SHA256\n${amzDate}\n${scope}\n${sha256Hex(canonicalRequest)}`;
  const signature = createHmac(
    'sha256',
    signingKey(identity.secretAccessKey, dateStamp, identity.region, identity.service),
  )
    .update(stringToSign, 'utf8')
    .digest('hex');
  url.searchParams.set('X-Amz-Signature', signature);
  return url.toString();
}

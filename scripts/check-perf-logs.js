#!/usr/bin/env node
/**
 * Reads the `perf_logs` Firestore collection (docs/Request-Perf-Logging-Plan.md)
 * and prints the timing breakdown for flows recorded after trying the app's
 * UI with PERF_LOG=true / KH_PERF_LOG=true.
 *
 * Usage:
 *   node scripts/check-perf-logs.js [--flow=request.publish] [--limit=20] [--since=30] [--json]
 *
 *   --flow=<name>   only show this flow (e.g. request.publish, request.open_draft)
 *   --limit=<n>     max documents to fetch, newest first (default 25)
 *   --since=<mins>  only docs created in the last N minutes
 *   --json          dump raw decoded docs instead of the table
 *
 * Reads over the public Firestore REST API (no service-account key needed —
 * the project's rules currently allow open reads/creates on perf_logs, same
 * as app_config/environment, which the deploy scripts already rely on).
 */

const PROJECT_ID = 'karat-hive-app';
const BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

function parseArgs(argv) {
  const out = { limit: 25 };
  for (const arg of argv) {
    if (arg === '--json') out.json = true;
    else if (arg.startsWith('--flow=')) out.flow = arg.slice('--flow='.length);
    else if (arg.startsWith('--limit=')) out.limit = Number(arg.slice('--limit='.length));
    else if (arg.startsWith('--since=')) out.sinceMins = Number(arg.slice('--since='.length));
  }
  return out;
}

// Decode a single Firestore REST "Value" object into a plain JS value.
function decodeValue(v) {
  if (v == null) return null;
  if ('stringValue' in v) return v.stringValue;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('doubleValue' in v) return v.doubleValue;
  if ('booleanValue' in v) return v.booleanValue;
  if ('nullValue' in v) return null;
  if ('timestampValue' in v) return v.timestampValue;
  if ('arrayValue' in v) return (v.arrayValue.values || []).map(decodeValue);
  if ('mapValue' in v) return decodeFields(v.mapValue.fields || {});
  return null;
}

function decodeFields(fields) {
  const out = {};
  for (const [k, v] of Object.entries(fields)) out[k] = decodeValue(v);
  return out;
}

async function fetchPerfLogs(limit) {
  const body = {
    structuredQuery: {
      from: [{ collectionId: 'perf_logs' }],
      orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }],
      limit,
    },
  };
  const res = await fetch(`${BASE}:runQuery`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    throw new Error(`Firestore runQuery failed: ${res.status} ${await res.text()}`);
  }
  const rows = await res.json();
  return rows
    .filter((r) => r.document)
    .map((r) => ({
      id: r.document.name.split('/').pop(),
      ...decodeFields(r.document.fields || {}),
    }));
}

function fmtMs(ms) {
  if (ms == null) return '-';
  return `${ms}ms`;
}

function printTable(docs) {
  if (docs.length === 0) {
    console.log('No perf_logs documents found. Enable perf logging '
      + '(PERF_LOG=true on the backend, run the app in debug or with '
      + '--dart-define=KH_PERF_LOG=true) and try the flow in the UI first.');
    return;
  }
  for (const doc of docs) {
    const flow = doc.flow ?? '(unknown flow)';
    const total = fmtMs(doc.totalMs);
    const platform = doc.platform ?? '?';
    const outcome = doc.outcome ?? doc.fields?.outcome ?? '';
    const when = doc.createdAt ?? '';
    console.log(`\n=== ${flow} — ${total} — ${platform}${outcome ? ` — ${outcome}` : ''} ===`);
    console.log(`  doc:        ${doc.id}`);
    console.log(`  createdAt:  ${when}`);
    if (doc.requestId) console.log(`  requestId:  ${doc.requestId}`);

    const phases = doc.phases && typeof doc.phases === 'object' ? doc.phases : null;
    if (phases && Object.keys(phases).length > 0) {
      console.log('  phases:');
      const entries = Object.entries(phases).sort((a, b) => (b[1] ?? 0) - (a[1] ?? 0));
      const widest = Math.max(...entries.map(([k]) => k.length));
      for (const [phase, ms] of entries) {
        console.log(`    ${phase.padEnd(widest)}  ${fmtMs(ms)}`);
      }
    }

    const skipKeys = new Set([
      'flow', 'platform', 'appFlavor', 'createdAt', 'totalMs', 'phases', 'requestId', 'outcome',
    ]);
    const extras = Object.entries(doc).filter(([k]) => !skipKeys.has(k) && k !== 'id');
    if (extras.length > 0) {
      console.log('  other fields:');
      for (const [k, v] of extras) {
        console.log(`    ${k}: ${Array.isArray(v) ? v.join(', ') : v}`);
      }
    }
  }
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  let docs = await fetchPerfLogs(args.limit);

  if (args.flow) docs = docs.filter((d) => d.flow === args.flow);

  if (args.sinceMins != null && !Number.isNaN(args.sinceMins)) {
    const cutoff = Date.now() - args.sinceMins * 60_000;
    docs = docs.filter((d) => d.createdAt && new Date(d.createdAt).getTime() >= cutoff);
  }

  if (args.json) {
    console.log(JSON.stringify(docs, null, 2));
    return;
  }

  printTable(docs);

  if (docs.length > 1) {
    const withTotal = docs.filter((d) => typeof d.totalMs === 'number');
    if (withTotal.length > 0) {
      const byFlow = new Map();
      for (const d of withTotal) {
        if (!byFlow.has(d.flow)) byFlow.set(d.flow, []);
        byFlow.get(d.flow).push(d.totalMs);
      }
      console.log('\n=== summary (avg total ms per flow) ===');
      for (const [flow, totals] of byFlow) {
        const avg = Math.round(totals.reduce((a, b) => a + b, 0) / totals.length);
        console.log(`  ${flow}: avg=${avg}ms  n=${totals.length}  min=${Math.min(...totals)}  max=${Math.max(...totals)}`);
      }
    }
  }
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});

#!/usr/bin/env node
/**
 * Seeds or updates the app_config/environment document in Firestore with API base URLs.
 *
 * Supports:
 *  - Service Account key JSON (via --service-account, GOOGLE_APPLICATION_CREDENTIALS, or FIREBASE_SERVICE_ACCOUNT_KEY)
 *  - OAuth2 Bearer token (via --token, GOOGLE_ACCESS_TOKEN, or FIREBASE_TOKEN)
 *  - gcloud CLI auto-detection (executes `gcloud auth print-access-token` if available)
 *  - Unauthenticated direct write attempt (for open rules or emulator)
 *
 * Usage:
 *  node scripts/seed-firestore-env.js [options]
 *
 * Options:
 *  --project <id>          Firebase Project ID (default: karat-hive-app)
 *  --dev-url <url>         API base URL for dev (default: https://algoray.tech/kh_api)
 *  --staging-url <url>     API base URL for staging (default: https://staging.algoray.tech/kh_api)
 *  --prod-url <url>        API base URL for prod (default: https://algoray.tech/kh_api)
 *  --service-account <path> Path to GCP service account key JSON file
 *  --token <token>         OAuth2 access token
 *  --help                  Show help message
 */

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execSync } from 'node:child_process';

const args = process.argv.slice(2);

function getArg(flag, defaultValue) {
  const idx = args.indexOf(flag);
  if (idx !== -1 && idx + 1 < args.length) {
    return args[idx + 1];
  }
  return defaultValue;
}

if (args.includes('--help') || args.includes('-h')) {
  console.log(`
Usage: node scripts/seed-firestore-env.js [options]

Seeds or updates the app_config/environment document in Firestore.

Options:
  --project <id>           Firebase project ID (default: karat-hive-app)
  --dev-url <url>          Dev API URL (default: https://algoray.tech/kh_api)
  --staging-url <url>      Staging API URL (default: https://staging.algoray.tech/kh_api)
  --prod-url <url>         Prod API URL (default: https://algoray.tech/kh_api)
  --service-account <file> Path to GCP/Firebase service account JSON key
  --token <token>          OAuth2 Bearer token (from gcloud or Firebase CLI)
  -h, --help               Show this help message
`);
  process.exit(0);
}

const projectId = getArg('--project', process.env.FIREBASE_PROJECT_ID || 'karat-hive-app');
const devUrl = getArg('--dev-url', 'https://algoray.tech/kh_api');
const stagingUrl = getArg('--staging-url', 'https://staging.algoray.tech/kh_api');
const prodUrl = getArg('--prod-url', 'https://algoray.tech/kh_api');
const saPath = getArg('--service-account', process.env.GOOGLE_APPLICATION_CREDENTIALS || process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
let token = getArg('--token', process.env.GOOGLE_ACCESS_TOKEN || process.env.FIREBASE_TOKEN);

console.log('============================================================');
console.log(' Seeding Firestore app_config/environment');
console.log(` Project ID : ${projectId}`);
console.log(` Dev URL    : ${devUrl}`);
console.log(` Staging URL: ${stagingUrl}`);
console.log(` Prod URL   : ${prodUrl}`);
console.log('============================================================');

/**
 * Generates an OAuth2 access token from a service account JSON file using Node built-in crypto.
 */
async function getAccessTokenFromServiceAccount(keyFilePath) {
  const resolvedPath = path.resolve(process.cwd(), keyFilePath);
  if (!fs.existsSync(resolvedPath)) {
    throw new Error(`Service account file not found: ${resolvedPath}`);
  }
  const sa = JSON.parse(fs.readFileSync(resolvedPath, 'utf8'));

  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const claimSet = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/datastore',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };

  const b64Header = Buffer.from(JSON.stringify(header)).toString('base64url');
  const b64ClaimSet = Buffer.from(JSON.stringify(claimSet)).toString('base64url');
  const signatureInput = `${b64Header}.${b64ClaimSet}`;

  const signer = crypto.createSign('RSA-SHA256');
  signer.update(signatureInput);
  const signature = signer.sign(sa.private_key, 'base64url');
  const assertion = `${signatureInput}.${signature}`;

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Failed to exchange service account JWT for token: ${response.status} ${errorText}`);
  }

  const data = await response.json();
  return data.access_token;
}

/**
 * Attempts to obtain an access token from gcloud if available.
 */
function tryGetGcloudToken() {
  try {
    const stdout = execSync('gcloud auth print-access-token', {
      stdio: ['ignore', 'pipe', 'ignore'],
      encoding: 'utf8',
    });
    const t = stdout.trim();
    if (t) return t;
  } catch {
    // Ignore gcloud failure
  }
  return null;
}

async function main() {
  if (!token && saPath) {
    console.log(`Using Service Account credentials from: ${saPath}`);
    try {
      token = await getAccessTokenFromServiceAccount(saPath);
      console.log('Obtained Google OAuth2 access token successfully.');
    } catch (e) {
      console.error(`Error resolving service account: ${e.message}`);
      process.exit(1);
    }
  }

  if (!token) {
    const gcloudToken = tryGetGcloudToken();
    if (gcloudToken) {
      console.log('Obtained token from gcloud CLI.');
      token = gcloudToken;
    }
  }

  const endpoint = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/app_config/environment`;

  const body = {
    fields: {
      api_base_url_dev: { stringValue: devUrl },
      api_base_url_staging: { stringValue: stagingUrl },
      api_base_url_prod: { stringValue: prodUrl },
    },
  };

  const headers = {
    'Content-Type': 'application/json',
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  console.log(`Sending PATCH request to ${endpoint}...`);
  const response = await fetch(endpoint, {
    method: 'PATCH',
    headers,
    body: JSON.stringify(body),
  });

  const responseData = await response.json();

  if (!response.ok) {
    console.error(`\n[ERROR] Firestore update failed (HTTP ${response.status}):`);
    console.error(JSON.stringify(responseData, null, 2));

    if (response.status === 403) {
      console.error(`
------------------------------------------------------------
PERMISSION_DENIED EXPLANATION & RESOLUTION:
------------------------------------------------------------
Firestore rejected the request because write permissions require authentication.
To update Firestore, use one of the following methods:

1. SERVICE ACCOUNT (Recommended):
   Download a Service Account key for project '${projectId}' from:
   Firebase Console -> Project Settings -> Service accounts -> Generate new private key
   Then run:
   node scripts/seed-firestore-env.js --service-account /path/to/service-account.json

2. GOOGLE ACCESS TOKEN:
   Generate an access token using gcloud:
   gcloud auth print-access-token
   Then run:
   node scripts/seed-firestore-env.js --token <YOUR_TOKEN>

3. FIREBASE RULES:
   If this is non-production, ensure firestore.rules allows writing app_config/environment,
   or edit the document directly in Firebase Console:
   Firestore Database -> app_config -> environment
------------------------------------------------------------
`);
    }
    process.exit(1);
  }

  console.log('\n==> SUCCESS! Firestore document written:');
  console.log(JSON.stringify(responseData, null, 2));
}

main().catch((err) => {
  console.error(`Fatal error: ${err.message}`);
  process.exit(1);
});

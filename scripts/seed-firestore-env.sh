#!/usr/bin/env bash
# Seeds or updates app_config/environment in Firestore with API base URLs.
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-karat-hive-app}"
DEV_URL="${DEV_URL:-https://algoray.tech/kh_api}"
STAGING_URL="${STAGING_URL:-https://staging.algoray.tech/kh_api}"
PROD_URL="${PROD_URL:-https://algoray.tech/kh_api}"
TOKEN="${GOOGLE_ACCESS_TOKEN:-${FIREBASE_TOKEN:-}}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Seeds or updates app_config/environment document in Firestore.

Options:
  --project <id>       Firebase project ID (default: karat-hive-app)
  --dev-url <url>      Dev API base URL (default: https://algoray.tech/kh_api)
  --staging-url <url>  Staging API base URL (default: https://staging.algoray.tech/kh_api)
  --prod-url <url>     Prod API base URL (default: https://algoray.tech/kh_api)
  --token <token>      Google/Firebase OAuth2 access token
  -h, --help           Show this help message

Environment variables:
  PROJECT_ID, DEV_URL, STAGING_URL, PROD_URL, GOOGLE_ACCESS_TOKEN, FIREBASE_TOKEN
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ID="$2"; shift 2 ;;
    --dev-url) DEV_URL="$2"; shift 2 ;;
    --staging-url) STAGING_URL="$2"; shift 2 ;;
    --prod-url) PROD_URL="$2"; shift 2 ;;
    --token) TOKEN="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

echo "============================================================"
echo " Seeding Firestore app_config/environment"
echo " Project ID : ${PROJECT_ID}"
echo " Dev URL    : ${DEV_URL}"
echo " Staging URL: ${STAGING_URL}"
echo " Prod URL   : ${PROD_URL}"
echo "============================================================"

# Auto-detect gcloud token if not provided
if [[ -z "${TOKEN}" ]] && command -v gcloud &>/dev/null; then
  echo "Attempting to retrieve token from gcloud CLI..."
  TOKEN="$(gcloud auth print-access-token 2>/dev/null || true)"
fi

ENDPOINT="https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/app_config/environment"

BODY=$(cat <<EOF
{
  "fields": {
    "api_base_url_dev": { "stringValue": "${DEV_URL}" },
    "api_base_url_staging": { "stringValue": "${STAGING_URL}" },
    "api_base_url_prod": { "stringValue": "${PROD_URL}" }
  }
}
EOF
)

HEADERS=(-H "Content-Type: application/json")
if [[ -n "${TOKEN}" ]]; then
  HEADERS+=(-H "Authorization: Bearer ${TOKEN}")
fi

HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" -X PATCH "${ENDPOINT}" "${HEADERS[@]}" -d "${BODY}")
HTTP_CODE=$(echo "${HTTP_RESPONSE}" | tail -n1)
RESPONSE_BODY=$(echo "${HTTP_RESPONSE}" | sed '$d')

if [[ "${HTTP_CODE}" -ge 200 && "${HTTP_CODE}" -lt 300 ]]; then
  echo "==> Success! Document written to ${PROJECT_ID}:"
  echo "${RESPONSE_BODY}"
else
  echo "[ERROR] Request failed with HTTP ${HTTP_CODE}:" >&2
  echo "${RESPONSE_BODY}" >&2
  exit 1
fi

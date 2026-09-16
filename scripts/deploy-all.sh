#!/usr/bin/env bash
# Build and deploy Karat Hive: backend (kh_api), Admin Portal (hive_admin),
# and karat_hive web. Flutter web builds run sequentially to avoid lock conflicts.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="${REPO_ROOT}/backend"
ADMIN_DIR="${REPO_ROOT}/apps/kh_admin"
KARAT_DIR="${REPO_ROOT}/apps/kh_mobile/karat_hive"

DEPLOY_ROOT="${DEPLOY_ROOT:-/var/www/html/algo_cloud}"
BACKUP_ROOT="${BACKUP_ROOT:-/root/deploy_backups}"
PM2_APP="${PM2_APP:-kh-api}"
API_HEALTH_LOCAL="${API_HEALTH_LOCAL:-http://127.0.0.1:3007/v1/platform-config}"
API_HEALTH_PUBLIC="${API_HEALTH_PUBLIC:-https://algoray.cloud/kh_api/v1/platform-config}"
PUBLIC_ADMIN="${PUBLIC_ADMIN:-https://algoray.cloud/hive_admin/}"
PUBLIC_KARAT="${PUBLIC_KARAT:-https://algoray.cloud/karat_hive/}"
KH_API_BASE="${KH_API_BASE:-https://algoray.cloud/kh_api}"
KH_FLAVOR="${KH_FLAVOR:-prod}"

DO_BACKEND=1
DO_ADMIN=1
DO_KARAT=1
DO_BUILD=1
DO_DEPLOY=1
SKIP_MIGRATE=0
SKIP_NPM_CI=0
TS="$(date +%Y%m%d_%H%M%S)"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Build and deploy all three Karat Hive surfaces to ${DEPLOY_ROOT}:
  backend      → ${DEPLOY_ROOT}/kh_api   (pm2: ${PM2_APP})
  admin        → ${DEPLOY_ROOT}/hive_admin
  karat_hive   → ${DEPLOY_ROOT}/karat_hive

Flutter web builds run one after another (safer; avoids Flutter lock races).

Options:
  --backend-only       Only backend
  --admin-only         Only Admin Portal web
  --karat-hive-only    Only karat_hive web
  --skip-build         Deploy existing artifacts only (no compile)
  --skip-deploy        Build only (no rsync / pm2)
  --skip-migrate       Skip prisma migrate deploy
  --skip-npm-ci        Skip npm ci on the deploy host
  -h, --help           Show this help

Environment:
  DEPLOY_ROOT, BACKUP_ROOT, PM2_APP, KH_API_BASE, KH_FLAVOR
  API_HEALTH_LOCAL, API_HEALTH_PUBLIC, PUBLIC_ADMIN, PUBLIC_KARAT

Examples:
  $(basename "$0")
  $(basename "$0") --backend-only
  $(basename "$0") --skip-build          # redeploy last build artifacts
  $(basename "$0") --skip-deploy         # compile only
EOF
  exit 0
}

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    --backend-only) DO_BACKEND=1; DO_ADMIN=0; DO_KARAT=0; shift ;;
    --admin-only) DO_BACKEND=0; DO_ADMIN=1; DO_KARAT=0; shift ;;
    --karat-hive-only) DO_BACKEND=0; DO_ADMIN=0; DO_KARAT=1; shift ;;
    --skip-build) DO_BUILD=0; shift ;;
    --skip-deploy) DO_DEPLOY=0; shift ;;
    --skip-migrate) SKIP_MIGRATE=1; shift ;;
    --skip-npm-ci) SKIP_NPM_CI=1; shift ;;
    *) die "Unknown option: $1 (try --help)" ;;
  esac
done

if [[ "${DO_BUILD}" -eq 0 && "${DO_DEPLOY}" -eq 0 ]]; then
  die "Nothing to do: both --skip-build and --skip-deploy were set"
fi

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

require_cmd rsync
if [[ "${DO_DEPLOY}" -eq 1 ]]; then
  require_cmd curl
  [[ -d "${DEPLOY_ROOT}" ]] || die "Deploy root missing: ${DEPLOY_ROOT}"
  mkdir -p "${BACKUP_ROOT}"
fi

http_code() {
  curl -sS -o /dev/null -w '%{http_code}' --max-time 15 "$1" 2>/dev/null || echo "000"
}

wait_http_ok() {
  local url="$1"
  local label="$2"
  local attempts="${3:-20}"
  local sleep_s="${4:-3}"
  local i code
  for ((i = 1; i <= attempts; i++)); do
    code="$(http_code "${url}")"
    if [[ "${code}" == "200" ]]; then
      log "${label}: HTTP 200"
      return 0
    fi
    log "${label}: attempt ${i}/${attempts} → HTTP ${code}; retry in ${sleep_s}s"
    sleep "${sleep_s}"
  done
  die "${label}: never reached HTTP 200 (${url})"
}

# ---------------------------------------------------------------------------
# Backend
# ---------------------------------------------------------------------------
build_backend() {
  log "Building backend"
  cd "${BACKEND_DIR}"
  if [[ ! -d node_modules ]]; then
    npm ci
  fi
  npm run build
  [[ -f dist/main.js ]] || die "backend build missing dist/main.js"
}

deploy_backend() {
  local dest="${DEPLOY_ROOT}/kh_api"
  [[ -d "${dest}" ]] || die "Backend deploy dir missing: ${dest}"
  [[ -f "${BACKEND_DIR}/dist/main.js" ]] || die "No backend dist; run without --skip-build"

  log "Backing up kh_api artifacts → ${BACKUP_ROOT}/kh_api_*_${TS}"
  [[ -d "${dest}/dist" ]] && cp -a "${dest}/dist" "${BACKUP_ROOT}/kh_api_dist_${TS}"
  [[ -d "${dest}/prisma" ]] && cp -a "${dest}/prisma" "${BACKUP_ROOT}/kh_api_prisma_${TS}"
  [[ -f "${dest}/package.json" ]] && cp -a "${dest}/package.json" "${BACKUP_ROOT}/kh_api_package_${TS}.json"
  [[ -f "${dest}/package-lock.json" ]] && cp -a "${dest}/package-lock.json" "${BACKUP_ROOT}/kh_api_package-lock_${TS}.json"

  log "Syncing dist / package manifests / prisma (preserving .env and start.sh)"
  rsync -a --delete "${BACKEND_DIR}/dist/" "${dest}/dist/"
  cp -a "${BACKEND_DIR}/package.json" "${dest}/package.json"
  cp -a "${BACKEND_DIR}/package-lock.json" "${dest}/package-lock.json"
  rsync -a --delete "${BACKEND_DIR}/prisma/" "${dest}/prisma/"

  cd "${dest}"
  if [[ "${SKIP_NPM_CI}" -eq 0 ]]; then
    log "npm ci --omit=dev"
    npm ci --omit=dev
  else
    log "Skipping npm ci"
  fi

  log "prisma generate"
  npx prisma generate

  if [[ "${SKIP_MIGRATE}" -eq 0 ]]; then
    log "prisma migrate deploy"
    # Redact DB password if migrate prints the URL
    npx prisma migrate deploy 2>&1 | sed -E 's/(postgresql:\/\/[^:]+:)[^@]+(@)/\1***\2/g'
  else
    log "Skipping prisma migrate deploy"
  fi

  chown -R www-data:www-data \
    "${dest}/dist" \
    "${dest}/prisma" \
    "${dest}/package.json" \
    "${dest}/package-lock.json" \
    "${dest}/node_modules" 2>/dev/null || true

  require_cmd pm2
  log "pm2 restart ${PM2_APP}"
  pm2 restart "${PM2_APP}"
  wait_http_ok "${API_HEALTH_LOCAL}" "kh-api local health" 20 3
  log "kh-api public: HTTP $(http_code "${API_HEALTH_PUBLIC}")"
}

# ---------------------------------------------------------------------------
# Flutter web surfaces
# ---------------------------------------------------------------------------
build_admin() {
  log "Building Admin Portal (Flutter web) — sequential"
  export BASE_HREF="/hive_admin/"
  export KH_API_BASE
  export KH_FLAVOR
  bash "${ADMIN_DIR}/build_web.sh"
  [[ -f "${ADMIN_DIR}/build/web/index.html" ]] || die "admin build missing index.html"
}

build_karat() {
  log "Building karat_hive (Flutter web) — sequential"
  export BASE_HREF="/karat_hive/"
  export KH_API_BASE
  export KH_API_BASE_URL="${KH_API_BASE}"
  export KH_FLAVOR
  bash "${KARAT_DIR}/build_web.sh"
  [[ -f "${KARAT_DIR}/build/web/index.html" ]] || die "karat_hive build missing index.html"
}

deploy_web_app() {
  local name="$1"
  local src="$2"
  local dest="$3"
  local public_url="$4"

  [[ -d "${src}" ]] || die "Missing build output: ${src}"
  [[ -d "${dest}" ]] || mkdir -p "${dest}"

  log "Backing up ${name} → ${BACKUP_ROOT}/${name}_${TS}"
  if [[ -d "${dest}" ]] && [[ -n "$(ls -A "${dest}" 2>/dev/null || true)" ]]; then
    cp -a "${dest}" "${BACKUP_ROOT}/${name}_${TS}"
  fi

  log "rsync ${name} → ${dest}"
  rsync -a --delete "${src}/" "${dest}/"
  chown -R www-data:www-data "${dest}"

  local code
  code="$(http_code "${public_url}")"
  log "${name} public: HTTP ${code} (${public_url})"
  [[ "${code}" == "200" ]] || die "${name} did not return HTTP 200"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
echo "============================================================"
echo " Karat Hive deploy-all"
echo "============================================================"
echo " Repo        : ${REPO_ROOT}"
echo " Deploy root : ${DEPLOY_ROOT}"
echo " Backup root : ${BACKUP_ROOT}"
echo " Timestamp   : ${TS}"
echo " Surfaces    : backend=${DO_BACKEND} admin=${DO_ADMIN} karat_hive=${DO_KARAT}"
echo " Build/Deploy: build=${DO_BUILD} deploy=${DO_DEPLOY}"
echo " API base    : ${KH_API_BASE}"
echo "============================================================"

if [[ "${DO_BACKEND}" -eq 1 ]]; then
  [[ "${DO_BUILD}" -eq 1 ]] && build_backend
  [[ "${DO_DEPLOY}" -eq 1 ]] && deploy_backend
fi

if [[ "${DO_ADMIN}" -eq 1 ]]; then
  [[ "${DO_BUILD}" -eq 1 ]] && build_admin
  [[ "${DO_DEPLOY}" -eq 1 ]] && deploy_web_app \
    "hive_admin" \
    "${ADMIN_DIR}/build/web" \
    "${DEPLOY_ROOT}/hive_admin" \
    "${PUBLIC_ADMIN}"
fi

if [[ "${DO_KARAT}" -eq 1 ]]; then
  [[ "${DO_BUILD}" -eq 1 ]] && build_karat
  [[ "${DO_DEPLOY}" -eq 1 ]] && deploy_web_app \
    "karat_hive" \
    "${KARAT_DIR}/build/web" \
    "${DEPLOY_ROOT}/karat_hive" \
    "${PUBLIC_KARAT}"
fi

echo ""
log "Summary"
if [[ "${DO_DEPLOY}" -eq 1 ]]; then
  printf '  hive_admin  %s → %s\n' "$(http_code "${PUBLIC_ADMIN}")" "${PUBLIC_ADMIN}"
  printf '  karat_hive  %s → %s\n' "$(http_code "${PUBLIC_KARAT}")" "${PUBLIC_KARAT}"
  printf '  kh_api      %s → %s\n' "$(http_code "${API_HEALTH_PUBLIC}")" "${API_HEALTH_PUBLIC}"
  if [[ -f "${DEPLOY_ROOT}/hive_admin/index.html" ]]; then
    grep -oE 'base href="[^"]+"' "${DEPLOY_ROOT}/hive_admin/index.html" | sed 's/^/  admin /' || true
  fi
  if [[ -f "${DEPLOY_ROOT}/karat_hive/index.html" ]]; then
    grep -oE 'base href="[^"]+"' "${DEPLOY_ROOT}/karat_hive/index.html" | sed 's/^/  karat /' || true
  fi
fi
echo "DONE"

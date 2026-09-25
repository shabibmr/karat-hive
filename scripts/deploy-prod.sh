#!/usr/bin/env bash
# Deploy Karat Hive Production surfaces:
#   - Customer / Vendor App -> /var/www/html/karat/karat-hive (app.karathive.com, karathive.com)
#   - Admin Portal          -> /var/www/html/karat/kh-admin   (admin.karathive.com)
#   - Backend API (optional)-> /var/www/html/algo_cloud/kh_api (pm2: kh-api)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="${REPO_ROOT}/backend"
ADMIN_DIR="${REPO_ROOT}/apps/kh_admin"
KARAT_DIR="${REPO_ROOT}/apps/kh_mobile/karat_hive"

APP_DEPLOY_DIR="${APP_DEPLOY_DIR:-/var/www/html/karat/karat-hive}"
ADMIN_DEPLOY_DIR="${ADMIN_DEPLOY_DIR:-/var/www/html/karat/kh-admin}"
BACKEND_DEPLOY_DIR="${BACKEND_DEPLOY_DIR:-/var/www/html/algo_cloud/kh_api}"
BACKUP_ROOT="${BACKUP_ROOT:-/root/deploy_backups}"

PUBLIC_APP="${PUBLIC_APP:-https://app.karathive.com/}"
PUBLIC_KARAT="${PUBLIC_KARAT:-https://karathive.com/}"
PUBLIC_ADMIN="${PUBLIC_ADMIN:-https://admin.karathive.com/}"
API_HEALTH_LOCAL="${API_HEALTH_LOCAL:-http://127.0.0.1:3007/v1/platform-config}"
API_HEALTH_PUBLIC="${API_HEALTH_PUBLIC:-https://algoray.cloud/kh_api/v1/platform-config}"

PM2_APP="${PM2_APP:-kh-api}"
KH_API_BASE="${KH_API_BASE:-https://algoray.cloud/kh_api}"
KH_FLAVOR="${KH_FLAVOR:-prod}"

DO_APP=1
DO_ADMIN=1
DO_BACKEND=0
DO_BUILD=1
DO_DEPLOY=1
SKIP_MIGRATE=0
SKIP_NPM_CI=0
TS="$(date +%Y%m%d_%H%M%S)"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Deploy Karat Hive to production destinations:
  App:     ${APP_DEPLOY_DIR} (${PUBLIC_APP}, ${PUBLIC_KARAT})
  Admin:   ${ADMIN_DEPLOY_DIR} (${PUBLIC_ADMIN})
  Backend: ${BACKEND_DEPLOY_DIR} (pm2: ${PM2_APP}) [use --with-backend or --backend-only]

Options:
  --app-only           Deploy only customer/vendor web app
  --admin-only         Deploy only Admin Portal web
  --backend-only       Deploy only Backend API
  --with-backend       Include Backend API deployment with frontend surfaces
  --skip-build         Deploy existing artifacts without compiling
  --skip-deploy        Build only without syncing / deploying
  --skip-migrate       Skip prisma migrate deploy (backend)
  --skip-npm-ci        Skip npm ci (backend)
  -h, --help           Show this help message

EOF
  exit 0
}

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    --app-only|--karat-hive-only) DO_APP=1; DO_ADMIN=0; DO_BACKEND=0; shift ;;
    --admin-only) DO_APP=0; DO_ADMIN=1; DO_BACKEND=0; shift ;;
    --backend-only) DO_APP=0; DO_ADMIN=0; DO_BACKEND=1; shift ;;
    --with-backend) DO_BACKEND=1; shift ;;
    --skip-build) DO_BUILD=0; shift ;;
    --skip-deploy) DO_DEPLOY=0; shift ;;
    --skip-migrate) SKIP_MIGRATE=1; shift ;;
    --skip-npm-ci) SKIP_NPM_CI=1; shift ;;
    *) die "Unknown option: $1" ;;
  esac
done

if [[ "${DO_BUILD}" -eq 0 && "${DO_DEPLOY}" -eq 0 ]]; then
  die "Nothing to do: both --skip-build and --skip-deploy were set"
fi

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

http_code() {
  curl -sS -o /dev/null -w '%{http_code}' --max-time 15 "$1" 2>/dev/null || echo "000"
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
  [[ -f dist/main.js ]] || die "Backend build missing dist/main.js"
}

deploy_backend() {
  local dest="${BACKEND_DEPLOY_DIR}"
  [[ -d "${dest}" ]] || die "Backend deploy dir missing: ${dest}"
  [[ -f "${BACKEND_DIR}/dist/main.js" ]] || die "No backend dist; run without --skip-build"

  mkdir -p "${BACKUP_ROOT}"
  log "Backing up kh_api artifacts → ${BACKUP_ROOT}/kh_api_*_${TS}"
  [[ -d "${dest}/dist" ]] && cp -a "${dest}/dist" "${BACKUP_ROOT}/kh_api_dist_${TS}"
  [[ -d "${dest}/prisma" ]] && cp -a "${dest}/prisma" "${BACKUP_ROOT}/kh_api_prisma_${TS}"
  [[ -f "${dest}/package.json" ]] && cp -a "${dest}/package.json" "${BACKUP_ROOT}/kh_api_package_${TS}.json"

  log "Syncing dist / package manifests / prisma"
  rsync -a --delete "${BACKEND_DIR}/dist/" "${dest}/dist/"
  cp -a "${BACKEND_DIR}/package.json" "${dest}/package.json"
  cp -a "${BACKEND_DIR}/package-lock.json" "${dest}/package-lock.json"
  rsync -a --delete "${BACKEND_DIR}/prisma/" "${dest}/prisma/"

  cd "${dest}"
  if [[ "${SKIP_NPM_CI}" -eq 0 ]]; then
    log "npm ci --omit=dev"
    npm ci --omit=dev
  fi

  log "prisma generate"
  npx prisma generate

  if [[ "${SKIP_MIGRATE}" -eq 0 ]]; then
    log "prisma migrate deploy"
    npx prisma migrate deploy 2>&1 | sed -E 's/(postgresql:\/\/[^:]+:)[^@]+(@)/\1***\2/g'
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

  local code
  code="$(http_code "${API_HEALTH_LOCAL}")"
  log "kh-api local health: HTTP ${code}"
  [[ "${code}" == "200" ]] || die "Local backend health check failed"
}

# ---------------------------------------------------------------------------
# Flutter surfaces
# ---------------------------------------------------------------------------
build_admin() {
  log "Building kh_admin for production web (base-href=/)"
  export BASE_HREF="/"
  export KH_API_BASE
  export KH_FLAVOR
  bash "${ADMIN_DIR}/build_web.sh"
  [[ -f "${ADMIN_DIR}/build/web/index.html" ]] || die "Admin build missing index.html"
}

build_app() {
  log "Building karat_hive for production web (base-href=/)"
  export BASE_HREF="/"
  export KH_API_BASE
  export KH_API_BASE_URL="${KH_API_BASE}"
  export KH_FLAVOR
  bash "${KARAT_DIR}/build_web.sh"
  [[ -f "${KARAT_DIR}/build/web/index.html" ]] || die "karat_hive build missing index.html"
}

deploy_web_surface() {
  local name="$1"
  local src="$2"
  local dest="$3"

  [[ -d "${src}" ]] || die "Missing build output: ${src}"
  mkdir -p "${dest}"
  mkdir -p "${BACKUP_ROOT}"

  if [[ -n "$(ls -A "${dest}" 2>/dev/null || true)" ]]; then
    log "Backing up ${name} → ${BACKUP_ROOT}/${name}_${TS}"
    cp -a "${dest}" "${BACKUP_ROOT}/${name}_${TS}"
  fi

  log "Syncing ${name} → ${dest}"
  rsync -a --delete "${src}/" "${dest}/"
  chown -R www-data:www-data "${dest}"
  chmod -R 755 "${dest}"
}

# ---------------------------------------------------------------------------
# Execution
# ---------------------------------------------------------------------------
echo "============================================================"
echo " Karat Hive Production Deployment"
echo "============================================================"
echo " Surfaces : App=${DO_APP} Admin=${DO_ADMIN} Backend=${DO_BACKEND}"
echo " App Dest : ${APP_DEPLOY_DIR}"
echo " Admin Dest: ${ADMIN_DEPLOY_DIR}"
echo " Build    : ${DO_BUILD}"
echo " Deploy   : ${DO_DEPLOY}"
echo " Timestamp: ${TS}"
echo "============================================================"

if [[ "${DO_BACKEND}" -eq 1 ]]; then
  [[ "${DO_BUILD}" -eq 1 ]] && build_backend
  [[ "${DO_DEPLOY}" -eq 1 ]] && deploy_backend
fi

if [[ "${DO_ADMIN}" -eq 1 ]]; then
  [[ "${DO_BUILD}" -eq 1 ]] && build_admin
  [[ "${DO_DEPLOY}" -eq 1 ]] && deploy_web_surface "kh_admin" "${ADMIN_DIR}/build/web" "${ADMIN_DEPLOY_DIR}"
fi

if [[ "${DO_APP}" -eq 1 ]]; then
  [[ "${DO_BUILD}" -eq 1 ]] && build_app
  [[ "${DO_DEPLOY}" -eq 1 ]] && deploy_web_surface "karat_hive" "${KARAT_DIR}/build/web" "${APP_DEPLOY_DIR}"
fi

if [[ "${DO_DEPLOY}" -eq 1 ]]; then
  echo ""
  log "Verifying endpoints:"
  if [[ "${DO_APP}" -eq 1 ]]; then
    printf '  %-26s → HTTP %s\n' "${PUBLIC_APP}" "$(http_code "${PUBLIC_APP}")"
    printf '  %-26s → HTTP %s\n' "${PUBLIC_KARAT}" "$(http_code "${PUBLIC_KARAT}")"
  fi
  if [[ "${DO_ADMIN}" -eq 1 ]]; then
    printf '  %-26s → HTTP %s\n' "${PUBLIC_ADMIN}" "$(http_code "${PUBLIC_ADMIN}")"
  fi
  if [[ "${DO_BACKEND}" -eq 1 ]]; then
    printf '  %-26s → HTTP %s\n' "${API_HEALTH_PUBLIC}" "$(http_code "${API_HEALTH_PUBLIC}")"
  fi
fi

echo "DONE"

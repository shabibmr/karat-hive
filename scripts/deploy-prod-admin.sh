#!/usr/bin/env bash
# Deploy Karat Hive Admin Portal to Production (/var/www/html/karat/kh-admin)
# Serves: https://admin.karathive.com
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${REPO_ROOT}/apps/kh_admin"
DEPLOY_DIR="${DEPLOY_DEST:-/var/www/html/karat/kh-admin}"
BACKUP_ROOT="${BACKUP_ROOT:-/root/deploy_backups}"
PUBLIC_URL="${PUBLIC_URL:-https://admin.karathive.com/}"
KH_API_BASE="${KH_API_BASE:-https://algoray.cloud/kh_api}"
KH_FLAVOR="${KH_FLAVOR:-prod}"
BASE_HREF="${BASE_HREF:-/}"

DO_BUILD=1
DO_DEPLOY=1
TS="$(date +%Y%m%d_%H%M%S)"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Build and deploy Karat Hive Admin Portal to production (${DEPLOY_DIR}):
  Public URL: ${PUBLIC_URL}

Options:
  --skip-build         Deploy existing artifacts without compiling
  --skip-deploy        Compile Flutter web without deploying
  --base-href <path>   Set base href (default: /)
  --api-base <url>     Set backend API base URL (default: https://algoray.cloud/kh_api)
  -h, --help           Show this help message

EOF
  exit 0
}

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    --skip-build) DO_BUILD=0; shift ;;
    --skip-deploy) DO_DEPLOY=0; shift ;;
    --base-href)
      BASE_HREF="${2:-/}"
      shift 2
      ;;
    --api-base)
      KH_API_BASE="${2:-https://algoray.cloud/kh_api}"
      shift 2
      ;;
    *) die "Unknown option: $1" ;;
  esac
done

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

http_code() {
  curl -sS -o /dev/null -w '%{http_code}' --max-time 15 "$1" 2>/dev/null || echo "000"
}

echo "============================================================"
echo " Karat Hive Admin Portal Production Deployment"
echo "============================================================"
echo " Repo        : ${REPO_ROOT}"
echo " Source Dir  : ${APP_DIR}"
echo " Deploy Dest : ${DEPLOY_DIR}"
echo " Base HREF   : ${BASE_HREF}"
echo " API Base    : ${KH_API_BASE}"
echo " Flavor      : ${KH_FLAVOR}"
echo " Build       : ${DO_BUILD}"
echo " Deploy      : ${DO_DEPLOY}"
echo "============================================================"

if [[ "${DO_BUILD}" -eq 1 ]]; then
  log "Building kh_admin for web (base-href=${BASE_HREF})"
  cd "${APP_DIR}"
  export BASE_HREF
  export KH_API_BASE
  export KH_FLAVOR
  bash "${APP_DIR}/build_web.sh"
  [[ -f "${APP_DIR}/build/web/index.html" ]] || die "Build failed: index.html not found in ${APP_DIR}/build/web"
fi

if [[ "${DO_DEPLOY}" -eq 1 ]]; then
  require_cmd rsync
  require_cmd curl

  [[ -d "${APP_DIR}/build/web" ]] || die "Missing build output: ${APP_DIR}/build/web"
  mkdir -p "${DEPLOY_DIR}"
  mkdir -p "${BACKUP_ROOT}"

  if [[ -n "$(ls -A "${DEPLOY_DIR}" 2>/dev/null || true)" ]]; then
    log "Backing up current deployment → ${BACKUP_ROOT}/kh_admin_${TS}"
    cp -a "${DEPLOY_DIR}" "${BACKUP_ROOT}/kh_admin_${TS}"
  fi

  log "Syncing build artifacts to ${DEPLOY_DIR}"
  rsync -a --delete "${APP_DIR}/build/web/" "${DEPLOY_DIR}/"
  chown -R www-data:www-data "${DEPLOY_DIR}"
  chmod -R 755 "${DEPLOY_DIR}"

  log "Verifying health check"
  CODE="$(http_code "${PUBLIC_URL}")"
  log "${PUBLIC_URL} → HTTP ${CODE}"
  [[ "${CODE}" == "200" ]] || die "Health check failed for ${PUBLIC_URL} (HTTP ${CODE})"

  log "Deployment successful!"
fi

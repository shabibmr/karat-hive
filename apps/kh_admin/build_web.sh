#!/usr/bin/env bash
set -uo pipefail

# Locate the kh_admin app directory
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${APP_DIR}/build"

# Ensure build directory exists
mkdir -p "${BUILD_DIR}"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LATEST_LOG="${BUILD_DIR}/web_build.log"
TIMESTAMPED_LOG="${BUILD_DIR}/web_build_${TIMESTAMP}.log"

BASE_HREF="${BASE_HREF:-/hive_admin/}"
API_BASE="${KH_API_BASE:-https://algoray.cloud/kh_api}"
FLAVOR="${KH_FLAVOR:-prod}"

echo "============================================================"
echo " Building kh_admin for Web"
echo "============================================================"
echo " App Directory : ${APP_DIR}"
echo " Base HREF     : ${BASE_HREF}"
echo " API Base      : ${API_BASE}"
echo " Flavor        : ${FLAVOR}"
echo " Log Files     : ${LATEST_LOG}"
echo "                 ${TIMESTAMPED_LOG}"
echo "============================================================"

cd "${APP_DIR}"

# Run flutter build web and stream output to both console and log
flutter build web \
  --base-href="${BASE_HREF}" \
  --dart-define="KH_API_BASE=${API_BASE}" \
  --dart-define="KH_FLAVOR=${FLAVOR}" \
  "$@" 2>&1 | tee "${LATEST_LOG}"

if [ -n "${BASH_VERSION:-}" ]; then
  BUILD_STATUS=${PIPESTATUS[0]}
elif [ -n "${ZSH_VERSION:-}" ]; then
  BUILD_STATUS=${pipestatus[1]}
else
  BUILD_STATUS=$?
fi

# Copy the log to a timestamped file for historical tracking
cp "${LATEST_LOG}" "${TIMESTAMPED_LOG}" 2>/dev/null || true

if [[ ${BUILD_STATUS} -eq 0 ]]; then
  echo ""
  echo "==> Web build succeeded!"
  echo "==> Output artifacts: ${BUILD_DIR}/web"
  echo "==> Log saved: ${LATEST_LOG}"
else
  echo ""
  echo "==> Web build failed with exit code ${BUILD_STATUS}."
  echo "==> Log saved: ${LATEST_LOG}"
  exit ${BUILD_STATUS}
fi

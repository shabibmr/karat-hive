#!/usr/bin/env bash
set -uo pipefail

# Locate the karat_hive app directory
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${APP_DIR}/build"

# Ensure build directory exists
mkdir -p "${BUILD_DIR}"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LATEST_LOG="${BUILD_DIR}/run_chrome.log"
TIMESTAMPED_LOG="${BUILD_DIR}/run_chrome_${TIMESTAMP}.log"

BASE_HREF="${BASE_HREF:-/karat_hive/}"
API_BASE="${KH_API_BASE_URL:-${KH_API_BASE:-https://algoray.cloud/kh_api}}"
FLAVOR="${KH_FLAVOR:-prod}"

echo "============================================================"
echo " Running karat_hive on Chrome"
echo "============================================================"
echo " App Directory : ${APP_DIR}"
echo " Device        : chrome"
echo " Base HREF     : ${BASE_HREF}"
echo " API Base      : ${API_BASE}"
echo " Flavor        : ${FLAVOR}"
echo " Log Files     : ${LATEST_LOG}"
echo "                 ${TIMESTAMPED_LOG}"
echo "============================================================"

cd "${APP_DIR}"

# Run flutter on Chrome and stream output to both console and log
flutter run -d chrome \
  --base-href="${BASE_HREF}" \
  --dart-define="KH_API_BASE_URL=${API_BASE}" \
  --dart-define="KH_API_BASE=${API_BASE}" \
  --dart-define="KH_FLAVOR=${FLAVOR}" \
  "$@" 2>&1 | tee "${LATEST_LOG}"

if [ -n "${BASH_VERSION:-}" ]; then
  RUN_STATUS=${PIPESTATUS[0]}
elif [ -n "${ZSH_VERSION:-}" ]; then
  RUN_STATUS=${pipestatus[1]}
else
  RUN_STATUS=$?
fi

# Copy the log to a timestamped file for historical tracking
cp "${LATEST_LOG}" "${TIMESTAMPED_LOG}" 2>/dev/null || true

if [[ ${RUN_STATUS} -eq 0 ]]; then
  echo ""
  echo "==> Session ended cleanly."
  echo "==> Log saved: ${LATEST_LOG}"
else
  echo ""
  echo "==> Session ended with exit code ${RUN_STATUS}."
  echo "==> Log saved: ${LATEST_LOG}"
  exit ${RUN_STATUS}
fi

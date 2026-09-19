#!/usr/bin/env bash
set -uo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${APP_DIR}/build"

mkdir -p "${BUILD_DIR}"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LATEST_LOG="${BUILD_DIR}/run_android.log"
TIMESTAMPED_LOG="${BUILD_DIR}/run_android_${TIMESTAMP}.log"

DEVICE="${DEVICE:-192.168.1.5:37527}"
CONFIG_FILE="${CONFIG_FILE:-config/dev.json}"

echo "============================================================"
echo " Running karat_hive on Android (${DEVICE})"
echo "============================================================"
echo " App Directory : ${APP_DIR}"
echo " Device        : ${DEVICE}"
echo " Config File   : ${CONFIG_FILE}"
echo " Log Files     : ${LATEST_LOG}"
echo "                 ${TIMESTAMPED_LOG}"
echo "============================================================"

cd "${APP_DIR}"

flutter run -d "${DEVICE}" --dart-define-from-file="${CONFIG_FILE}" "$@" 2>&1 | tee "${LATEST_LOG}"

if [ -n "${BASH_VERSION:-}" ]; then
  RUN_STATUS=${PIPESTATUS[0]}
elif [ -n "${ZSH_VERSION:-}" ]; then
  RUN_STATUS=${pipestatus[1]}
else
  RUN_STATUS=$?
fi

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

#!/usr/bin/env bash
# build_apk.sh — Build a release APK and copy it to karat_hive.v-{version}.apk
#
# Defaults to config/prod.json (KH_FLAVOR=prod). Without a define file the
# app falls back to flavor dev and http://10.0.2.2:3000.
#
#   ./build_apk.sh
#   CONFIG_FILE=config/staging.json ./build_apk.sh
#   ./build_apk.sh --split-per-abi
set -uo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${APP_DIR}/build"
APK_DIR="${BUILD_DIR}/app/outputs/flutter-apk"

mkdir -p "${BUILD_DIR}"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LATEST_LOG="${BUILD_DIR}/apk_build.log"
TIMESTAMPED_LOG="${BUILD_DIR}/apk_build_${TIMESTAMP}.log"

CONFIG_FILE="${CONFIG_FILE:-config/prod.json}"

VERSION_LINE="$(grep -E '^version:' "${APP_DIR}/pubspec.yaml" | head -n 1 || true)"
VERSION_FULL="$(printf '%s\n' "${VERSION_LINE}" | awk '{print $2}')"
VERSION="${VERSION_FULL%%+*}"

if [[ -z "${VERSION}" ]]; then
  echo "==> Could not read version: from ${APP_DIR}/pubspec.yaml" >&2
  exit 1
fi

if [[ ! -f "${APP_DIR}/${CONFIG_FILE}" ]]; then
  echo "==> Config file not found: ${APP_DIR}/${CONFIG_FILE}" >&2
  exit 1
fi

echo "============================================================"
echo " Building karat_hive release APK v${VERSION}"
echo "============================================================"
echo " App Directory : ${APP_DIR}"
echo " Config File   : ${CONFIG_FILE}"
echo " Log Files     : ${LATEST_LOG}"
echo "                 ${TIMESTAMPED_LOG}"
echo "============================================================"

cd "${APP_DIR}"

flutter build apk --release --dart-define-from-file="${CONFIG_FILE}" "$@" 2>&1 | tee "${LATEST_LOG}"

if [[ -n "${BASH_VERSION:-}" ]]; then
  BUILD_STATUS=${PIPESTATUS[0]}
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  BUILD_STATUS=${pipestatus[1]}
else
  BUILD_STATUS=$?
fi

cp "${LATEST_LOG}" "${TIMESTAMPED_LOG}" 2>/dev/null || true

if [[ ${BUILD_STATUS} -ne 0 ]]; then
  echo ""
  echo "==> APK build failed with exit code ${BUILD_STATUS}."
  echo "==> Log saved: ${LATEST_LOG}"
  exit "${BUILD_STATUS}"
fi

# Fat APK. --split-per-abi writes app-<abi>-release.apk instead; leave those names.
SOURCE="${APK_DIR}/app-release.apk"
DEST="${APK_DIR}/karat_hive.v-${VERSION}.apk"

if [[ -f "${SOURCE}" ]]; then
  cp "${SOURCE}" "${DEST}"
  SIZE="$(du -h "${DEST}" | awk '{print $1}')"
  echo ""
  echo "==> APK ready: ${DEST}"
  echo "==> Size: ${SIZE}"
else
  echo ""
  echo "==> Build succeeded. Split APKs are in ${APK_DIR}"
fi

echo "==> Log saved: ${LATEST_LOG}"

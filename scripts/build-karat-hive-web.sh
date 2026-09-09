#!/usr/bin/env bash
set -euo pipefail

# Determine repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${REPO_ROOT}/apps/kh_mobile/karat_hive"
DEFAULT_BASE_HREF="/karat_hive/"

BASE_HREF="${BASE_HREF:-$DEFAULT_BASE_HREF}"
EXTRA_ARGS=()

usage() {
  cat <<EOF
Usage: $(basename "$0") [base_url] [options] [-- flutter build web options]

Builds the Karat Hive Customer / Vendor app (apps/kh_mobile/karat_hive) for Flutter Web.

Arguments:
  base_url             Base URL path prefix (default: /karat_hive/)

Options:
  --base-href <path>   Explicitly specify the base href (default: /karat_hive/)
  -h, --help           Show this help message

Environment Variables:
  BASE_HREF            Override default base href (e.g. BASE_HREF="/custom/")

Examples:
  $(basename "$0")
  $(basename "$0") karat_hive
  $(basename "$0") --dart-define-from-file=config/prod.json
EOF
  exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      ;;
    --base-href)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --base-href requires a path argument" >&2
        exit 1
      fi
      BASE_HREF="$2"
      shift 2
      ;;
    --base-href=*)
      BASE_HREF="${1#*=}"
      shift
      ;;
    *)
      if [[ "$1" != -* ]] && [[ "${BASE_HREF}" == "${DEFAULT_BASE_HREF}" ]]; then
        BASE_HREF="$1"
      else
        EXTRA_ARGS+=("$1")
      fi
      shift
      ;;
  esac
done

# Ensure base href starts and ends with '/'
[[ "${BASE_HREF}" != /* ]] && BASE_HREF="/${BASE_HREF}"
[[ "${BASE_HREF}" != */ ]] && BASE_HREF="${BASE_HREF}/"

echo "============================================================"
echo " Building Karat Hive Mobile/Web App for Web"
echo "============================================================"
echo " App Directory : ${APP_DIR}"
echo " Base URL      : ${BASE_HREF}"
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  echo " Extra Args    : ${EXTRA_ARGS[*]}"
fi
echo "============================================================"

cd "${APP_DIR}"

flutter build web --base-href "${BASE_HREF}" "${EXTRA_ARGS[@]}"

echo ""
echo " Build successful!"
echo " Output artifacts: ${APP_DIR}/build/web"

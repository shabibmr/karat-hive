#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${BACKEND_DIR}/logs"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
LATEST_LOG="${LOG_DIR}/run.log"
TIMESTAMPED_LOG="${LOG_DIR}/run_${TIMESTAMP}.log"

WATCH=0
USE_DOCKER=0
SKIP_INSTALL=0
SKIP_MIGRATE=0
EXTRA_ARGS=()

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [-- extra start args]

Build and run the Karat Hive Node.js backend (NestJS + Fastify).

Options:
  --watch            Skip nest build; run npm run start:dev (file watch)
  --docker           Start local Postgres via backend/docker/docker-compose.yml
  --skip-install     Do not run npm install
  --skip-migrate     Do not run prisma migrate deploy
  -h, --help         Show this help message

Environment:
  PORT, KH_ROLE, NODE_ENV, DATABASE_URL  Taken from backend/.env when unset
  Copies .env.example to .env when .env is missing

Examples:
  $(basename "$0")
  $(basename "$0") --watch
  $(basename "$0") --docker
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      ;;
    --watch)
      WATCH=1
      shift
      ;;
    --docker)
      USE_DOCKER=1
      shift
      ;;
    --skip-install)
      SKIP_INSTALL=1
      shift
      ;;
    --skip-migrate)
      SKIP_MIGRATE=1
      shift
      ;;
    --)
      shift
      EXTRA_ARGS+=("$@")
      break
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

env_value() {
  local key="$1"
  local fallback="${2:-}"
  local file="${BACKEND_DIR}/.env"
  if [[ -f "${file}" ]]; then
    local line
    line="$(grep -E "^${key}=" "${file}" | tail -n 1 || true)"
    if [[ -n "${line}" ]]; then
      local value="${line#*=}"
      value="${value%\"}"
      value="${value#\"}"
      value="${value%\'}"
      value="${value#\'}"
      printf '%s' "${value}"
      return 0
    fi
  fi
  printf '%s' "${fallback}"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: '$1' is required but was not found on PATH." >&2
    exit 1
  fi
}

require_cmd node
require_cmd npm
require_cmd npx

NODE_VERSION="$(node -v)"
NODE_MAJOR="${NODE_VERSION#v}"
NODE_MAJOR="${NODE_MAJOR%%.*}"
if [[ "${NODE_MAJOR}" -lt 20 ]]; then
  echo "Error: Node.js 20+ is required (found ${NODE_VERSION})." >&2
  exit 1
fi

mkdir -p "${LOG_DIR}"
cd "${BACKEND_DIR}"

if [[ ! -f .env ]]; then
  if [[ ! -f .env.example ]]; then
    echo "Error: backend/.env is missing and .env.example was not found." >&2
    exit 1
  fi
  cp .env.example .env
  echo "==> Copied .env.example to .env"
fi

PORT="${PORT:-$(env_value PORT 3000)}"
KH_ROLE="${KH_ROLE:-$(env_value KH_ROLE api)}"
NODE_ENV="${NODE_ENV:-$(env_value NODE_ENV development)}"
MODE="build + start:prod"
if [[ "${WATCH}" -eq 1 ]]; then
  MODE="start:dev (watch)"
fi

echo "============================================================"
echo " Building and running karat-hive-backend"
echo "============================================================"
echo " Backend Directory : ${BACKEND_DIR}"
echo " Node              : ${NODE_VERSION}"
echo " Mode              : ${MODE}"
echo " Role              : ${KH_ROLE}"
echo " Port              : ${PORT}"
echo " NODE_ENV          : ${NODE_ENV}"
echo " Log Files         : ${LATEST_LOG}"
echo "                     ${TIMESTAMPED_LOG}"
echo "============================================================"

if [[ "${USE_DOCKER}" -eq 1 ]]; then
  if ! command -v docker >/dev/null 2>&1; then
    echo "Error: --docker requires docker on PATH." >&2
    exit 1
  fi
  echo "==> Starting Postgres (docker compose)"
  docker compose -f "${BACKEND_DIR}/docker/docker-compose.yml" up -d postgres
  echo "==> Waiting for Postgres to become healthy"
  for _ in $(seq 1 60); do
    if docker compose -f "${BACKEND_DIR}/docker/docker-compose.yml" exec -T postgres \
      pg_isready -U karat -d karat_hive >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
  if ! docker compose -f "${BACKEND_DIR}/docker/docker-compose.yml" exec -T postgres \
    pg_isready -U karat -d karat_hive >/dev/null 2>&1; then
    echo "Error: Postgres did not become ready in time." >&2
    exit 1
  fi
fi

if [[ "${SKIP_INSTALL}" -eq 0 ]]; then
  echo "==> npm install"
  npm install
fi

echo "==> prisma generate"
npx prisma generate

if [[ "${SKIP_MIGRATE}" -eq 0 ]]; then
  echo "==> prisma migrate deploy"
  if ! npx prisma migrate deploy; then
    if [[ "${NODE_ENV}" == "production" ]]; then
      echo "Error: prisma migrate deploy failed (required when NODE_ENV=production)." >&2
      exit 1
    fi
    echo "==> Warning: migrate deploy failed. GET /health will still work; GET /ready will 503 until Postgres is up and migrations have run."
  fi
fi

run_and_log() {
  "$@" 2>&1 | tee "${LATEST_LOG}"
  local status
  if [[ -n "${BASH_VERSION:-}" ]]; then
    status=${PIPESTATUS[0]}
  elif [[ -n "${ZSH_VERSION:-}" ]]; then
    status=${pipestatus[1]}
  else
    status=$?
  fi
  cp "${LATEST_LOG}" "${TIMESTAMPED_LOG}" 2>/dev/null || true
  return "${status}"
}

set +e
if [[ "${WATCH}" -eq 1 ]]; then
  echo "==> npm run start:dev"
  echo "==> API: http://127.0.0.1:${PORT}/health"
  run_and_log npm run start:dev -- "${EXTRA_ARGS[@]}"
else
  echo "==> npm run build"
  npm run build
  BUILD_STATUS=$?
  if [[ ${BUILD_STATUS} -ne 0 ]]; then
    echo ""
    echo "==> Build failed with exit code ${BUILD_STATUS}."
    exit "${BUILD_STATUS}"
  fi
  echo "==> npm run start:prod"
  echo "==> API: http://127.0.0.1:${PORT}/health"
  run_and_log npm run start:prod -- "${EXTRA_ARGS[@]}"
fi
RUN_STATUS=$?
set -e

if [[ ${RUN_STATUS} -eq 0 ]]; then
  echo ""
  echo "==> Session ended cleanly."
  echo "==> Log saved: ${LATEST_LOG}"
else
  echo ""
  echo "==> Session ended with exit code ${RUN_STATUS}."
  echo "==> Log saved: ${LATEST_LOG}"
  exit "${RUN_STATUS}"
fi

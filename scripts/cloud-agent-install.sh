#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="${REPO_ROOT}/backend"
COMPOSE_FILE="${BACKEND_DIR}/docker/docker-compose.yml"

# shellcheck source=/dev/null
source "${REPO_ROOT}/scripts/cloud-agent-docker.sh"

cd "${BACKEND_DIR}"

if [[ ! -f .env ]]; then
  cp .env.example .env
fi

npm ci
npx prisma generate

docker compose -f "${COMPOSE_FILE}" up -d postgres

for _ in $(seq 1 60); do
  if pg_isready -h localhost -p 5432 -U karat -d karat_hive >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! pg_isready -h localhost -p 5432 -U karat -d karat_hive >/dev/null 2>&1; then
  echo "PostgreSQL did not become ready in time." >&2
  exit 1
fi

npx prisma migrate deploy

#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/backend/docker/docker-compose.yml"

# shellcheck source=/dev/null
source "${REPO_ROOT}/scripts/cloud-agent-docker.sh"

docker compose -f "${COMPOSE_FILE}" up -d postgres

for _ in $(seq 1 60); do
  if pg_isready -h localhost -p 5432 -U karat -d karat_hive >/dev/null 2>&1; then
    exit 0
  fi
  sleep 1
done

echo "PostgreSQL did not become ready in time." >&2
exit 1

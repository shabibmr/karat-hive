#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="${REPO_ROOT}/backend"

# shellcheck source=/dev/null
source "${REPO_ROOT}/scripts/cloud-agent-postgres.sh"

cd "${BACKEND_DIR}"

if [[ ! -f .env ]]; then
  cp .env.example .env
fi

npm ci
npx prisma generate
npx prisma migrate deploy

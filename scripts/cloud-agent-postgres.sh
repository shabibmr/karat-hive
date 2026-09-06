#!/usr/bin/env bash
set -euo pipefail

start_postgres() {
  if command -v pg_ctlcluster >/dev/null 2>&1; then
    local pg_version
    pg_version="$(pg_lsclusters -h | awk '{print $1}' | head -1)"
    if [[ -n "${pg_version}" ]]; then
      if [[ "$(id -u)" -eq 0 ]]; then
        pg_ctlcluster "${pg_version}" main start 2>/dev/null || true
      elif command -v sudo >/dev/null 2>&1; then
        sudo pg_ctlcluster "${pg_version}" main start 2>/dev/null || true
      else
        pg_ctlcluster "${pg_version}" main start 2>/dev/null || true
      fi
    fi
  elif command -v service >/dev/null 2>&1; then
    if [[ "$(id -u)" -eq 0 ]]; then
      service postgresql start 2>/dev/null || true
    elif command -v sudo >/dev/null 2>&1; then
      sudo service postgresql start 2>/dev/null || true
    fi
  fi
}

start_postgres

for _ in $(seq 1 60); do
  if pg_isready -q 2>/dev/null; then
    break
  fi
  sleep 1
done

if ! pg_isready -q 2>/dev/null; then
  echo "PostgreSQL did not become ready in time." >&2
  exit 1
fi

run_psql() {
  if id postgres >/dev/null 2>&1; then
    if [[ "$(id -u)" -eq 0 ]]; then
      su - postgres -c "psql -v ON_ERROR_STOP=1 $*"
    elif command -v sudo >/dev/null 2>&1; then
      sudo -u postgres psql -v ON_ERROR_STOP=1 "$@"
    else
      su - postgres -c "psql -v ON_ERROR_STOP=1 $*"
    fi
  else
    psql -v ON_ERROR_STOP=1 "$@"
  fi
}

if ! run_psql -tc "SELECT 1 FROM pg_roles WHERE rolname = 'karat'" | grep -q 1; then
  run_psql -c "CREATE USER karat WITH PASSWORD 'karat'"
fi

if ! run_psql -tc "SELECT 1 FROM pg_database WHERE datname = 'karat_hive'" | grep -q 1; then
  run_psql -c "CREATE DATABASE karat_hive OWNER karat"
fi

run_psql -d karat_hive -c "CREATE EXTENSION IF NOT EXISTS pgcrypto"
run_psql -d karat_hive -c "CREATE EXTENSION IF NOT EXISTS pg_trgm"

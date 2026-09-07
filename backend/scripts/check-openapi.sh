#!/usr/bin/env bash
# Fail when generated OpenAPI drifts from the index/HEAD artefact (NFR-030 / G2-GR05).
set -euo pipefail
cd "$(dirname "$0")/.."

npm run openapi:generate

if [[ ! -f openapi/openapi.json ]]; then
  echo "openapi/openapi.json was not written" >&2
  exit 1
fi

if [[ -z "$(git ls-files -- openapi/openapi.json)" ]]; then
  echo "openapi/openapi.json must be git-added (CI diffs the committed artefact)." >&2
  exit 1
fi

if ! git diff --exit-code -- openapi/; then
  echo "OpenAPI drift detected. Run: npm run openapi:generate && git add openapi/" >&2
  exit 1
fi

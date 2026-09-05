#!/usr/bin/env bash
set -euo pipefail

# Ensure Docker is reachable inside nested Cloud Agent VMs.
if ! docker info >/dev/null 2>&1; then
  dockerd --iptables=false --storage-driver=vfs >/tmp/dockerd.log 2>&1 &
  for _ in $(seq 1 30); do
    if docker info >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not available." >&2
  exit 1
fi

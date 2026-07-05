#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Checks if a Unix socket exists and is responsive with retries.
# version     : 0.1.1

# -------------------------------------------------------------------- usage ---

# usage: ./script.sh [socket_path] [max_retries] [retry_interval]

# --------------------------------------------------------------------- main ---

set -euo pipefail

# Configuration
SOCKET_PATH="${1:-/run/clamav/clamd.sock}"
MAX_RETRIES="${2:-90}"
RETRY_INTERVAL="${3:-1}"

# Validate dependencies
if ! command -v nc &>/dev/null; then
  echo "==> Error: nc (netcat) not found" >&2
  exit 1
fi

# Check socket with retries
count=0

while [ "$count" -lt "$MAX_RETRIES" ]; do
  if test -S "$SOCKET_PATH"; then
    echo "==> Socket found: $SOCKET_PATH"
    
    response="$(echo ping | nc -U "$SOCKET_PATH" 2>/dev/null || echo "")"
    
    if [[ "$response" == "pong" ]]; then
      echo "==> Socket responsive"
      exit 0
    fi
    
    echo "==> Unexpected response: ${response:-<empty>}"
  fi
  
  count=$((count + 1))
  echo "==> Attempt $count/$MAX_RETRIES - retrying in ${RETRY_INTERVAL}s"
  sleep "$RETRY_INTERVAL"
done

echo "==> Error: Socket check failed after $MAX_RETRIES attempts" >&2
exit 1

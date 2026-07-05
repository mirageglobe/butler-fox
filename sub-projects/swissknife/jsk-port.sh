#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Shows which process is listening on a given port.
# version     : 0.1.0

# -------------------------------------------------------------------- usage ---

usage() {
  cat <<EOF
Usage: $(basename "$0") <port>

Shows which process is listening on the given port number.

Example:
  $(basename "$0") 8080
  $(basename "$0") 443
EOF
  exit "${1:-0}"
}

# --------------------------------------------------------------------- main ---

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage 0
fi

PORT="$1"

if [[ -z "$PORT" ]]; then
  echo "Error: no port specified." >&2
  usage 1
fi

if ! [[ "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
  echo "Error: '$PORT' is not a valid port number (1-65535)." >&2
  exit 1
fi

if ! command -v lsof >/dev/null 2>&1; then
  echo "Error: lsof not found." >&2
  exit 1
fi

result=$(lsof -nP -iTCP:"$PORT" -sTCP:LISTEN 2>/dev/null)

if [[ -z "$result" ]]; then
  echo "Nothing listening on port $PORT."
  exit 0
fi

echo "$result"

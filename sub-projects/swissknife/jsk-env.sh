#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Diffs .env against .env.example, flagging missing or extra keys.
# version     : 0.1.0

# -------------------------------------------------------------------- usage ---

usage() {
  cat <<EOF
Usage: $(basename "$0") [env_file] [example_file]

Compares an .env file against a .env.example template.
Reports keys that are missing from .env or not present in .env.example.

Defaults:
  env_file     .env
  example_file .env.example

Example:
  $(basename "$0")
  $(basename "$0") .env.local .env.example
EOF
  exit "${1:-0}"
}

# ----------------------------------------------------------- core functions ---

extract_keys() {
  local file="$1"
  grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$file" | cut -d '=' -f1 | sort
}

# --------------------------------------------------------------------- main ---

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage 0
fi

ENV_FILE="${1:-.env}"
EXAMPLE_FILE="${2:-.env.example}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: '$ENV_FILE' not found." >&2
  exit 1
fi

if [[ ! -f "$EXAMPLE_FILE" ]]; then
  echo "Error: '$EXAMPLE_FILE' not found." >&2
  exit 1
fi

env_keys=$(extract_keys "$ENV_FILE")
example_keys=$(extract_keys "$EXAMPLE_FILE")

missing=$(comm -23 <(echo "$example_keys") <(echo "$env_keys"))
extra=$(comm -13 <(echo "$example_keys") <(echo "$env_keys"))

ok=true

if [[ -n "$missing" ]]; then
  ok=false
  echo "[missing] keys in $EXAMPLE_FILE but not in $ENV_FILE:"
  while IFS= read -r key; do
    echo "  - $key"
  done <<< "$missing"
fi

if [[ -n "$extra" ]]; then
  ok=false
  echo "[extra] keys in $ENV_FILE but not in $EXAMPLE_FILE:"
  while IFS= read -r key; do
    echo "  + $key"
  done <<< "$extra"
fi

if [[ "$ok" == true ]]; then
  echo "[ok] $ENV_FILE matches $EXAMPLE_FILE"
fi

#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Decodes and displays JWT token header and payload.
# version     : 0.1.0

# -------------------------------------------------------------------- usage ---

usage() {
  cat <<EOF
Usage: $(basename "$0") <token>
       echo <token> | $(basename "$0")

Decodes a JWT token and pretty-prints the header and payload.
Does not verify the signature.

Example:
  $(basename "$0") eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyIn0.abc
EOF
  exit "${1:-0}"
}

# ----------------------------------------------------------- core functions ---

decode_part() {
  local part="$1"
  # JWT uses base64url (- instead of +, _ instead of /)
  # Pad to multiple of 4 for standard base64
  local padded
  padded="${part}==="
  padded="${padded:0:${#part} + (4 - ${#part} % 4) % 4}"
  echo "${padded}" | tr -- '-_' '+/' | base64 -d 2>/dev/null
}

pretty_print() {
  local json="$1"
  if command -v python3 >/dev/null 2>&1; then
    echo "$json" | python3 -m json.tool
  elif command -v jq >/dev/null 2>&1; then
    echo "$json" | jq .
  else
    echo "$json"
  fi
}

# --------------------------------------------------------------------- main ---

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage 0
fi

# accept token from argument or stdin
if [[ -n "$1" ]]; then
  TOKEN="$1"
elif [[ ! -t 0 ]]; then
  read -r TOKEN
else
  echo "Error: no token provided." >&2
  usage 1
fi

IFS='.' read -r header_b64 payload_b64 _ <<< "$TOKEN"

if [[ -z "$header_b64" || -z "$payload_b64" ]]; then
  echo "Error: invalid JWT format (expected header.payload.signature)" >&2
  exit 1
fi

header=$(decode_part "$header_b64")
payload=$(decode_part "$payload_b64")

if [[ -z "$header" || -z "$payload" ]]; then
  echo "Error: failed to decode token — not a valid base64url JWT" >&2
  exit 1
fi

echo "=== header ==="
pretty_print "$header"
echo ""
echo "=== payload ==="
pretty_print "$payload"

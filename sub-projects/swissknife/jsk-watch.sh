#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Runs a specified command at regular intervals with output monitoring.
# version     : 0.1.0

# --------------------------------------------------------------------- main ---

# usage: ./script.sh [interval duration] [command]

set -euo pipefail

# Display usage
usage() {
  cat <<EOF
Usage: $0 <interval_seconds> <command> [args...]

Examples:
  $0 5 echo "test me"
  $0 2 ls -la
  $0 10 df -h

Press Ctrl-C to exit.
EOF
  exit "${1:-0}"
}

# Validate arguments
if [ "$#" -lt 2 ]; then
  usage 1
fi

# Validate interval is a number
time_interval="$1"
if ! [[ "$time_interval" =~ ^[0-9]+$ ]]; then
  echo "Error: Interval must be a positive integer" >&2
  usage 1
fi

shift
command_to_run=("$@")

# Main watch loop
while true; do
  clear
  printf "==> %s [Ctrl-C to exit]\n\n" "$(date '+%Y-%m-%d %H:%M:%S')"
  
  # Execute command and handle errors gracefully
  if ! "${command_to_run[@]}"; then
    exit_code=$?
    echo ""
    echo "==> Command failed with exit code: $exit_code" >&2
  fi
  
  sleep "$time_interval"
done

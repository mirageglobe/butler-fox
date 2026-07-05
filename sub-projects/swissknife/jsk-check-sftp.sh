#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Validates SFTP availability and connectivity for remote transfers.
# version     : 0.1.1

# -------------------------------------------------------------------- usage ---

# - https://devhints.io/bash

# --------------------------------------------------------------------- main ---

# usage: ./script.sh [host] [options]

set -euo pipefail

# Validate sftp is available
if ! command -v sftp &>/dev/null; then
  echo "==> Error: sftp not found. Please install sftp." >&2
  exit 1
fi

# Accept parameters or use defaults
SFTP_HOST="${1:-dh}"
SFTP_OPTIONS="${2:--hi .}"

sftp "$SFTP_HOST" "$SFTP_OPTIONS"

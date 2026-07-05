#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Checks tool dependencies and prints a status table.
# version     : 0.1.0

# -------------------------------------------------------------------- usage ---

usage() {
  cat <<EOF
Usage: $(basename "$0")

Checks that dependencies required by jsk tools are installed.
Prints a status table with [ok] / [missing] per dependency.

EOF
  exit "${1:-0}"
}

# ----------------------------------------------------------- core functions ---

check() {
  local bin="$1"
  local used_by="$2"
  if command -v "$bin" >/dev/null 2>&1; then
    printf "  \033[32m[ok]     \033[0m %-18s %s\n" "$bin" "$used_by"
  else
    printf "  \033[33m[missing]\033[0m %-18s %s\n" "$bin" "$used_by"
  fi
}

# --------------------------------------------------------------------- main ---

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage 0
fi

echo ""
echo "=== jsk-doctor ==="
echo ""
printf "  %-10s %-18s %s\n" "status" "dependency" "used by"
printf "  %s\n" "------------------------------------------------------------"

# core
check "bash"        "core"
check "python3"     "jsk-system-check, jsk-decode-vbe"
check "curl"        "jsk-install, jsk-sqldb"
check "git"         "jsk-git-cache-meta"
check "lsof"        "jsk-port"
check "nc"          "jsk-check-socket"
check "sftp"        "jsk-check-sftp"
check "jq"          "jsk-kvdb (optional pretty-print)"

# media
check "ffmpeg"      "jsk-mp3, jsk-mp4"
check "gs"          "jsk-pdf (ghostscript)"
check "gm"          "jsk-png (graphicsmagick)"
check "optipng"     "jsk-png"
check "pngquant"    "jsk-png"

# data
check "mysql"       "jsk-sqldb"
check "mysqldump"   "jsk-sqldb"

echo ""

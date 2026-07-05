#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Core shell library with utility functions for system, files, and UI.
# version     : 0.4.0

# ----------------------------------------------------------- core functions ---

# --- System & OS ---

_allow_os() {
  # usage: _allow_os "Darwin Linux"
  local allowed=$1
  local current
  current=$(uname -s)
  [[ "$allowed" == *"$current"* ]]
}

_is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

_is_linux() {
  [[ "$(uname -s)" == "Linux" ]]
}

_is_installed() {
  # usage: if _is_installed "git"; then ...
  command -v "$1" >/dev/null 2>&1
}

# --- File & Directory ---

_file_exists() {
  [[ -f "$1" ]]
}

_directory_exists() {
  [[ -d "$1" ]]
}

# --- UI & Output ---

_print_success() {
  printf "\n\342\234\224  %s\n" "$1"
}

_print_error() {
  printf "\n\342\234\226  %s\n" "$1"
}

_spinner() {
  # usage: some_command & _spinner $!
  local pid=$1
  local delay=0.1
  local spinstr="|/-\\"
  while ps -p "$pid" > /dev/null; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# --- Date & Time ---

_timestamp() {
  date +"%T"
}

_datestamp() {
  date +"%Y%m%d%H%M%S"
}

# --- Data Parsing ---

_parse_yaml() {
  # usage: _parse_yaml "file.yaml" "PREFIX_"
  local prefix=$2
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs
  fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
  awk -F"$fs" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
      vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
      printf("%s%s%s=\"%s\"\n", "'"$prefix"'",vn, $2, $3);
    }
  }'
}

# --- Utilities & Exit ---

_yell() { echo "$0: $*" >&2; }
_die() { _yell "$*"; exit 111; }
_try() { "$@" || _die "cannot $*"; }
_quit() { exit 0; }

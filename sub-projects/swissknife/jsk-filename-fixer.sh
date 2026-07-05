#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Normalizes filenames for URL-safe and cross-platform compatibility.
# version     : 0.3.0

# -------------------------------------------------------------------- usage ---

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] <file|directory>

Options:
  -n    Dry-run: show what would be renamed, but don't perform the action.
  -i    Interactive: prompt for confirmation before renaming.
  -r    Recursive: process directories recursively.
  -h    Display this help message.

Example:
  $(basename "$0") -r ./my_folder
EOF
  exit "${1:-0}"
}

# ----------------------------------------------------------- core functions ---

fix_filename() {
  local target="$1"
  local base_name
  local dir_name
  local new_name
  local target_path

  if [[ ! -f "$target" ]]; then
    return
  fi

  base_name=$(basename "$target")
  dir_name=$(dirname "$target")

  # normalization logic:
  # 1. convert to lowercase
  # 2. replace spaces and underscores with hyphens
  # 3. remove characters that aren't letters, numbers, hyphens, or dots
  # 4. collapse multiple hyphens
  new_name=$(echo "$base_name" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | sed 's/[^a-z0-9.-]//g' | sed 's/-\{2,\}/-/g')
  target_path="${dir_name}/${new_name}"

  # if the name is already the same, skip
  if [[ "$base_name" == "$new_name" ]]; then
    return
  fi

  # check if target already exists
  if [[ -f "$target_path" ]]; then
    echo "Skipping: '$target' -> '$target_path' (Destination already exists)" >&2
    return
  fi

  # Handle Dry-Run
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] Would rename: '$target' -> '$target_path'"
    return
  fi

  # Handle Interactive confirmation
  if [[ "$INTERACTIVE" == true ]]; then
    read -p "Rename '$target' to '$target_path'? [y/N] " -n 1 -r
    echo ""
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
      echo "Skipped: '$target'"
      return
    fi
  fi

  # perform the rename
  if mv "$target" "$target_path"; then
    echo "Success: '$target' -> '$target_path'"
  else
    echo "Error: Failed to rename '$target'" >&2
  fi
}

# --------------------------------------------------------------------- main ---

DRY_RUN=false
INTERACTIVE=false
RECURSIVE=false

# parse options
while getopts "nirh" opt; do
  case "$opt" in
    n) DRY_RUN=true ;;
    i) INTERACTIVE=true ;;
    r) RECURSIVE=true ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
done

shift $((OPTIND-1))

INPUT="$1"

# check if input argument is provided
if [[ -z "$INPUT" ]]; then
  echo "Error: No file or directory specified." >&2
  usage 1
fi

# Determine if input is a directory or file
if [[ -d "$INPUT" ]]; then
  if [[ "$RECURSIVE" == true ]]; then
    # find all files recursively
    find "$INPUT" -type f | while IFS= read -r f; do
      fix_filename "$f"
    done
  else
    # find files in the current directory only (one level)
    for f in "$INPUT"/*; do
      fix_filename "$f"
    done
  fi
elif [[ -f "$INPUT" ]]; then
  fix_filename "$INPUT"
else
  echo "Error: '$INPUT' is not a valid file or directory." >&2
  exit 2
fi

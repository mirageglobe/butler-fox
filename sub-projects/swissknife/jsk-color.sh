#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Displays a visual ANSI color chart for terminal development.
# version     : 0.2.0

# -------------------------------------------------------------------- usage ---

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -b    Show basic 16 colors with labels.
  -e    Show extended 256 colors chart.
  -a    Show all color charts (basic + extended).
  -h    Display this help message.

If no options are provided, shows all charts.
EOF
  exit "${1:-0}"
}

# ----------------------------------------------------------- core functions ---

show_basic() {
  echo "--- Basic Colors (16) ---"
  local colors=("BLACK" "RED" "GREEN" "YELLOW" "BLUE" "MAGENTA" "CYAN" "WHITE")
  
  # Standard colors (0-7)
  for i in {0..7}; do
    printf "\033[0;3%dm%s\t\t" "$i" "${colors[$i]}"
    # Light/High intensity colors (8-15)
    printf "\033[1;3%dmLIGHT_%s\n" "$i" "${colors[$i]}"
  done
  printf "\033[0m\n"
}

show_extended() {
  echo "--- Extended ANSI Colors (256) ---"
  # Standard 16 colors in grid
  for (( i=0; i<16; i++ )); do
    printf "$(tput setaf $i)%3d $(tput sgr0)" "$i"
    [[ $(( (i + 1) % 8 )) -eq 0 ]] && printf "\n"
  done
  printf "\n"

  # 216 color cube (6x6x6)
  for (( i=16; i<232; i++ )); do
    printf "$(tput setaf $i)%3d $(tput sgr0)" "$i"
    [[ $(( (i - 15) % 6 )) -eq 0 ]] && printf " "
    [[ $(( (i - 15) % 18 )) -eq 0 ]] && printf "\n"
  done
  printf "\n"

  # Grayscale ramp
  for (( i=232; i<256; i++ )); do
    printf "$(tput setaf $i)%3d $(tput sgr0)" "$i"
    [[ $(( (i - 231) % 12 )) -eq 0 ]] && printf "\n"
  done
  printf "\n"
}

# --------------------------------------------------------------------- main ---

SHOW_BASIC=false
SHOW_EXTENDED=false

# parse options
while getopts "beah" opt; do
  case "$opt" in
    b) SHOW_BASIC=true ;;
    e) SHOW_EXTENDED=true ;;
    a) SHOW_BASIC=true; SHOW_EXTENDED=true ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
done

# If no flags, show everything
if [[ "$SHOW_BASIC" == false && "$SHOW_EXTENDED" == false ]]; then
  SHOW_BASIC=true
  SHOW_EXTENDED=true
fi

[[ "$SHOW_BASIC" == true ]] && show_basic
[[ "$SHOW_EXTENDED" == true ]] && show_extended

exit 0

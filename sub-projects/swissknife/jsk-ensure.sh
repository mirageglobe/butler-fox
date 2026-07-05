#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Basic dependency checker for local environment requirements.
# version     : 0.1.0

# --------------------------------------------------------------------- main ---

# ensure script is a basic bash cli tool for checking dependencies

function ensure () {
  (printf "[ok] ... %s - " "$1" && command -v "$1") || echo "[no] ... $1 not found"
}

ensure fox
# ensure that fox is in path
# grep -q "/.fox.bash" "$HOME/.bashrc" && echo "[fox] found bash path. skipping update." || echo "[ -f ~/.fox.bash ] && source ~/.fox.bash" >> $HOME/.bashrc

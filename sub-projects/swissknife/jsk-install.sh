#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Bootstrap/installer for Swissknife utility scripts.
# version     : 0.2.0

# --------------------------------------------------------------------- main ---

# this is an example script to install an application into /usr/local/bin
# /usr/local/bin/ is normally in your $PATH
# it installs either from local cloned repo or remote github service

# installs samurai into /usr/local/bin
# files: samurai / samurai-mac.py / samurai-linux.py

readonly SUDO_REQUIRED=true
readonly APP_NAME=samurai

if [[ $SUDO_REQUIRED ]]; then
  if [[ $(id -u) != 0 ]]; then
    # check for sudo
    if command -v sudo >/dev/null 2>&1; then
      SUDO="sudo"
    else
      echo >&2 "==> sudo not found. abort script $0."; exit 1;
    fi
  fi
fi

if git ls-files >& /dev/null && [[ -f samurai.py ]]; then
  # install from local repo
  $SUDO cp ./samurai /usr/local/bin/samurai || { echo "failed to install samurai into /usr/local/bin."; exit 1; }
  $SUDO cp ./samurai-mac.py /usr/local/bin/samurai-mac.py || { echo "failed to install samurai-mac.py into /usr/local/bin."; exit 1; }
  $SUDO cp ./samurai-linux.py /usr/local/bin/samurai-linux.py || { echo "failed to install samurai-linux.py into /usr/local/bin."; exit 1; }
else
  # install from remote github repo
  if $SUDO curl -L https://raw.githubusercontent.com/mirageglobe/samurai/master/samurai -o /usr/local/bin/samurai && $SUDO chmod +x /usr/local/bin/samurai; then
    : # Successful
  else
    echo "failed to install samurai into /usr/local/bin." ; exit 1
  fi

  if $SUDO curl -L https://raw.githubusercontent.com/mirageglobe/samurai/master/samurai-mac.py -o /usr/local/bin/samurai-mac.py && $SUDO chmod +x /usr/local/bin/samurai-mac.py; then
    : # Successful
  else
    echo "failed to install samurai-mac.py into /usr/local/bin." ; exit 1
  fi

  if $SUDO curl -L https://raw.githubusercontent.com/mirageglobe/samurai/master/samurai-linux.py -o /usr/local/bin/samurai-linux.py && $SUDO chmod +x /usr/local/bin/samurai-linux.py; then
    : # Successful
  else
    echo "failed to install samurai-linux.py into /usr/local/bin." ; exit 1
  fi
fi

echo "installed $APP_NAME into /usr/local/bin.";
echo "to uninstall, delete samurai / samurai-mac.py / samurai-linux.py from folder /usr/local/bin";
exit 0;

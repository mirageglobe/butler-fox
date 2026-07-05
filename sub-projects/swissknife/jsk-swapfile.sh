#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Utility to create and manage Linux swap files for memory management.
# version     : 1.0.4

# ---------------------------------------------------------------- reference ---

# - update swap file -> https://help.ubuntu.com/community/SwapFaq
# - make swap reference https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04

# --------------------------------------------------------------------- todo ---

# - check os
# - check if swapon no response

# --------------------------------------------------------------------- check os ---

if [[ "$(uname)" != "Linux" ]]; then
  echo "Error: This script must be run on Linux."
  exit 1
fi

if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    if [[ "$ID" != "debian" && "$ID" != "ubuntu" && "$ID_LIKE" != *"debian"* && "$ID_LIKE" != *"ubuntu"* ]]; then
        echo "Error: This script is designed for Debian or Ubuntu systems only."
        echo "Detected: $PRETTY_NAME"
        exit 1
    fi
else
    echo "Error: Cannot determine OS distribution (/etc/os-release not found)."
    exit 1
fi

# --------------------------------------------------------------------- main ---

# run this script to generate a 2gb swap file
#
# to revert
# - delete "/swapfile  none  swap  sw  0  0 line" from `/etc/fstab`
# - delete "vm.swappiness=10" from `/etc/sysctl.conf`
# - delete "vm.vfs_cache_pressure=50" from `/etc/sysctl.conf`
# - delete `/swapfile`

# ----- check arguments

EXPECTED_ARGS=1
E_BADARGS=0

DTTITLE=""
DTTEXT="   "

if [ "$#" -lt "$EXPECTED_ARGS" ]; then
  echo ""
  echo "$DTTITLE swap file deployment script:"
  echo "$DTTEXT this script converts adds a swapfile in root folder"
  echo ""
  echo "$DTTITLE usage:"
  echo "$DTTEXT $0 [options] [arguments]"
  echo "$DTTEXT $0 check                      : displays current memory allocation"
  echo "$DTTEXT $0 deploy                     : adds a 2gb swap file"
  echo ""
  echo "$DTTITLE examples:"
  echo "$DTTEXT $0 deploy"
  echo ""

  exit $E_BADARGS
fi

echo "$DTTITLE adding virtual memory"

if [ -f /swapfile ]; then
  echo "$DTTITLE error. swapfile already found"
  exit 0
fi

echo "$DTTITLE checking current free memory"
sudo swapon -s
df -h

if [ "$1" == "deploy" ]; then
  echo "$DTTITLE making 2gb swap file"
  sudo fallocate -l 2G /swapfile

  echo "$DTTITLE setting swap file permissions"
  sudo chmod 600 /swapfile

  echo "$DTTITLE activating swap file"
  sudo mkswap /swapfile
  sudo swapon /swapfile

  echo "$DTTITLE updating fstab"
  echo "$DTTEXT writing /swapfile  none  swap  sw  0  0 to /etc/fstab"
  echo "/swapfile  none  swap  sw  0  0" | sudo tee -a /etc/fstab > /dev/null

  #echo "[+] set swappiness"
  #cat /proc/sys/vm/swappiness

  echo "$DTTEXT writing vm.swappiness=10 to /etc/sysctl.conf"
  echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null

  echo "$DTTEXT writing vm.vfs_cache_pressure=50 to /etc/sysctl.conf"
  echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf > /dev/null

  echo "$DTTEXT deployment complete. please reboot now if necessary. use sudo swapon -s or free -m"
fi

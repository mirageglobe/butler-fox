#!/usr/bin/env python3

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# version     : 1.0.0

# --------------------------------------------------------------- references ---

import os
import platform
import socket
import sys

samuraimap = {}

# ---------------------------------------------------------------- functions ---

def loadoptions(ninja=False,showcmd=False):
  print("==================================")
  print("samurai for mac")
  print("modes: ninja={0},".format(ninja), "showcmd={0}".format(showcmd))
  print("system:","{0}".format(platform.system()),"({0})".format(platform.release()))
  print("==================================")

  for key, value in sorted(samuraimap.items()):
    if showcmd:
      print("[", key, "] -", value['name'], " ::> " , value['cmd'])
    else:
      print("[", key, "] -", value['name'])

def runcommand(cmdstring):
  return_value = os.system(cmdstring)

# --------------------------------------------------------------------- main ---

if __name__ == "__main__":

  # ===============================
  # checks for system
  # ===============================

  if platform.system() != 'Darwin':
    print("[Samurai] System incompatible, please run samurai.py instead.")
    sys.exit(1)

  # ===============================
  # setting arguments
  # ===============================

  ninja_active = False
  showcmd_active = False

  # adding ninja mode here - ninja mode activated within menu
  # in ninja mode, the commands are not executed; until the end. if you run ninja, it will create a scroll.sh with bash commands which can be used with vagrant
  # export DEBIAN_FRONTEND=noninteractive
  # apt-get -y install package1 package2

  # ===============================
  # default load of system
  # ===============================

  avatar = "[samurai]"
  gloop = True

  # ===============================
  # entering loop of samurai
  # ===============================

  runcommand("clear")

  while gloop:
    gchoice = 9999

    loadoptions(ninja_active,showcmd_active)
    gchoice = input("================================== \n{0} What is your command? : ".format(avatar))

    if gchoice.isdigit():
      gchoice = int(gchoice)
    else:
      gchoice = 9999

    if gchoice == 0:
      break

    if gchoice == 3:
      showcmd_active = not showcmd_active
      # toggle showcmd mode

    if gchoice in samuraimap:
      runcommand(samuraimap[gchoice]['cmd'])
      if not samuraimap[gchoice]['responsesuccess']:
        print("{0}".format(avatar), samuraimap[gchoice]['responsesuccess'])
    else:
      print("{0} Command is does not exist. Please enter number.".format(avatar))
      # load the options again. does not work if placed in above array

    input("enter to continue")
    runcommand("clear")

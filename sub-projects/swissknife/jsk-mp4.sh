#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Media conversion utility focused on creating optimized MP4 video.
# version     : 0.1.0

# ---------------------------------------------------------------- reference ---

# - http://superuser.com/questions/134679/command-line-application-for-converting-svg-to-png-on-mac-os-x

# --------------------------------------------------------------------- main ---

# use mp4 output only

# ----- include constants

# program base name or use $0
app_basename=$(basename "${0}")
app_argv1=$(basename "${1}")
app_argv2=$(basename "${2}")

# ----- extracted shell-lib.sh

_print_help() {
  # Usage: my_program [command] [--option] [<argument>]
  # ref https://stackoverflow.com/questions/9725675/is-there-a-standard-format-for-command-line-shell-help-text
  # ref http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html#tag_12_01

  # Print the program help information.

  cat <<HEREDOC

SHELLAPP
  this utility app prints/execute helper functions to manage this application

  version       v0.1.0
  author/site   jimmylim (mirageglobe@gmail.com) / www.mirageglobe.com

usage:
  ${app_basename} [options] [<file>]
  ${app_basename} h | help

options:
  help          display this help information
  mp4           convert video to mp4 using x264

examples:
  sh ${app_basename} help

HEREDOC
}

_is_installed() {
  # returns the path with true 0 or null 1
  command -v "$1" >/dev/null 2>&1

  # ref : command -v "$1" >/dev/null 2>&1 || { echo >&2 "nginx not installed ... [abort]"; exit 1; }
  # example : if _is_installed "myprogram"; then _print_success "found"; else _print_error "not found"; fi
}

_is_macos() {
  rtn_val=1 #note rtn boolean for error codes is 0 = true / 1 = false (reversed with boolean statements)

  if uname -s | grep -Fq 'Darwin'; then
    rtn_val=0
  fi

  return $rtn_val
}

_is_linux() {
  rtn_val=1 #note rtn boolean for error codes is 0 = true / 1 = false (reversed with boolean statements)

  if uname -s | grep -Fq 'Linux'; then
    rtn_val=0
  fi

  return $rtn_val
}

_file_exists() {
  if [ -f "$1" ]; then
    true # return true or 0 (0=true); i.e num of errors = 0
  else
    false # return false or 1 (1=false); i.e. num of errors > 0
  fi
  # example : if _file_exists "myfile.txt"; then _print_success "found"; else _print_error "not found"; exit 1; fi
}

_print_success () {
  printf "\\n\\342\\234\\224  %s\\n" "$1"
}

_print_error () {
  printf "\\n\\342\\234\\226  %s\\n" "$1"
}

_yell() { echo "$0: $*" >&2; }
_die() { _yell "$*"; exit 111; }
_try() { "$@" || _die "cannot $*"; }
_quit() { exit 0; }


# ----- describe app

# - check os/dependancies
# - check input
# - backup file
# - convert file

# ----- check arguments

# one for command other for file input
EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]; then _print_help; exit $E_BADARGS; fi

# ----- check os

app_os="NIL"

if _is_macos; then app_os="MAC";
elif _is_linux; then app_os="NIX";
fi

if [ "$app_os" == "NIL" ]; then _die; fi

# ----- check dependancies

if _is_installed "avconv"; then _print_success "avconv/libav"; else _print_error "avconv/libav - install via \$brew install libav"; _die; fi
# package is libav on homebrew

if _file_exists "$app_argv2"; then _print_success "found"; else _print_error "not found"; _die; fi
# testing if file exists

# ----- main code

app_cmd=$app_argv1

# default checks
case "$app_cmd" in
  help)
    # list help
    _print_help
    ;;
  mp4)
    # your option for test here
    echo "running \$ avconv -i inputfile.mov -c:v libx264 outputfile.mp4"
    _print_success "done ... [ok]"
    ;;
  *)
    _print_error "unexpected arguments/input"
    _print_help
    _die
esac


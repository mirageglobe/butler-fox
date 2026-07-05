#!/usr/bin/env sh

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Manages project-specific configurations and dotfile environments.
# version     : 0.1.0

# -------------------------------------------------------------------- todo ---

# - support raw folder for custom native shell scripts
# - use default.json, custom.json for input rules. any scroll can be created in camp folder http://stackoverflow.com/questions/2835559/parsing-values-from-a-json-file-in-python
# - check packages option to see a summary of what is installed.
# - add unit test (https://github.com/kward/shunit2)
# - add fail2ban in core scroll
# - add caffeine in linux
# - install to home directory and symlink commands
# - future tooling prototype for sub-scripting

# prototype example:

# ```
# {
#   "scrollname" : "myfirstscroll",
#   "scrolldescription" : "this scroll does A B C."
#   "scrollscript" :
#   {
#     "command.1" : "",
#     "command.2" : "",
#   }
# }
# ```

# --------------------------------------------------------------------- main ---

# ----- common functions

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

# ----- local functions

buildReport() {
  LOCAL_LOGIN=$1
  LOCAL_SERVER=$2

  if [ -z "$LOCAL_LOGIN" ] || [ -z "$LOCAL_SERVER" ]; then
    echo "missing variables (login name). retype bash command to see."
  else
    echo "Logging onto server environment ($LOCAL_SERVER)"
    ssh "$LOCAL_LOGIN@$LOCAL_SERVER" 'sudo bash -s' < swissknife.docker-report.sh
    ssh "$LOCAL_LOGIN@$LOCAL_SERVER" 'tail -10 report.yml'
  fi
}

# ----- check arguments
DTTITLE="***"
DTTEXT="     "

# ----- check arguments

EXPECTED_ARGS=1  # expected number of arguments in command line
E_BADARGS=65                      #

if [ "$#" -lt "$EXPECTED_ARGS" ]; then
  printf "\n%s" "$DTTEXT"
  printf "\n%s Jimmys Configuration Manager" "$DTTITLE"
  printf "\n%s JCM is a configuration tool for building and configuring machines (as well as cloud based VMs). It reads a basic jcm file (json format) which specifies the intended state and ensures the target (which can be remote or local) corresponds to the jot file specification. It WILL automatically install missing applications and highlight ones that already exist." "$DTTEXT"
  printf "\n%s" "$DTTEXT"
  printf "\n%s USAGE" "$DTTITLE"
  printf "\n%s %s init             # initialize generates a sample jot script if none is found" "$DTTEXT" "$0"
  printf "\n%s %s remote [IP]      # execute run default jot file script on remote" "$DTTEXT" "$0"
  printf "\n%s %s local            # execute run default jot file script locally" "$DTTEXT" "$0"
  printf "\n%s %s help / -h        # show commands" "$DTTEXT" "$0"
  printf "\n%s %s version / -v     # show version number" "$DTTEXT" "$0"
  printf "\n%s" "$DTTEXT"
  printf "\n%s EXAMPLES" "$DTTITLE"
  printf "\n%s %s -v" "$DTTEXT" "$0"
  printf "\n%s" "$DTTEXT"
  exit "$E_BADARGS"
fi

# ----- variables

VERSION_NO="0.1.2"
SLIENT_INSTALL=true

#an interactive password updater will run at the end to change this password to one of your choice
#you should change this to one of your own passwords; i recommend using keepassX to generate at least 128bit unique passwords without odd non alphanumberic words; also use lower caps to ensure ease of typing in.

INSTALL_backintime=true
INSTALL_cifs=true #smb client
INSTALL_git=true
INSTALL_graphicsmagick=true
INSTALL_java7=true
INSTALL_java8=true
INSTALL_nginx=true
INSTALL_nvmnodejs=true
INSTALL_postgres93=true
INSTALL_samurai=true
INSTALL_vim=true
INSTALL_x11vncserver=true

SET_java7_default=false
SET_java8_default=true

#INSTALL_mysql=false
#INSTALL_mongodb=false
#INSTALL_sqlite=false
#INSTALL_nginx=true

#do not change variables below
SLIENT_YES="" #slient yes use for slient installs, this just appends -y or nothing

if [ "$SLIENT_INSTALL" = true ]; then
  export DEBIAN_FRONTEND=noninteractive
  SLIENT_YES="-y"
fi

# ----- main code

SK_CMD=$1
SK_LOGIN=$2

case "$SK_CMD" in
  opt-1)
    echo "Logging onto local server environment"
    buildReport "$SK_LOGIN" 10.131.4.40
    ;;
  ls)
    echo "test ls"
    ;;
  *)
    die
esac


printf "\n%s" "$DTTEXT"
printf "\n%s script: terracotta (v%s) - an auto server setup" "$DTTITLE" "$VERSION_NO"
printf "\n%s" "$DTTEXT"

printf "\n%s" "$DTTEXT"
printf "\n%s warning: this script is designed specifically for *buntu trusty 14.04 LTS. Lubuntu 14.04 Full highly recommended" "$DTTEXT"
printf "\n%s" "$DTTEXT"

# switching to root and installing default applications
printf "\n%s updating server as root" "$DTTITLE"

if [ "$(id -u)" != "0" ]; then
   printf "\n%s this script must be run as root. try sudo <script>" "$DTTEXT" 1>&2
   exit 1
fi

sudo apt-get update $SLIENT_YES
sudo apt-get upgrade $SLIENT_YES
sudo apt-get dist-upgrade $SLIENT_YES
sudo apt-get install build-essential $SLIENT_YES
sudo apt-get install python-software-properties $SLIENT_YES
sudo apt-get install curl $SLIENT_YES

# installing selected applications

if [ "$INSTALL_backintime" = true ]; then
  printf "\n%s installing backintime" "$DTTEXT"
  sudo add-apt-repository ppa:bit-team/stable
  sudo apt-get update $SLIENT_YES
  sudo apt-get install backintime-common $SLIENT_YES
fi

if [ "$INSTALL_cifs" = true ]; then
  printf "\n%s installing cifs" "$DTTEXT"
  sudo apt-get install cifs-utils "$SLIENT_YES"
fi

if [ "$INSTALL_git" = true ]; then
  printf "\n%s installing git" "$DTTEXT"
  sudo add-apt-repository ppa:git-core/ppa
  sudo apt-get update "$SLIENT_YES"
  sudo apt-get install git "$SLIENT_YES"
fi

if [ "$INSTALL_graphicsmagick" = true ]; then
  printf "\n%s installing graphicsmagick" "$DTTEXT"
  sudo apt-get install graphicsmagick "$SLIENT_YES"
fi

if [ "$INSTALL_java7" = true ]; then
  printf "\n%s installing java7" "$DTTEXT"
  sudo add-apt-repository ppa:webupd8team/java
  sudo apt-get install oracle-java7-installer "$SLIENT_YES"
fi

if [ "$INSTALL_java8" = true ]; then
  printf "\n%s installing java8" "$DTTEXT"
  sudo add-apt-repository ppa:webupd8team/java
  sudo apt-get install oracle-java8-installer "$SLIENT_YES"
fi

if [ "$INSTALL_nginx" = true ]; then
  printf "\n%s installing nginx" "$DTTEXT"
  sudo add-apt-repository ppa:nginx/stable
  sudo apt-get install nginx "$SLIENT_YES"
fi

if [ "$INSTALL_nvmnodejs" = true ]; then
  printf "\n%s installing nvm for node/iojs management" "$DTTEXT"
  sudo curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.25.4/install.sh | bash
fi

if [ "$INSTALL_postgres93" = true ]; then
  printf "\n%s installing postgres9.3" "$DTTEXT"
  sudo curl -vs https://www.postgresql.org/media/keys/ACCC4CF8.asc 2>&1 | apt-key add -
  sudo apt-get update "$SLIENT_YES"
  sudo apt-get install postgresql-9.3 pgadmin3 "$SLIENT_YES"
  printf "\ndeb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/postgresql.list
fi

if [ "$INSTALL_samurai" = true ]; then
  printf "\n%s installing samurai" "$DTTEXT"
  sudo curl -LO https://raw.githubusercontent.com/mirageglobe/samurai/master/install.sh | bash
fi

if [ "$INSTALL_vim" = true ]; then
  printf "\n%s installing vim" "$DTTEXT"
  sudo apt-get install vim "$SLIENT_YES"
fi

if [ "$INSTALL_x11vncserver" = true ]; then
  printf "\n%s installing x11vnc" "$DTTEXT"
  sudo apt-get install x11vnc "$SLIENT_YES"
fi

# all the settings here

if [ "$SET_java7_default" = true ]; then
  printf "\n%s setting default java7" "$DTTEXT"
  sudo apt-get update "$SLIENT_YES"
  sudo apt-get install oracle-java7-set-default "$SLIENT_YES"
fi

if [ "$SET_java8_default" = true ]; then
  printf "\n%s setting default java8" "$DTTEXT"
  sudo apt-get update "$SLIENT_YES"
  sudo apt-get install oracle-java8-set-default "$SLIENT_YES"
fi

sudo apt-get autoremove "$SLIENT_YES"
printf "\n%s COMPLETE" "$DTTITLE"

# all installations complete. please run setpasswords to update individual passwords for these applications.
printf "\n%s all installations are complete" "$DTTEXT"
printf "\n%s please reset the passwords for the applications installed." "$DTTEXT"


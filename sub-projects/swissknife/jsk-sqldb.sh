#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Database management and backup utility for MySQL, MariaDB, and others.
# version     : 0.1.0

# ------------------------------------------------------------------ todo ---

# - check db backup file health
# - check db operation connection health
# - support mysql/mariadb
# - support couchdb
# - support mongodb
# - add unit test (https://github.com/kward/shunit2) or (https://github.com/bats-core/bats-core)
# - push and pull standard flat files (to support json or other flat file dbs)
# - install to commandline executable by user (/Users/usr/.jdm)
# - uninstall option which removes from bin
# - add to homebrew

# --------------------------------------------------------------------- main ---

# ----- include libraries


# ----- check arguments

MG_TITLE="**"
MG_TEXT="  "

# ----- constants

MG_ARG1=$1
MG_ARG2=$2

export VERSION_NO="0.1.0"
export DEFAULT_PASS="defaultpass"

# an interactive password updater will run at the end to change this password to one of your choice
# you should change this to one of your own passwords; i recommend using keepassX to generate at least 128bit unique passwords without odd non alphanumberic words; also use lower caps to ensure ease of typing in.

# ----- common functions

print_help() {
  printf "\\n%s jimmys database manager" "$MG_TITLE"
  printf "\\n"
  printf "\\n%s %s backup-mysql [target]     # backsup target (remote) db to local with datastamp." "$MG_TEXT" "$0"
  printf "\\n%s %s restore-mysql [target]    # restores latest local db to remote." "$MG_TEXT" "$0"
  printf "\\n%s %s status [target]           # does local checks." "$MG_TEXT" "$0"
  printf "\\n%s %s help                      # shows help" "$MG_TEXT" "$0"
  printf "\\n"
  printf "\\n%s EXAMPLES :" "$MG_TITLE"
  printf "\\n%s %s status myuser@127.0.0.1:2222" "$MG_TEXT" "$0"
  printf "\\n%s %s status myuser@127.0.0.1" "$MG_TEXT" "$0"
  printf "\\n"
  printf "\\n%s NOTES :" "$MG_TITLE"
  printf "\\n%s - [target] refers to target IP address which is made up of user, ip, and port. for example myuser@127.0.0.1:2222" "$MG_TEXT"
  printf "\\n%s - [target] all three values: user, ip, and port are optional" "$MG_TEXT"
  printf "\\n%s - [target] if port is left out, the default port will be used. for example mysql/mariadb is 3306" "$MG_TEXT"
}

is_valid_ip() {

  full_ip=${1:-$1}
  rtn_val=1
  check_var=0

  if expr "$full_ip" : "[0-9][0-9]*\\.[0-9][0-9]*\\.[0-9][0-9]*\\.[0-9][0-9]*$" >/dev/null; then
    rtn_val=0 #first pass above is true thus true

    for i in 1 2 3 4; do
      check_var=$(echo "$full_ip" | cut -d. -f$i)
      if [ "$check_var" -gt 255 ]; then
        rtn_val=1
      fi
    done
  fi

  return $rtn_val
}

is_valid_port() {

  full_ip=${1:-$1}
  rtn_val=1
  check_var=$(echo "$full_ip" | cut -d. -f2)

  if test "$check_var" -lt 65536; then
    rtn_val=0
  else
    rtn_val=1
  fi

  return $rtn_val
}

is_installed_app() {

  rtn_val=1
  test_cmd=$1
  # using which to find if binary exists in path

  if command -v "$test_cmd" >/dev/null 2>&1; then
    rtn_val=$?
  fi

  return $rtn_val
}

print_target() {

  rtn_val=root
  parse_val=$1
  val_user=0
  val_ip=0
  val_port=0

  val_user="${1%%@*}"           # remove all words after @
  val_ipport="${1##*@}"         # remove all words before @ resulting in ip:port
  val_ip="${val_ipport%%:*}"    # remove all words after : resulting in ip
  val_port="${val_ipport##*:}"  # remove all words before : resulting in port

  printf "\\nuser: %s" "$val_user"
  printf "\\nip: %s" "$val_ip"
  printf "\\nport: %s" "$val_port"

  printf "\\n"

  if expr "$parse_val" : '.*@' > /dev/null; then
    printf "\\nuser found .. with @ sign found : %s" "$val_user"
  fi

  if expr "$parse_val" : '.*\:' > /dev/null; then
    printf "\\nport found .. with : sign found : %s" "$val_port"
  fi

  printf "\\n"
}

get_target_user() {

  parse_val=$1
  val_user=0
  val_ip=0
  val_port=0

  val_user="${1%%@*}"           # remove all words after @
  val_ipport="${1##*@}"         # remove all words before @ resulting in ip:port
  val_ip="${val_ipport%%:*}"    # remove all words after : resulting in ip
  val_port="${val_ipport##*:}"  # remove all words before : resulting in port

  #fix for non existant user variable, if @ not found
  if expr "$parse_val" : '.*\@' > /dev/null; then
    #user exists
    val_user="${1%%@*}"         # reinit value as above as posix regex does not support lookahead/behinds
  else
    val_user=""
  fi

  printf "%s" "$val_user"  #note that this print can be captured by call using val=$(get_target_user "127.0.0.1")
}

get_target_ip() {

  parse_val=$1
  val_user=0
  val_ip=0
  val_port=0

  val_user="${1%%@*}"           # remove all words after @
  val_ipport="${1##*@}"         # remove all words before @ resulting in ip:port
  val_ip="${val_ipport%%:*}"    # remove all words after : resulting in ip
  val_port="${val_ipport##*:}"  # remove all words before : resulting in port

  #fix for non existant ip variable, if . not found
  if expr "$parse_val" : '.*\.' > /dev/null; then
    #ip exists
    val_ip="${val_ipport%%:*}"
  else
    val_ip=""
  fi

  printf "%s" "$val_ip"
}

get_target_port() {

  parse_val=$1
  val_user=0
  val_ip=0
  val_port=0

  val_user="${1%%@*}"           # remove all words after @
  val_ipport="${1##*@}"         # remove all words before @ resulting in ip:port
  val_ip="${val_ipport%%:*}"    # remove all words after : resulting in ip
  val_port="${val_ipport##*:}"  # remove all words before : resulting in port

  #fix for non existant port variable, if : not found
  if expr "$MG_ARG2" : '.*\:' > /dev/null; then
    #port exists
    val_port="${val_ipport##*:}"  # remove all words before : resulting in port
  else
    val_port=""
  fi

  printf "%s" "$val_port"
}

run_remote_cmd() {

  rtn_val=0
  export parse_val_user=$1
  export parse_val_ip=$2
  export parse_val_port=$3

  printf "%s@%s:%s" "$1" "$2" "$3"

  return $rtn_val
}

print_success() {
  printf "\\342\\234\\224 %s" "$1"
}

print_error() {
  printf "\\342\\234\\226 %s" "$1"
}

# ----- main

EXPECTED_ARGS=1
E_BADARGS=65

if [ "$#" -lt "$EXPECTED_ARGS" ]; then
  print_help
  printf "\\n\\n"
  exit $E_BADARGS
fi

# checking target ip address and assigning values (user@ip:port)
export MG_TARGETIP=0
export MG_TARGETUSER=0
export MG_TARGETPORT=0

#print_target "$MG_ARG2"

MG_TARGETIP=$(get_target_ip "$MG_ARG2")
MG_TARGETUSER=$(get_target_user "$MG_ARG2")
MG_TARGETPORT=$(get_target_port "$MG_ARG2")

printf "\\n" # line gap to prettify code

# checking main options for user
case "$MG_ARG1" in
  backup-mysql)
    printf "%s backup running" "$MG_TITLE"
    printf "\\n"

    printf "%s using values (args) : user (%s) - ip (%s) - port (%s)" "$MG_TEXT" "$MG_TARGETUSER" "$MG_TARGETIP" "$MG_TARGETPORT"
    printf "\\n"

    # checking for a valid ip address
    if is_valid_ip "$MG_TARGETIP"; then
      print_success " target ip valid"
      printf "\\n"
      # backup of all databases - mysql
      #mysqldump --all-databases > all_databases.sql
      # mysqldump -u [user] -p --all-databases > [file_name].sql
    else
      print_error "target ip invalid or not provided. if you are running it locally, please run with 127.0.0.1 which is a backloop"
      printf "\\n"
    fi

    # connect remote ip and find db
    ;;
  restore-mysql)
    printf "%s restore running" "$MG_TITLE"
    printf "\\n"

    # checking for a valid ip address
    if is_valid_ip "$MG_TARGETIP"; then
      print_success " target ip valid"
      printf "\\n"
      # restore all databases - mysql
      # mysql -u username -p < dump.sql
    else
      print_error "target ip invalid or not provided. if you are running it locally, please run with 127.0.0.1 which is a backloop"
      printf "\\n"
    fi
   ;;
  status)
    printf "%s status" "$MG_TITLE"
    printf "\\n"

    printf "%s using values (args) : user (%s) - ip (%s) - port (%s)" "$MG_TEXT" "$MG_TARGETUSER" "$MG_TARGETIP" "$MG_TARGETPORT"
    printf "\\n"
    if is_valid_ip "$MG_TARGETIP"; then
      print_success "target ip valid"
      printf "\\n"
    else
      print_error "target ip invalid"
      printf "\\n"
    fi

    #checking ssh
    if is_installed_app "ssh"; then
      print_success "ssh binary found"
      printf "\\n"
    else
      print_error "ssh binary missing"
      printf "\\n"
    fi

    #checking curl
    if is_installed_app "curl"; then
      print_success "curl binary found"
      printf "\\n"
    else
      print_error "curl binary missing"
      printf "\\n"
    fi

    printf "\\n%s services" "$MG_TITLE"
    printf "\\n"

    #checking mysql/mariadb
    if is_installed_app "mysqld"; then
      print_success "mysql/mariadb binary found"
      printf "\\n"
    else
      print_error "mysql/mariadb binary missing"
      printf "\\n"
    fi

    #checking couchdb
    if is_installed_app "couchdb"; then
      print_success "couchdb binary found"
      printf "\\n"
    else
      print_error "couchdb binary missing"
      printf "\\n"
    fi

    #checking mongodb
    if is_installed_app "mongod"; then
      print_success "mongod binary found"
      printf "\\n"
    else
      print_error "mongod binary missing"
      printf "\\n"
    fi
    ;;
  help)
    print_help
    ;;
  *)
    print_error "invalid input arguments. to use, please refer to help."
    printf "\\n"
esac

printf "\\n"

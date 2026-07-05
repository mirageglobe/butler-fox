#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Utility for converting and displaying UTF-8 character sequences.
# version     : 0.1.0

# --------------------------------------------------------------------- main ---

# usage: ./script.sh [utf char]

if [ -z "$1" ]; then
  echo "usage : $0 <utf char>";
  echo "        $0 5";
  exit 0;
fi

printf "==> use bash and not sh \n"
printf "0 1 2 3 4 5 6 7 8 9 a b c d e f \n"
printf "\n"

echo "==> to test flag and printf or echo"
echo -e "\ue3c4"
printf "\\ue3c4 \n"
printf "\n"

echo "==> to test code: $1"
echo -e "unicode : \u$1"

# in utf-8 it's actually 6 digits (or 3 bytes)
echo "==> print utf using hex 6 digits / 3 bytes"
printf '\xe2\x98\xa0 \n'
printf "\n"

# to check how its encoded
echo "==> print hexdump to check encoding"
printf ☠ | hexdump

# -e is not posix; use \033 instead
# printf '\033[3;12r\033[3H'

# for y in $(seq 0 524287)
#   do
#   for x in $(seq 0 7)
#   do
#     a=$(expr $y \* 8 + $x)
#     echo -ne "$a \\u$a "
#   done
#   echo
# done

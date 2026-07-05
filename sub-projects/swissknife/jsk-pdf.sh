#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Utility for manipulating, joining, and processing PDF documents.
# version     : 0.1.0

# ---------------------------------------------------------------- reference ---

# - http://superuser.com/questions/134679/command-line-application-for-converting-svg-to-png-on-mac-os-x

# --------------------------------------------------------------------- main ---

# use pdf output only

# ----- include libraries

# ----- check arguments

EXPECTED_ARGS=2
E_BADARGS=65

if [ "$#" -lt "$EXPECTED_ARGS" ]; then
  echo "$DTTITLE script:"
  echo "$DTTEXT this script converts with ghostscript and does postcompression. Dependancies: ghostscript(brew)"
  echo "$DTTITLE usage:"
  echo "$DTTEXT $0 [options] [arguments]"
  echo "$DTTEXT $0 -g /path/to/file             : compress pdf"
  echo "$DTTEXT $0 -o /path/to/image /new/file  : (soon) set output file"
  echo "$DTTITLE examples:"
  echo "$DTTEXT $0 -h /home/useraccount/myfirst/pdffile.pdf"
  echo "$DTTITLE notes:"
  echo "$DTTEXT N/A"

  exit $E_BADARGS
fi

# ----- Define Variables

SKOPTIONS=$1
FILEFULL=$2

FILENAME="${FILEFULL%.*}"
FILEPDF="${FILENAME}.pdf"

DSTAMP=$(date +%y%m%d)

# ----- Main Code

echo "*** ----- "
echo "*** Running : Compress PDF"
echo "*** ----- "

# checks first char of string to be -

echo "$DTTITLE validating options"
if [[ ${SKOPTIONS::1} == "-" ]]; then
  echo "$DTTEXT [ok]"
else
  echo "$DTTEXT options wrongly defined [abort]"
  exit 1;
fi

# checking destination of file

echo "$DTTEXT checking file ${FILEFULL}"
if [ ! -f "${FILEFULL}" ]; then
  echo "$DTTEXT file not found [abort]"
  exit 1
else
  echo "$DTTEXT [ok]"
fi

# backup current pdf

if [ -f "${FILEPDF}" ]; then

  echo "$DTTEXT backing up current file"
  cp -i "${FILEPDF}" "${FILENAME}_$DSTAMP.pdf"
  echo "$DTTEXT [ok]"

fi


# pdf ebook quality

# pdf printer quality

if [[ "${SKOPTIONS}" =~ "h" ]]; then

  echo "$DTTEXT checking ghostscript installation"
  command -v gs >/dev/null 2>&1 || { echo "$ESST ghostscript not installed. try brew install ghostscript [abort]" >&2; exit 1; }
  echo "$DTTEXT [ok]"

  echo "$DTTITLE compress using ghostscript"
  ghostscript -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf "${FILEPDF}"
  echo "$DTTEXT [ok]"

  echo "$DTTEXT replacing output png with compressed version"
  mv "${IMAGENAME}-fs8.png" "${IMAGEPNG}"
  echo "$DTTEXT [ok]"

fi

# complete
echo "$DTTITLE done ... [ok]"

#!/usr/bin/env bash

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# purpose     : Image conversion and optimization utility with a focus on PNG.
# version     : 0.1.0

# ---------------------------------------------------------------- reference ---

# - http://superuser.com/questions/134679/command-line-application-for-converting-svg-to-png-on-mac-os-x

# --------------------------------------------------------------------- main ---

# use pngquant for web (lossy)
# use optipng for print (lossless)
# use http://phantomjs.org/screen-capture.html to print to pdf or png from svg
# use convert -d 300 foo.pdf bar.png for higher ppi(dpi) - http://askubuntu.com/questions/50170/how-to-convert-pdf-to-image
# use ls *.jpg|while read i;do gm convert $i -resize "900x" -unsharp 2x0.5+0.5+0 -quality 98 `basename $i .jpg`_s.jpg;done

# to convert for android .... try gm convert "input.png" -resize 2481x3507 -bit-depth=32 "output.png"
# ----- include libraries

# this code converts a png for web to 800x600 WxH at 72 dpi (if needed)

# ----- Check Arguments

DTTITLE=""
DTTEXT="   "

EXPECTED_ARGS=2
E_BADARGS=65

if [ "$#" -lt "$EXPECTED_ARGS" ]; then
  echo "$DTTEXT"
  echo "$DTTITLE script:"
  echo "$DTTEXT this script converts with graphicsmagick and does postcompression. Dependancies: graphicsmagick(brew), pngquant(brew) or pngquant-bin(npm), optipng(brew) or optipng-bin(npm), svgexport(npm)"
  echo "$DTTEXT"
  echo "$DTTITLE usage:"
  echo "$DTTEXT $0 [options] [source:path/to/file] [target:path/to/file]"
  echo "$DTTEXT $0 -g /path/to/image            : convert to grayscale"
  echo "$DTTEXT $0 -w /path/to/image            : convert for (w)eb 800x600 WxH 72dpi png (webstandard)"
  echo "$DTTEXT $0 -p /path/to/image            : convert for (p)rint 2481x3507 WxH (fullA4) 300dpi png (printstandard)"
  echo "$DTTEXT $0 -l /path/to/image            : compress to (l)ossy based on pngquant"
  echo "$DTTEXT $0 -s /path/to/image            : compress to lossles(s) based on optipng"
  echo "$DTTEXT $0 -i /path/to/image            : (soon) generate icons including .ico .png appletouch win8tile"
  echo "$DTTEXT $0 -o /path/to/image /new/file  : (soon) set output file"
  echo "$DTTEXT"
  echo "$DTTITLE examples:"
  echo "$DTTEXT $0 -w /home/useraccount/myfirst/image.png"
  echo "$DTTEXT $0 -wl /home/useraccount/myfirst/image.png"
  echo "$DTTEXT $0 -ws /home/useraccount/myfirst/image.svg"
  echo "$DTTEXT"
  echo "$DTTITLE notes:"
  echo "$DTTEXT options l and s are not interoperable"
  echo "$DTTEXT options w and p are not interoperable"
  echo "$DTTEXT"

  exit $E_BADARGS
fi

# ----- Define Variables

GMOPTIONS=$1
IMAGEFULL=$2

IMAGEEXT="${IMAGEFULL##*.}"
IMAGENAME="${IMAGEFULL%.*}"
IMAGEPNG="${IMAGENAME}.png"

DSTAMP=$(date +%y%m%d)

# ----- Main Code
#if target file is empty. set it to current file



echo "*** ----- "
echo "*** Running : MakeGMpng"
echo "*** ----- "

# checks first char of string to be -

echo "$DTTITLE validating options"
if [[ ${GMOPTIONS::1} == "-" ]]; then
  echo "$DTTEXT [ok]"
else
  echo "$DTTEXT options wrongly defined [abort]"
  exit 1;
fi

# checking destination of file

echo "$DTTEXT checking graphics file ${IMAGEFULL}"
if [ ! -f "${IMAGEFULL}" ]; then
  echo "$DTTEXT file not found [abort]"
  exit 1
else
  echo "$DTTEXT [ok]"
fi


# auto convert svg to 2x

if [[ "${IMAGEEXT}" == "svg" ]]; then

  echo "$DTTEXT checking svgexport installation"
  command -v gm >/dev/null 2>&1 || { echo "$ESST svgexport not installed [abort]" >&2; exit 1; }
  echo "$DTTEXT [ok]"

  echo "$DTTEXT export svg to png using svgexport"
  svgexport "${IMAGEFULL}" "${IMAGEPNG}" png 100% "" 2x
  echo "$DTTEXT [ok]"

fi


# backup current image

if [ -f "${IMAGEPNG}" ]; then

  echo "$DTTEXT backing up current image"
  cp -i "${IMAGEPNG}" "${IMAGENAME}_$DSTAMP.png"
  echo "$DTTEXT [ok]"

fi


# convert grayscale

if [[ "${GMOPTIONS}" =~ "g" ]]; then

  # checking application installation
  echo "$DTTITLE convert to grayscale"

  echo "$DTTEXT checking graphicsmagick installation"
  command -v gm >/dev/null 2>&1 || { echo "$ESST graphicsmagick not installed [abort]" >&2; exit 1; }
  echo "$DTTEXT [ok]"

  # compressing image: may need to rescale to 300x300 dpi in option
  echo "$DTTEXT grayify"
  gm convert "${IMAGEPNG}" -type Grayscale -colorspace GRAY "${IMAGEPNG}"
  echo "$DTTEXT [ok]"

fi


# convert for web 800x600 72dpi

if [[ "${GMOPTIONS}" =~ "w" ]]; then

  # checking application installation
  echo "$DTTITLE convert and compress for (w)eb"

  echo "$DTTEXT checking graphicsmagick installation"
  command -v gm >/dev/null 2>&1 || { echo "$ESST graphicsmagick not installed [abort]" >&2; exit 1; }
  echo "$DTTEXT [ok]"

  # compressing image: may need to rescale to 300x300 dpi in option
  echo "$DTTEXT resizing image"
  gm convert "${IMAGEPNG}" -resize 800x600 -quality 95 "${IMAGEPNG}"
  echo "$DTTEXT [ok]"

fi


# convert for print 2481x3507 300dpi WxH A4portrait

if [[ "${GMOPTIONS}" =~ "p" ]]; then

  # checking application installation
  echo "$DTTITLE convert and compress for (p)rint"

  echo "$DTTEXT checking graphicsmagick installation"
  command -v gm >/dev/null 2>&1 || { echo "$ESST graphicsmagick not installed [abort]" >&2; exit 1; }
  echo "$DTTEXT [ok]"

  # compressing image: may need to rescale to 300x300 dpi in option
  echo "$DTTEXT resizing image"
  gm convert "${IMAGEPNG}" -resize 2481x3507 -quality 95 "${IMAGEPNG}"
  echo "$DTTEXT [ok]"

fi


# lossy compression

if [[ "${GMOPTIONS}" =~ "l" ]]; then

  echo "$DTTEXT checking pngquant installation"
  command -v pngquant >/dev/null 2>&1 || { echo "$ESST pngquant not installed [abort]" >&2; exit 1; }
  echo "$DTTEXT [ok]"

  echo "$DTTITLE compress using pngquant (lossy)"
  pngquant --force "${IMAGEPNG}"
  echo "$DTTEXT [ok]"

  echo "$DTTEXT replacing output png with compressed version"
  mv "${IMAGENAME}-fs8.png" "${IMAGEPNG}"
  echo "$DTTEXT [ok]"

fi


# lossless compression

if [[ "${GMOPTIONS}" =~ "s" ]]; then

  echo "$DTTEXT checking optipng installation"
  command -v optipng >/dev/null 2>&1 || { echo "$ESST optipng not installed [abort]" >&2; exit 1; }
  echo "$DTTEXT [ok]"

  echo "$DTTITLE compress using optipng (lossy)"
  optipng "${IMAGEPNG}"
  echo "$DTTEXT [ok]"

fi

if [[ "${GMOPTIONS}" =~ "i" ]]; then
  echo "$DTTITLE converting tbc"
fi

if [[ "${GMOPTIONS}" =~ "o" ]]; then
  echo "$DTTITLE converting tbc"
fi

# complete
echo "$DTTITLE done ... [ok]"

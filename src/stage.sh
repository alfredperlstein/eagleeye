#!/bin/sh

mydir=`dirname $0`
dir=$1
if [ "x$dir" = "x" ] ; then
    echo "usage: $0 <dir>"
    echo "copies all files for web display to <dir>"
    exit 1
fi

mkdir -p $dir

cp -v index.html large.html $dir
cp -v *.png $dir
cp -v "${mydir}"/*.js $dir
cp -v "${mydir}"/*.css $dir

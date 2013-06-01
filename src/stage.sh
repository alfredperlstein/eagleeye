#!/bin/sh

dir=$1
if [ "x$dir" = "x" ] ; then
    echo "usage: $0 <dir>"
    echo "copies all files for web display to <dir>"
    exit 1
fi

mkdir -p $dir

cp *.html *.js *.css *.png $dir

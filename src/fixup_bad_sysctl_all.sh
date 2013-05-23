#!/bin/sh

# fixup bad sysctl logs grabbed from old version of eagleeye

#
# If we are given arguments, then act on each argument as a filename
# to manipulate instead of a pipe.
#
if [ "x$1" != "x" ] ; then
    INPLACE="-i .bak"
fi

# the old regex for sysctl pruning was letting in bad strings
# such as "<118> syncpeer: 0.0.0.0 maxupd: 128", use this
# sed to strip it out.

# 1st pattern: replace any column that doesn't start with [a-z]
# 2nd pattern: replace any column that has non numeric data
# 3rd pattern: replace any column with multiple occurences of whitespace
sed $INPLACE \
     -e 's/|[^a-z][^|]*//g' \
     -e 's/|[^|:]*: [^0-9][^|]*//g' \
     -e 's/|[^| ]* [^| ]* [^|]*//g' \
     $*


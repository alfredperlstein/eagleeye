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

# Patterns:
# 1: Remove leading whitespace from any column
# 2: remove any column that doesn't start with [a-z]
# 3: remove any column that has non numeric data
# 4: remove any column with multiple occurences of whitespace
sed $INPLACE \
     -e 's/| */|/g' \
     -e 's/|[^a-z][^|]*//g' \
     -e 's/|[^|:]*: [^0-9][^|]*//g' \
     -e 's/|[^| ]* [^| ]* [^|]*//g' \
     $*


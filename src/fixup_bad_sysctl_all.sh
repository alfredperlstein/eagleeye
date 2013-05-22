#!/bin/sh

# fixup unparseable sysctl logs.

# the old regex for sysctl pruning was letting in bad strings
# such as "<118> syncpeer: 0.0.0.0 maxupd: 128", use this
# sed to strip it out.

if [ "x$1" != "x" ] ; then
    INPLACE="-i .bak"
fi

sed $INPLACE -e 's/|[^a-z][^|]*//g' -e 's/|[^|:]*: [^0-9][^|]*//g' $*


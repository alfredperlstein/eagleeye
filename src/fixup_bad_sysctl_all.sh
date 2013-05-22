#!/bin/sh

# fixup unparseable sysctl logs.

# the old regex for sysctl pruning was letting in bad strings
# such as "<118> syncpeer: 0.0.0.0 maxupd: 128", use this
# sed to strip it out.

sed 's/|[^a-z][^|]*/|/g'

#!/bin/sh
 
# Copyright (c) 2013, iXSystems Inc. 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#     Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 
#     Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer
#     in the documentation and/or other materials provided with the
#     distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

INDEX_FILE="index.html"
LARGE_FILE="large.html"

echo "<html><head><title>graphed data</title></head><body>" > $INDEX_FILE
echo "<html><head><title>graphed data</title></head><body>" > $LARGE_FILE

for file in *.png ; do
    echo "$file"
    echo "<a href=\"${LARGE_FILE}#${file}\">" >> $INDEX_FILE
    echo "<p>$file<br>" >> $INDEX_FILE
    echo "<img src=\"${file}\" height=200 width=400><br>" >> $INDEX_FILE
    echo "</a>" >> $INDEX_FILE

    echo "<a id=\"${file}\"><p>$file<br></a>" >> $LARGE_FILE
    echo "<img src=\"${file}\"><br>" >> $LARGE_FILE
done

echo "</body></html>" >> $LARGE_FILE
echo "</body></html>" >> $INDEX_FILE
echo "done."


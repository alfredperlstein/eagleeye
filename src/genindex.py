#!/usr/local/bin/python
"""
BSD 2-Clause License:
 
Copyright (c) 2013, iXSystems Inc. 
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""


import glob

def main():
    pngs = glob.glob('*.png')
    if pngs is None:
	sys.exit(0)


    indexfile = open("index.html", 'wb')
    largefilename = "large.html"
    largefile = open(largefilename, 'wb')

    html = "<html><head><title>graphed data</title></head><body>\n"
    indexfile.write(html)
    largefile.write(html)

    div = None
    for file in pngs:
	indexfile.write("<a href=\"" + largefilename + "#${file}\">")
	indexfile.write("<p>" + file + "<br>")
	indexfile.write("<img src=\"" + file + "\" height=200 width=400><br>")
	indexfile.write("</a>")

	largefile.write("<a id=\"" + file + "\"><p>" + file + "<br></a>")
	largefile.write("<img src=\"" + file + "\"><br>")
	print "linked: " + file

    html = "</body></html>"
    indexfile.write(html)
    largefile.write(html)

if __name__ == "__main__":
     main()
    

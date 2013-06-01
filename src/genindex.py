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
import re

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

    indexfile.write('<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js"></script>\n')
    indexfile.write('<div id="test"></div>\n')
    
    all_divs = list()

    div = None
    insysctl = False # sysctl output is huge, track that we're inside it.
    indent = ""
    current_divname = None
    for file in pngs:

	# we want to do a decent job of splitting this page up based
	# mibs, so try to group the mibs based on number of components
	# in the mib.

	# get everything but the .png
	mibarray = file.split(".")[:-1]

	# sysctl is very big, wrap the entire thing with a div
	if mibarray[0] == "sysctl_all":
	    mibarray = mibarray[1:] # trim off the sysctl_all
	    if not insysctl:
		insysctl = True
		indexfile.write('<div id="sysctl_all">\n')
		indent += "  "
	else:
	    if insysctl:
		insysctl = False
		indexfile.write('</div> <!-- div id="sysctl_all"-->\n')
		indent = indent[:-2]

	# if the mib is small then just make a div for the top level,
	# otherwise make it for the secondary levels
	if len(mibarray) < 3:
	    divname = mibarray[0]
	else:
	    divname = ".".join(mibarray[0:2])

	# create a new div if needed (and close an older one)
	if current_divname != divname:
	    # close current div if open
	    #  or update indent if this is the first div we are opening
	    if current_divname != None:
		indent = indent[:-2]
		indexfile.write(indent +
			'</div> <!-- div id="%s"-->\n' % current_divname)
	    current_divname = divname
	    indexfile.write(indent + '<div id="%s">\n' % divname)
	    indent += '  '
	    all_divs.append(divname) 

	#print "div: " + current_divname + " " + divname
	#print mibarray

	indexfile.write(
		indent + "<a href=\"" + largefilename + "#" + file + "\">\n" +
		indent + "  <p>" + file + "<br>\n" +
		indent + "  <img src=\"" + file + "\" height=200 width=400>\n" +
		indent + "<br>\n" + 
		indent + "</a>\n")

	largefile.write("<a id=\"" + file + "\"><p>" + file + "<br></a>")
	largefile.write("<img src=\"" + file + "\"><br>")
	print "--- linked: " + file

    if current_divname != None:
	indexfile.write(indent +
		'</div> <!-- div id="%s"-->\n' % current_divname)

    indexfile.write('<div id="nav">')
    js= '''
	    <script>
	    var allDivs=''' + str(all_divs) + ''';
	    </script>
	    <script src="index.inc.js"></script>
	    '''

    indexfile.write(js)
    print all_divs
    indexfile.write('\n</div> <!-- id="nav"-->\n')


    html = "\n</body></html>"
    indexfile.write(html)
    largefile.write(html)

if __name__ == "__main__":
     main()
    

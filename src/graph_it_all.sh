#!/bin/sh

TRANSFORM="python transform.py"
# Process compressed the newsyslog files.

set -x

process_files()
{
    local FILTER=$1
    shift
    local FILES=$*

    local totfiles=`echo $FILES | wc -w | sed 's/ *//g'`
    local curfile=1

    for file in $* ; do
	echo $file | grep -Eq '/(netstat_mbufs_|vmstat_interupts_|vmstat_z_|zpool_iostat_)'
	if [ $? -eq 0 ] ; then
	    continue
	fi
	echo "Processing file ($curfile of $totfiles) $file..."
	set -e
	if [ -z "$FILTER" ] ; then
	    $TRANSFORM -a -f $file
	else
	    $FILTER $file | $TRANSFORM -a
	fi
	set +e
	echo "Completed $file..."
	curfile=$(($curfile + 1))
    done
}



process_compressed_files()
{

    process_files bzcat `find . -depth 1 -and \( -name \*_second.txt.\*.bz2 -or -name \*_sec.txt.\*.bz2 \)`
}

process_uncompressed_files()
{
    process_files "" `find . -depth 1 -and \( -name \*_second.txt -or -name \*_sec.txt \)`
}

rm *.csv

process_compressed_files
process_uncompressed_files
set -e
for file in ./*.csv ; do
    Rscript --no-save --slave plot_csv.R $file
done
set +e

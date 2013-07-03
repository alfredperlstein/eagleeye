#!/bin/sh

mydir=`dirname $0`
#TRANSFORM_ARGS=" --fixup-date"
TRANSFORM="python ${mydir}/transform.py $TRANSFORM_ARGS"
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
	echo $file | grep -Eq '/(netstat_mbufs_|vmstat_interupts_|vmstat_z_|zpool_iostat_|vmstat_5_second.txt)'
	if [ $? -eq 0 ] ; then
	    continue
	fi
	echo "Processing file ($curfile of $totfiles) $file..."
	set -e
	local prefix=`basename $file | sed 's/_[0-9]_sec.*//'`
	prefix="${prefix}."
	if [ -z "$FILTER" ] ; then
	    $TRANSFORM -a -f $file --prefix $prefix
	else
	    $FILTER $file | $TRANSFORM -a --prefix $prefix
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


rm -f *.csv *.png
process_compressed_files
process_uncompressed_files
set -e
for file in ./*.csv ; do
    base=`basename ${file%.csv}`
    if [ `head -2 $file | wc -l ` -le 1 ] ; then
	echo "Warning file $file has no data, skipping it."
	continue
    fi
    Rscript --no-save --slave ${mydir}/plot_csv.R $file $base ${base}.png
done
set +e

# make html
python ${mydir}/genindex.py

# copy to staging directory
sh ${mydir}/stage.sh stage

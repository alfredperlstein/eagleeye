#!/bin/sh
"""
BSD 2-Clause License:
 
Copyright (c) 2013, iXSystems Inc. 
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

    Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

    Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer
    in the documentation and/or other materials provided with the
    distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

"""
# Author(s): Alfred Perlstein, Larry Maloney
#
# Notes: 
# Just run on the command line. (foreground or background
# Note: You want to first create a mountpoint, so
# you can store the log data off safetly.  If FreeNAS locks up, or crashes,
# The log data will be saved on the mountpoint, and we
# will have a time index to see when it stopped.

#INTERFACES="cxgb0 cxgb1 cxgb2 cxgb3 lagg0"

# set TZ to UTC otherwise date(1) output is really bad to parse.
export TZ=UTC

set_interfaces() {
    # get all UP interfaces except lo|carp|pflog|pfsync
    INTERFACES=`ifconfig | grep UP | grep '^[a-z][a-z]*' | cut -f1 -d: | egrep -v '^(lo|carp|pflog|pfsync)' | paste -s -d " " - `
}

set_interfaces

echo "Interfaces: $INTERFACES"

stdbuf="/usr/bin/stdbuf"
if [ -e "$stdbuf" ] ; then 
    export UNBUFFER="$stdbuf -o L"
fi

: ${LOGDIR="/mnt/logdir"}
: ${POOLNAME="tank"}
: ${USE_HWPMC="yes"}

if [ "$VERBOSE" = "yes" ] ; then
    set -x
fi

: ${SLEEP_SEC=1}

# don't set this, by default we'll do a sysctl -a
#: ${SYSCTL_NODES="vm nfs kern"}

BGPIDS=""

export ISODATE="date +%Y-%m-%dT%H:%M:%S"

end_children()
{

    kill $BGPIDS
}

gothup()
{
    end_children
    echo "Restarting on HUP..."
    exec sh $0
}

cleanup ()
{
    echo "Killing stuff monitoring processes"
    echo "End capturing: ";$ISODATE
    nfsstat > nfsstat_end.txt
    zpool_wrap list > zpool_list_end.txt
    netstat -m > netstat_mbufs_end_of_test.txt
    fstat -m -v  > fstat_end.txt


    arc_summary > arc_summary_end_test.txt

    # Kill pid.

    $ISODATE > end_time.txt
    cp /var/log/messages*  ./messages_end_of_test.txt

    end_children

    exit 0
}

trap cleanup SIGINT SIGTERM
trap gothup SIGHUP

zfs mount > /dev/null
if [ $? -eq 0 ] ; then
    ZFS_AVAILABLE=1
else
    ZFS_AVAILABLE=0
fi

zpool_wrap() {
    if [ $ZFS_AVAILABLE -eq 1 ] ; then
        zpool $*
    else
        echo "zfs not available"
    fi
}


arc_summary() {
    script="/usr/local/www/freenasUI/tools/arc_summary.py"
    if [ -e "$script" ] ; then
        python "$script"
    else
        echo "$script not available."
    fi
}

add_bg() {
    BGPIDS="$BGPIDS $1"
    if [ "$VERBOSE" = "yes" ] ; then
	echo "BGPIDS: $BGPIDS"
    fi
}


echo "You should execute this sript, while the working directory is on an NFS mount point to store the logging data."
echo "Capturing data for: $1"
echo "erasing prior data first"
echo -n "Start time: ";$ISODATE
echo "Poolname: $POOLNAME"

# Command to mount logging dir for client and targets
#----------------------------------------------------
# Samba Example:
# mntlogdir="mount_smbfs -I freenas.ixsystems.com -U guest //guest@freenas/sj-storage"
# NFS:
#echo "Setup Logging directory at $LOGDIR"
#mkdir $LOGDIR
#MNTLOGDIR="mount spec10.sjlab1.ixsystems.com:/usr/home/logdata $LOGDIR"
#echo "We want to run: $MNTLOGDIR"
#eval $MNTLOGDIR
cd $LOGDIR
echo
echo
if [ "$USE_HWPMC" = "yes" ] ; then
    echo "Loading HWPMC..."
    kldload hwpmc
fi
echo "========================Start===================="
rm *.txt
$ISODATE > start_time.txt
uname -v > uname.txt
nfsstat > nfsstat_start.txt
df > df.txt
zpool_wrap list > zpool_list_start.txt
cp /data/freenas* .

arc_summary > arc_summary_start_test.txt

dmesg > dmesg.txt
cp /var/run/dmesg.boot ./dmesg.boot
cp /var/log/messages*  ./
ifconfig > ifconfig.txt
cp /boot/loader.conf  ./loader.conf.txt
cat /boot/loader.conf.local > ./loader.conf.local.txt
cp /etc/rc.conf ./rc.conf.txt
cp /etc/sysctl.conf ./sysctl.conf.txt
sysctl -a > sysctl_all.txt
sysctl vfs.nfs > sysctl_nfs.txt
sysctl vfs.nfsd >> sysctl_nfs.txt
sysctl vfs.zfs > sysctl_zfs.txt
mount > mount.txt
cat /etc/exports > ./exports.txt
gmultipath status > gmulitpathstatus.txt
zpool_wrap status > zpool_status.txt

actstat_cmd()
{
    w=$1
    arcstat="/usr/local/www/freenasUI/tools/arcstat.py"
    # if there's no arcstat, then we're probably on a non-TrueNAS host, then just bail.
    if [ ! -e "${arcstat}" ] ; then
	return
    fi
    # XXX: some of the output of arcstat has "humanized numbers", can we easily graph
    # this?
    python ${arcstat} $w | grep --line-buffered -v 'time' | \
	$UNBUFFER sh -c 'while read arc_time arc_read  arc_miss  arc_miss_pct  arc_dmis  arc_dm_pct  arc_pmis  arc_pm_pct  arc_mmis  arc_mm_pct arc_sz arc_c ; do
	echo `$ISODATE`"|arc_read: $arc_read|arc_miss: $arc_miss|arc_miss_pct: $arc_miss_pct|arc_dmis: $arc_dmis|arc_dm_pct: $arc_dm_pct|arc_pmis: $arc_pmis|arc_pm_pct: $arc_pm_pct|arc_mmis: $arc_mmis|arc_mm_pct: $arc_mm_pct|arc_sz: $arc_sz|arc_c: $arc_c|"
    done' > arcstat_${w}_second.txt &
    add_bg $!
}

iostat_cmd()
{
    w=$1
    iostat w $w | grep --line-buffered -v '[^0-9 ]' | \
	$UNBUFFER sh -c 'while read tin tout us ni sy in id ; do 
	echo `$ISODATE`"|tin: $tin|tout: $tout|us: $us|ni: $ni|sy: $sy|in: $in|id: $id|" ;
    done' > iostat_${w}_second.txt &
    add_bg $!
}

#Added by larry to parse output just like iostat.  Need to test
nfsstat_cmd()
{
    w=$1
    nfsstat -e -s -w  $w | grep --line-buffered -v '[^0-9 ]' | \
        $UNBUFFER sh -c 'while read GtAttr Lookup Rdlink Read  Write Rename Access  Rddir ; do
        echo `$ISODATE`"|GtAttr: $GtAttr|Lookup: $Lookup|RdLink: $Rdlink|Read: $Read|Write: $Write|Rename: $Rename|Rddir: $Rddir|" ;
    done' > nfsstat_${w}_second.txt &
    add_bg $!
}

actstat_cmd ${SLEEP_SEC}
iostat_cmd ${SLEEP_SEC}

if [ $ZFS_AVAILABLE -eq 1 ] ; then
    zpool_wrap iostat -v $POOLNAME 1 > zpool_iostat_1_second.txt &
    add_bg $!
    zpool_wrap iostat -v $POOLNAME 60 > zpool_iostat_1_minute.txt &
    add_bg $!
fi

# remove the header columns, prefix with a date, format for CSV
netstat_iface()
{
    sleeptime=$1
    iface=$2
    if [ "$iface" != "" ] ; then
        echo "Running netstat_iface on $iface..."
        iarg="-I $iface"
        fname="$iface"
    else
        echo "Running netstat on all interfaces..."
        iarg=""
        fname="all"
    fi
    netstat $iarg $sleeptime | \
    egrep --line-buffered -v '^ *(input|packets)' | \
	sed -l 's/  */ /g' | \
	$UNBUFFER sh -c 'while read ipackets ierrs idrops ibytes opackets oerrs obytes colls; do echo `$ISODATE`"|ipackets: $ipackets|ierrs: $ierrs|idrops: $idrops|ibytes: $ibytes|opackets: $opackets|oerrs: $oerrs|obytes: $obytes|colls: $colls|" ;done' \
    > netstat_${fname}_${sleeptime}_second.txt &
    add_bg $!
}

netstat_all_ifaces() {
    sleeptime=$1
    for iface in $INTERFACES ; do
        netstat_iface $sleeptime $iface
    done
    netstat_iface $sleeptime
}

prefix_date()
{
    $UNBUFFER sh -c 'while read line ; do echo `$ISODATE`"$line" ;done' 
}

netstat_all_ifaces $SLEEP_SEC
nfsstat_cmd $SLEEP_SEC
netstat -x -w 1 > netstat_x_1_second.txt &
add_bg $!
vmstat -p pass  -w 5 > vmstat_5_second.txt &
add_bg $!
echo "One time Statistics captured."


datestamp()
{
    echo "=== " `$ISODATE` " ==="
    $*
}

join_filter()
{
    paste -s -d "|" -

}

# grab all the numeric values from sysctl ONLY and make it into a csv-like
# format
sysctl_filter()
{
    egrep '^[a-z][a-z.0-9]+: [0-9]+$' |join_filter

}

vmstat_i_filter()
{
    awk '{printf "%s",$1 ; for(i=2;i<NF-1;i++){printf " %s",$(i)} ; printf ",%s,%s|",$(NF-1),$(NF)}'
}

to_csv()
{
    filter=$1
    shift
    echo -n `$ISODATE`'|'
    eval $* | $filter
}

while [ 1 ]
do
    echo "Capturing..." `$ISODATE`
    #datestamp top -b 10 >> top.txt;
    to_csv join_filter netstat -m >> netstat_mbufs_${SLEEP_SEC}_second.txt;
    if [ "$SYSCTL_NODES" = "" ] ; then
	to_csv sysctl_filter sysctl -a >> sysctl_all_${SLEEP_SEC}_second.txt;
    else
	for node in $SYSCTL_NODES ; do
	    to_csv sysctl_filter sysctl $node >> sysctl_${node}_${SLEEP_SEC}_second.txt;
	done
    fi
    to_csv vmstat_i_filter vmstat -i >> vmstat_interupts_${SLEEP_SEC}_second.txt;
    if [ "$USE_HWPMC" = "yes" ] ; then
	$ISODATE >> pmccontrol_s_${SLEEP_SEC}_second.txt;
	pmccontrol -s >> pmccontrol_s_${SLEEP_SEC}_second.txt;
	echo >> pmccontrol_s_${SLEEP_SEC}_second.txt;
    fi

    # vmstat -z output.  this is large, might want to filter out some values
    # or skip and only capture this every few seconds?
    echo `$ISODATE`"|"`vmstat -z | grep -v '^ITEM' | grep -v '^$' | paste -s -d "|" - | sed -e 's/  *//g'` >> vmstat_z_${SLEEP_SEC}_second.txt

    sleep $SLEEP_SEC
done


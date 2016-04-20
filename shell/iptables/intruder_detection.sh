#!/bin/bash

prefix=data/intruder

daynum=${1:-0}
minlimit=${2:-500}

for((i=0;i<=$daynum;i++))
do
	accessdate=`date -d "${i} days ago"  +%Y%m%d`
	tblname="access_"${accessdate}

	sql="select clientip, count(clientip) from $tblname group by clientip  order by count(clientip) desc limit $minlimit"

	echo $sql |  mysql -h 10.1.1.94 -S/tmp/mysqld.sock access_statistics -N > ${prefix}${tblname}

done


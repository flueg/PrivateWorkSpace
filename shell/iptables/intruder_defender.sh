#!/bin/bash

base_dir=$(dirname $0)
white_list=$base_dir/data/whitelist
prefix=$base_dir/data/intruder
tblname="access_"`date +%Y%m%d`
file=${prefix}${tblname}
log_file=$base_dir/log/intruder.log
intruder_suspect=$base_dir/data/intruder_suspects
iptable=$base_dir/data/iptables

rm -f $intruder_suspect.*

# If host ip had accessed our service more than this threshold,
# we gonna stop it.
threshold=${1:-1000}

$base_dir/intruder_detection.sh

while read line
do
	ip=$(echo $line | awk '{print $1}')
	access_count=$(echo $line | awk '{print $2}')

	# Allow hosts in white list to access more than threshold times.
	grep -E "\b$ip\b" $white_list 2>&1 >/dev/null
	if [ $? -eq 0 ]; then continue; fi

	if [ $access_count -gt $threshold ]; then
		echo $ip >> ${intruder_suspect}.tmp
	fi
done<$file

cat ${intruder_suspect}.tmp | sort > $intruder_suspect
# diff filea fileb
#0a1
#> 115.202.161.46
#34d34
#< 58.242.208.126
rm -f ${iptable}.tmp
diff $intruder_suspect $iptable | while read line
do
	# We will add the new suspect ip into iptables
	pattern=${line:0:1}
	if [ "$pattern" = "<" ]; then
		new_ip=${line:2}
		#echo diff found: $new_ip
		iptables -I INTRUDER-INPUT -s $new_ip -j DROP
		echo [$(date +%Y%m%d-%k:%M:%S)] $new_ip might be a intruder.>> $log_file
		echo $new_ip >> ${iptable}.tmp
	fi
done

if [ -f ${iptable}.tmp ]; then
	cat $iptable ${iptable}.tmp | sort > ${iptable}.atmp
	mv ${iptable}.atmp $iptable
else
	echo no new intruder is found.
	echo [$(date +%Y%m%d-%k:%M:%S)] no new intruder is found. >> $log_file
fi
rm -f *tmp

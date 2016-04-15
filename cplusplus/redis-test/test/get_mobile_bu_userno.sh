#!/bin/bash

outfile=result
out_email=flueg.email
CMD="/home/root1/gateway_client 10.24.36.111 8636 getuserinfo usertype:2 mobile mail userid:"

if [ -f $outfile ]; then mv $outfile $outfile.bak; fi
if [ -f $out_email ]; then rm -f $out_email; fi

while read line
do
	echo get mobile of user: $line
	mobile=$(${CMD}$line | grep mobile | awk -F: '{print $2}')
	if [ -z $mobile ]; then
		echo $line >>${out_email}
	else
		echo $mobile $line >>$outfile
	fi
done<userno

if [ -f $out_email ]; then
	while read line
	do
		echo get email of user: $line
		mail=$(${CMD}$line | grep mail | awk -F: '{print $2}')
		if [ ! -z $mail ]; then
			echo $mail $line >>$outfile
		fi	
	done<$out_email
	rm $out_email
fi

echo "Finish job.... Pls check file [$outfile] for your sake"

#!/bin/bash
NO_MOBILE_ERR=userno-without-mobile.err
USERNO_MOBILE=userno-mobile
CONFLICT_MOBILE=mobile-with-mutiuserno.log
DIRTY_DATA=dirty-userno.log

mv $USERNO_MOBILE $USERNO_MOBILE.bak
mv $CONFLICT_MOBILE $CONFLICT_MOBILE.bak
mv $DIRTY_DATA $DIRTY_DATA.bak

do_sanity_test()
{
	userno=$1
	mobile=$2
	dif_userno=$(/home/root1/gateway_client  127.0.0.1 39299 name2id userid:$mobile usertype:5 | grep userno | awk -F: '{print $2}')
	if [ "x$dif_userno" = "x$userno" ]; then
		# No userno conflict if found. very nice.
		return;
	elif [ "x$dif_userno" != "x" -a "x$dif_userno" != "x$userno" ]; then
		# Opppps, conflict userno is found
		echo "confict found: $mobile $userno $dif_userno"
		echo "$mobile $userno $dif_userno" >>$CONFLICT_MOBILE
	else
		# mobile not bind in this machine. Let's check the userno now.
		# note that cheat=1 will return userno.
		nresult=$(/home/root1/gateway_client 10.24.36.111 8636 getuserinfo_sec userid:$userno usertype:2 mobile | wc -l)
		dif_userno=$(/home/root1/gateway_client 10.24.36.111 8636 getuserinfo_sec userid:$userno usertype:2 | grep userno | awk -F: '{print $2}')
		if [ "$nresult" -lt 3 -a "x$dif_userno" != "x" ]; then
			# userinfo is not sync with mxkj, error!!!
			echo "$mobile $userno" >> $DIRTY_DATA
		fi
	fi
}

userno=""
mobile=""
i=0
while read line
do
	if [ "$line" = "-------------------" ]; then
		if [ "x$userno" = "x" -a "$mobile" = "x" ]; then
			# We can ignore this case.
			echo No userno and mobile is found
		fi
		if [ "x$userno" != "x" -a "x$mobile" = "x" ]; then
			# mxkj should not allow register without mobile
			echo $userno >>$NO_MOBILE_ERR
		fi
		if [ "x$userno" != "x" -a "x$mobile" != "x" ]; then
			echo "$userno $mobile" >>$USERNO_MOBILE
			echo $i do sanity check for [$mobile] [$userno]
			((i = $i + 1))
			do_sanity_test $userno $mobile
			userno=""
			mobile=""
		else
			echo no mobile
		fi
		continue
	fi
		
	echo "$line" | grep "mobile" 2>&1 >/dev/null
	if [ $? -eq 0 ];then
		mobile=$(echo "$line" | awk '{print $3}')
		continue
	fi

	echo "$line" | grep "userno" 2>&1 >/dev/null
	if [ $? -eq 0 ];then
		userno=$(echo "$line" | awk '{print $3}')
	fi
done<old2new-all

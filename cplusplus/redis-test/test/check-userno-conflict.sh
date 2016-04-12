#!/bin/bash
CONFLICT_USER=conflict-userno.log
USERNO_GET_MOBILE=get-mobile-by-userno
OLD_GATEWAY=123.162.189.202
NEW_NAME2ID=114.55.57.103
NEW_GATEWAY=10.24.36.111
NEWMH_DATA_MISSED=newmh-data-leak
OLDMH_DATA_MISSED=oldmh-data-leak
# 1: data from Xunlei machine house
# 2: data from Aliyun machine house
# 3: only check mobile confliction, no userno is required
DATA_FROM_MH=2

if [ -f $CONFLICT_USER ]; then mv $CONFLICT_USER $CONFLICT_USER.bak; fi
if [ -f $USERNO_GET_MOBILE ]; then mv $USERNO_GET_MOBILE $USERNO_GET_MOBILE.bak; fi
if [ -f $NEWMH_DATA_MISSED ]; then mv $NEWMH_DATA_MISSED $NEWMH_DATA_MISSED.bak; fi
if [ -f $OLDMH_DATA_MISSED ]; then mv $OLDMH_DATA_MISSED $OLDMH_DATA_MISSED.bak; fi

debug()
{
	if [ $DEBUG = "debug" ]; then
		echo DEBUG: $*
	fi
}

info()
{
	if [ $DEBUG = "debug" -o $DEBUG = "info" ]; then
		echo INFO: $*
	fi
}

error ()
{
	if [ $DEBUG = "debug" -o $DEBUG = "info" -a $DEBUG = "error" ]; then
		echo ERROR: $*
	fi
}

do_sanity_test_for_mobile()
{
	mobile=$1

	# mobile not bind in this machine. Let's check the userno now.
	if [ $DATA_FROM_MH -eq 2 ]; then
		new_userno=$2
	else
		debug "/home/root1/gateway_client $NEW_NAME2ID 39299 name2id userid:$mobile usertype:5 | grep userno"
		#/home/root1/gateway_client  127.0.0.1 39299 name2id userid:$mobile usertype:5 | grep userno >/dev/null 2>&1
		new_userno=$(/home/root1/gateway_client $NEW_NAME2ID 39299 name2id userid:$mobile usertype:5 | grep userno | awk -F: '{print $2}')
	fi

	if [ $DATA_FROM_MH -eq 1 ]; then
		old_userno=$2
	else
		debug "/home/root1/gateway_client $OLD_GATEWAY 8636 getuserinfo_sec userid:$mobile usertype:5"
		#/home/root1/gateway_client $OLD_GATEWAY 8636 getuserinfo_sec userid:$mobile usertype:5 | grep userno >/dev/null 2>&1
		old_userno=$(/home/root1/gateway_client $OLD_GATEWAY 8636 getuserinfo_sec userid:$mobile usertype:5 | grep userno | awk -F: '{print $2}')
	fi

	if [ "x$old_userno" != "x" -a "x$new_userno" != "x" -a "x$old_userno" != "x$new_userno" ]; then
		# userinfo is not sync with mxkj, error!!!
		error "conflict userno found: [$new_userno => $old_userno]"
		echo "$mobile $old_userno $new_userno" >> $CONFLICT_USER
	fi
}

do_sanity_test_for_userno()
{
	userno=$1
	
	# Data from Aliyun MH
	if [ $DATA_FROM_MH -eq 2 ]; then

		# Try to get the bind mobile, and then check if it has conflict usernos.
		debug "/home/root1/gateway_client $NEW_GATEWAY 8636 getuserinfo userid:$userno usertype:2 mobile | grep mobile"
		#/home/root1/gateway_client $NEW_GATEWAY 8636 getuserinfo userid:$userno usertype:2 mobile | grep mobile >/dev/null 2>&1
		mobile=$(/home/root1/gateway_client $NEW_GATEWAY 8636 getuserinfo userid:$userno usertype:2 mobile| grep mobile | awk -F: '{print $2}')
		if [ "x$mobile" != "x" ]; then
			debug "do sanity mobile userno conflict test for $mobile"
			echo "$userno $mobile" >> $USERNO_GET_MOBILE
			do_sanity_test_for_mobile $mobile $userno
		else	
			debug "	no mobile is bind, nothing to check."
		fi

		# Try to search if userno exists in Xunlei MH, too.
		# note that cheat=1 will return userno.
		debug "/home/root1/gateway_client $OLD_GATEWAY 8636 getuserinfo_sec userid:$userno usertype:2"
		nresult=$(/home/root1/gateway_client $OLD_GATEWAY 8636 getuserinfo_sec userid:$userno usertype:2 | wc -l)
		if [ $nresult -eq 3 ]; then
			# userno no exist in old MH, need to sync
			error "un-sync userno found: [$userno]"
			echo "$mobile $userno" >> $OLDMH_DATA_MISSED
		else
			debug "data is sync from Aliyun => Xunlei"
		fi
		return
	fi

	# Data from Xunlei MH
	if [ $DATA_FROM_MH -eq 1 ]; then

		# Try to get the bind mobile, and then check if it has conflict usernos.
		debug "/home/root1/gateway_client $OLD_GATEWAY 8636 getuserinfo_sec userid:$userno usertype:2 mobile | grep mobile"
		mobile=$(/home/root1/gateway_client $OLD_GATEWAY 8636 getuserinfo_sec userid:$userno usertype:2 mobile| grep mobile | awk -F: '{print $2}')
		if [ "x$mobile" != "x" ]; then
			debug "do sanity mobile userno conflict test for $mobile"
			echo "$userno $mobile" >> $USERNO_GET_MOBILE
			do_sanity_test_for_mobile $mobile $userno
		
			debug "	no mobile is bind, nothing to check."
		fi

		# Try to search if userno exists in Xunlei MH, too.
		# note that cheat=0 will return 404 in userno not exists. 
		debug "/home/root1/gateway_client $NEW_GATEWAY 8636 getuserinfo userid:$userno usertype:2"
		nresult=$(/home/root1/gateway_client $NEW_GATEWAY 8636 getuserinfo userid:$userno usertype:2 | grep result | awk -F: '{print $2}')
		#old_userno=$(/home/root1/gateway_client $OLD_GATEWAY 8636 getuserinfo userid:$userno usertype:2 | grep mobile | awk -F: '{print $2}')
		if [ $nresult -ne 200 ]; then
			# userno no exist in new MH, need to sync
			error "un-sync userno found: [$userno]"
			echo "$mobile $userno" >> $NEWMH_DATA_MISSED
		else
			debug "data is sync from Xunlei => Aliyun"
		fi
		return
	fi
}

conf_file=${1:-dbmobmxkj}
DEBUG=${2:-false}

echo $conf_file

userno=""
mobile=""
while read line
do
	userno=$(echo "$line" | awk '{print $1}')
	mobile=$(echo "$line" | awk '{print $3}')
	#mobile=$(echo "$line" | awk '{print $2}')
	info "sanity test for userno: [$userno], mobile: [$mobile]"
	if [ -z "$mobile" ]; then
		debug sanity mobile userno confict test for: [$userno]
		do_sanity_test_for_userno $userno
	#elif [ -z $userno ]; then
		#echo userno should not be null
	else
		debug "sanity test for mobile $[mobile] ..."
		do_sanity_test_for_mobile $mobile
	fi

done<$conf_file

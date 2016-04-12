#!/bin/bash
CLIENT=/home/root1/gateway_client 
OLD_GATEWAY="123.162.189.202 8636"
NEW_NAME2ID="114.55.57.103 39299"
NEW_GATEWAY="10.24.36.111 8636"
DEBUG=debug

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

init_commands()
{
	# Reserved userno from Aliyun
	if [ $RESERVED_FIELD -eq 2 ]; then
		CHECK_IS_BIND_CMD="$CLIENT $NEW_NAME2ID name2id usertype:5 "
		CHECK_IS_REGISTER_CMD="$CLIENT $OLD_GATEWAY getuserinfo_sec usertype:2 "
		UNBIND_CMD="$CLIENT $OLD_GATEWAY unbind usertype:2 nametype:5 "
		BIND_CMD="$CLIENT $OLD_GATEWAY bind usertype:2 nametype:5 "
		SET_USERINFO_CMD="$CLIENT $OLD_GATEWAY setuserinfo usertype:2"
		CLEAR_USERINFO_CMD="$CLIENT $NEW_GATEWAY setuserinfo usertype:2"
	# Reserved userno from Xunlei
	elif [ $RESERVED_FIELD -eq 1 ]; then
		CHECK_IS_BIND_CMD="$CLIENT $OLD_GATEWAY name2id usertype:5 "
		CHECK_IS_REGISTER_CMD="$CLIENT $NEW_GATEWAY getuserinfo usertype:2 "
		UNBIND_CMD="$CLIENT $NEW_GATEWAY unbind usertype:2 nametype:5 "
		BIND_CMD="$CLIENT $NEW_GATEWAY bind usertype:2 nametype:5 "
		SET_USERINFO_CMD="$CLIENT $NEW_GATEWAY setuserinfo usertype:2"
		CLEAR_USERINFO_CMD="$CLIENT $OLD_GATEWAY setuserinfo usertype:2"
	else
		error reserved field:$RESERVED_FIELD is not defined.
	fi
}

# Check and return true if:
# 1. userno is bind to mobile in current reserved machine.
# 2. userno is already registered in traget host, so we can bind the mobile
check_userno()
{
	mobile=$1
	userno=$2
	userno_conflict=$3
	# Firstly, check if userno is bind to current mobile.
	# If no, error
	# If yes, ok to proceed
	debug $CHECK_IS_BIND_CMD userid:$mobile
	$CHECK_IS_BIND_CMD userid:$mobile
	testno=$($CHECK_IS_BIND_CMD userid:$mobile | grep userno | awk -F: '{print $2}')
	debug testno is [$testno], userno is [$userno]
	if [ "$testno" != "$userno" ]; then
		error $testno is bind to $mobile instead of $userno
		return 1
	fi

	# Secondly, check if userno is regiester in target hosts.
	# If no, error
	# If yes, ok to proceed
	debug $CHECK_IS_REGISTER_CMD userid:$userno_conflict
	$CHECK_IS_REGISTER_CMD userid:$userno_conflict
	if [ $RESERVED_FIELD -eq 1 ]; then
		result=$($CHECK_IS_REGISTER_CMD userid:$userno_conflict | grep result | awk -F: '{print $2}')
		if [ "$result" -ne 200 ]; then
			error $userno is not register in target aliyun host.
			return 1
		fi
	elif [ $RESERVED_FIELD -eq 2 ]; then
		ncount=$($CHECK_IS_REGISTER_CMD userid:$userno_conflict | wc -l)
		if [ "$ncount" -eq 3 ]; then
			error $userno is not register in target xunlei host.
			return 1
		fi
	fi

	# return true if pass the check.
	debug check userno successfully.
	return 0
}

unbind_mobile()
{
	mobile=$1
	userno=$2
	debug $UNBIND_CMD userid:$userno name:$mobile
	$UNBIND_CMD userid:$userno name:$mobile

	debug $SET_USERINFO_CMD userid:$userno mobile:
	$SET_USERINFO_CMD userid:$userno mobile:
}

bind_mobile()
{
	mobile=$1
	userno=$2
	debug $BIND_CMD userid:$userno name:$mobile
	$BIND_CMD userid:$userno name:$mobile

	debug $SET_USERINFO_CMD userid:$userno mobile:$mobile
	$SET_USERINFO_CMD userid:$userno mobile:$mobile
}

clear_garbage()
{
	mobile=$1
	userno=$2
	debug $CLEAR_USERINFO_CMD userid:$userno mobile:
	$CLEAR_USERINFO_CMD userid:$userno mobile:
}

input=$1
#   mobile     Xunlei     Aliyun
#13007195823 1008351291 1008318716
RESERVED_FIELD=${2:-2} # By default reserve the Aliyun userno
init_commands
while read line
do
	mobile=$(echo "$line" | awk '{print $1}')
	userno1=$(echo "$line" | awk '{print $2}')
	userno2=$(echo "$line" | awk '{print $3}')

	if [ -z "$mobile" -o -z "$userno1" -o -z "$userno2" ]; then 
		error mobile reserve_userno unbind_userno 3 fields are required.
		cat $USAGE <<EOF

usage: $0 data_file reserved_filed(1/2)
	data format in datafile:
	#mobile		userno1 userno2
	#13007195823 1008351291 1008318716
	Note that userno1 should be the userno bind to mobile in Xunlei machine house
		  userno2 should be the userno bind to mobile in Aliyun machine house
EOF
		break
	fi
	
	# Reserved userno from Xunlei
	if [ $RESERVED_FIELD -eq 1 ]; then
		check_userno $mobile $userno1 $userno2 || error "$userno1 deoes not exist in target host."
		unbind_mobile $mobile $userno2
		bind_mobile $mobile $userno1
		clear_garbage $mobile $userno2
	# Reserved userno from Aliyun
	elif [ $RESERVED_FIELD -eq 2 ]; then
		check_userno $mobile $userno2 $userno1 || error "$userno1 deoes not exist in target host."
		unbind_mobile $mobile $userno1
		bind_mobile $mobile $userno2
		clear_garbage $mobile $userno1
	else
		error reservied field is undefined
		break
	fi
done<$input


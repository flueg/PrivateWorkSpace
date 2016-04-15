#!/bin/bash

rm -f dataleak.usrno

while read line
do
	userno=$line
	if [ "x$userno" = "x" ];then continue; fi
	echo checking $userno...
	result=3
	#/home/root1/gateway_client 127.0.0.1 8636 getuserinfo_sec usertype:2 userid:$userno
	#result=$(/home/root1/gateway_client 127.0.0.1 8636 getuserinfo_sec usertype:2 userid:$userno |wc -l)
	PROPERTY="userid:$userno"
	/home/root1/gateway_client 127.0.0.1 8636 getuserinfo_sec usertype:2 userid:$userno | while read property
	do
		name=$(echo $property |awk -F: '{print $1}')
		value=$(echo $property|awk -F: '{print $2}')
		echo $name $value ...
		if [ "$name" = "result" ];then
			if [ $value -ne 200 ]; then break; fi
			continue
		fi
		
		if [ "$value" != "" ]; then
			echo lalala $PROPERTY
			export PROPERTY="$PROPERTY $name:$value"
		fi

		if [ "$name" = "---row---" ]; then 
			echo "$PROPERTY Oh yeah..."
			echo $PROPERTY >dataleak.tmp
		fi
	done
	PROPERTY=$(tail dataleak.tmp)
	/home/root1/gateway_client 127.0.0.1 8636 getuserinfo_base usertype:2 userid:$userno | while read property
	do
		name=$(echo $property |awk -F: '{print $1}')
		value=$(echo $property|awk -F: '{print $2}')
		echo $name $value ...
		if [ "$name" = "result" ];then
			if [ $value -ne 200 ]; then break; fi
			continue
		fi
		if [ "$name" = "usernewno" ]; then continue; fi
		
		if [ "$value" != "" ]; then
			echo lalala $PROPERTY
			PROPERTY="$PROPERTY $name:$value"
		fi

		if [ "$name" = "---row---" ]; then 
			echo "$PROPERTY Oh yeah..."
			echo $PROPERTY >>dataleak.usrno
		fi
	done
	echo "why I can't get the property in while loop: $PROPERTY"

	if [ $result -eq 3 ]; then
		echo 	
	else
		echo Oppppppps, datalead userno: $userno
		echo $userno >>dataleak.final
	fi
	
done<aaa

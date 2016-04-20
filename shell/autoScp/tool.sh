
kkscp()
{
	send_file=${1}
	host=${2:-"essh.sandai.net:/home/usrname/packages/"}	
	usrname=${3:-"usrname"}
	passwd=${4:-passwd}

	if [ "x$send_file" = "x" ]; then
		echo "Usage: kkscp <sendfile> [<host> <usrname> <passwd>]"
		return 1
	elif [ ! -f $send_file ]; then
		echo "$send_file is not found"
		return 2
	fi
	if [ ! -x /usr/bin/expect ];then
		echo "binary /usr/bin/expect is not installed."
		return 3
	fi

	SSH=scp.expect
	cat <<-EXPECT_SCRIPTS > $SSH
	#!/usr/bin/expect
	spawn /usr/bin/scp $send_file $usrname@$host
	expect "$usrname@essh.sandai.net*"
	send "$passwd\r"
	expect "$send_file*"
	EXPECT_SCRIPTS
	chmod 755 $SSH
	./$SSH
	rm -f $SSH
}

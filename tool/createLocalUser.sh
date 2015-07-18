#!/bin/bash
################################################################################
#
#  A shell script to create local unix user.
#
#
################################################################################

INPUT_CONF="/tmp/local.user"
DEBUG="false"


##>> Sub >> ###########################
Usage()
{
    cat <<-END_USAGE
Usage: $0 [options]
    -d:            print debug messages
    -g:            generate local account data to input file.
    -c:            clear the old input file. should used with -g option
    -f <file>:     the input file path. default "$INPUT_CONF"
    -h:            print this help mesage.

END_USAGE
exit 0
}
verbose()
{
    if [ "x$DEBUG" == "xtrue" ]
    then
        echo $*
    fi
}

deleteLocalGroup()
{
    name=$1
    groupdel $name
    if [ $? ]; then
        echo "Fail to delete group $name"
    fi
}

createLocalGroup()
{
    name=$1
    gid=$2
    verbose "creating local group $name"
    result=`getent group | grep $gid | awk -F: '{print $1}'`
    if [ $result ]; then
        verbose "gid [$gid] conflict found."
        verbose "deleting group $name"
        deleteLocalGroup $result
    fi

    groupadd -g $gid $name
    verbose "create group $name done"
}

deleteLocalUser()
{
    name=$1
    userdel $name
    if [ $? ]; then
        echo "Fail to delete user $name"
    fi
}

createLocalUser()
{
    name=$1
    uid=$2
    gid=$3
    home=$4
    shell=$5
    verbose "creating local user $name $uid $gid $home $shell"
    result=`getent passwd | grep $uid | awk -F: '{print $1}'`
    if [ $result ]; then
        verbose "uid [$uid] confict found."
        verbose "deleting user $name"
        userdel $result
    fi

    createLocalGroup $name $gid
    useradd -d $home -s $shell -u $uid -g $gid $name
    verbose "create user $name done"
}

createLocalAccounts()
{
    prefix="local-"
    let numBase=1000
    for i in $(seq 1 10)
    do
        num=$(($i + $numBase))
        uname="${prefix}$num"
        uhome="/home/$uname"
        ushell="/bin/bash"
        accountData=$uname:$num:$num:$uhome:$ushell
        verbose "generating user: [$accountData]"
        echo $accountData >> $INPUT_CONF
    done
}

##>> Main >>#########################

# Parse the command options
while [ $# -gt 0 ]; do
    case "$1" in
        -g) GENERATE_DATA="true"
        ;;
        -c) CLEANUP="true"
        ;;
        -d) DEBUG="true"
        ;;
        -f) INPUT_CONF="$1"
        shift
        ;;
        *)
        Usage
        ;;
    esac
    shift
done

# By default, will not generate local account data.
${GENERATE_DATA:="false"}
${CLEANUP:="false"}

if [ $GENERATE_DATA == "true" ];then
    if [ $CLEANUP == "true" ]; then
        rm $INPUT_CONF
    fi
    createLocalAccounts
    echo "creating local accounts data done. exit."
    exit
fi

# root priviledge required
if [ $EUID -ne 0 ]; then
    echo ERROR: script should be run by root.
    exit
fi

# Read the input file and create local user
while read line
do
    uname=`echo $line | awk -F: '{print $1}'`
    uid=`echo $line | awk -F: '{print $2}'`
    gid=`echo $line | awk -F: '{print $3}'`
    uhome=`echo $line | awk -F: '{print $4}'`
    ushell=`echo $line | awk -F: '{print $5}'`
    createLocalUser $uname $uid $gid $uhome $ushell
done < "$INPUT_CONF"
Usage

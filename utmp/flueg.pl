#!/usr/bin/perl

use strict;
my $UTMP = "/var/log/wtmp";
my $size_of_utmp_struct=384;       # 384 byte
my $ut_type=4;    # 2 byte, but 4 byte aligned in mem
my $ut_pid=4;        # 4 byte
my $ut_line;    # 32 byte
my $ut_id;      # 4 byte
my $ut_user;    # 32 byte
my $ut_host=256;    # 256 byte
my $ut_exit;    # 4 byte
my $ut_session; # 4 byte
my $ut_tv;      # 8 byte
my $ut_addr;    # 16 byte
my $ut_unused;  # 20 byte
my @type = qw(EMPTY RUN_LVL BOOT_TIME NEW_TIME OLD_TIME INIT_PROCESS
              LOGIN_PROCESS USER_PROCESS DEAD_PROCESS ACCOUNTING);

sub ParseUtmpBinaryRecord;
sub ParseUtmpBinaryRecord
{
    my ($pl, $buffer) = @_;
    my $pattern = "(.{4})(.{4})(.{32})(.{4})(.{32})(.{256})(.{4})(.{4})(.{8})(.{16})(.{20})";
    my ($type,$pid,$line,$inittab,$user,$host,$exit,$session,$tv,$addr,$unused) = 
     $buffer =~ m/$pattern/;

    $host =~ s/\x00+//g;
    $user =~ s/\x00+//g;
    $line =~ s/\x00+//g;
    # The login time format is: the seconds since 1970/1/1
    $tv = unpack("I8",$tv);
    $type = unpack("S2", $type);

    return ($user, $tv, $host, $type, $line);
}

sub GetUtmpRecords
{

    my $result = {};
    my $begin_time;
    my $platform = "rhel";

    # Default: get the wtmp file path
    open my $FD, '<', $UTMP
        or die("Cannot open file $UTMP");
    my $buffer = "";
    my $lll;
    my $size = -s $UTMP;
    print "file size: $size\n" if ($size % $size_of_utmp_struct);
    while(read($FD, $buffer, $size_of_utmp_struct))
    {
        #    my $buf1 = substr($buffer, $size_of_utmp_struct);
        #my $buf2 = substr($buffer, $size_of_utmp_struct + 1, $size_of_utmp_struct);
        # Get the user name, user login time and user hosts from the utmp
        # record
        my ($user, $login_time, $host, $type, $line) = 
            ParseUtmpBinaryRecord($platform, $buffer);
            #my ($user, $login_time, $host) = 
            #    ParseUtmpBinaryRecord($platform, $buf1);
            #my ($user1, $login_time1, $host1) = 
            #    ParseUtmpBinaryRecord($platform, $buf2);

            #last if ($user ne $user1);

        $lll = $login_time;
        # Note: If we find that the user name and host are not the printable
        # charactor, consider this file is not a valed utmp binary file.
        #if ($user and $type == 7 or $type == 2)
        {
            # Ignore the records if it was older than $threshold
            #next if ($login_time < $threshold);

            $result->{'users'}->{$user} = $user;

            # Get the latest login time of user
            $result->{'ltime'}->{$user} = $login_time
                if ($result->{'ltime'}->{$user} < $login_time);

            # Keep the host amount of every host for every login user.
            $result->{'hosts'}->{$user}->{$host}++;

            # Consider the utmp file begin time as the time of the earliest
            # record
            $begin_time = $login_time if ($begin_time < $login_time);
        }
            printf "$user, $line, $host, %s, $type\n", scalar gmtime($login_time);
    }
        my $ttime = scalar gmtime($lll);
        #print substr($ttime, 4);
        return $result;
}


GetUtmpRecords;

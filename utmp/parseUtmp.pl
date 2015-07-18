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

sub GetUtmpRecords;
sub NDaysAgoSeconds;
sub ParseUtmpBinaryRecord;
sub GetUtmpFilePaths;

sub NDaysAgoSeconds
{
    my ($day) = @_;
    return time() - $day * 86400;
}

sub ParseUtmpBinaryRecord
{
    my ($platform, $buffer) = @_;
    my $rc = 1;
    my ($type,$pid,$line,$inittab,$user,$host,$exit,$session,$tv,$addr,$unused) = 
     $buffer =~ m/^(.{4})(.{4})(.{32})(.{4})(.{32})(.{256})(.{4})(.{4})(.{8})(.{16})(.{20})$/;

    $type = unpack("s2", $tv);
    # Assume we read a non-regular utmp file.
    if ($type < 0 or $type > 9)
    {
        DEBUG_OUT("Reading a non utmp binary file.");
        return -1;
    }
    

    $host =~ s/\x00+//g;
    $user =~ s/\x00+//g;
    # The login time format is: the seconds since 1970/1/1
    $tv = unpack("I4",$tv);

    # Only get the the USER_PROCESS (type id is 7) and BOOT_TIME (type id is 2)
    # record
    $rc = 0 if ($type != 2 and $type !=7);
    return ($rc, $user, $tv, $host);
}

sub GetUtmpFilePaths
{
    my ($platform, $file) = @_;

    my $os_family = $platform->getOSFamily();
    my @tmp_file;
    if ($os_family eq OS_FAMILY->{LINUX})
    {
        @tmp_file = </var/log/${file}*>;
    }
    elsif ($os_family eq OS_FAMILY->{AIX})
    {
        if ($file eq 'btmp')
        {
            @tmp_file = </etc/security/failedlogin> ;
        }
        else
        {
            @tmp_file = </var/adm/${file}*>;
        }
    }
    elsif ($os_family eq OS_FAMILY->{SOLARIS})
    {
        if ($file eq 'btmp')
        {
            DEBUG_OUT("Solaris does not use binary file to store the bad/fail" .
                      " login");
        }
        else
        {
            @tmp_file = </var/adm/${file}*>;
        }
    }
    else
    {
         DEBUG_OUT("Unknown platform [%s] detected", $os);
         return;
    }

    return \@tmp_file
}

sub GetUtmpRecords
{
    my ($test, $threshold, $good_or_bad_login_record) = @_;

    $platform = $test->getPlatform();
    # Transfer the threshold unit from n days ago to seconds since 1970/1/1
    # Default set to 0 sec, mean 1970/1/1
    if($threshold)
    {
        DEBUG_OUT("Get the user records during the past $threshold days");
        $threshold = NDaysAgoSeconds($threshold);
    }
    else
    {
        DEBUG_OUT("Get all the user login records");
    }
    my $result = {};
    my $begin_time;
    my $time_zone = GetTimeZone($platform);

    # Default: get the wtmp file path
    my $utmp_file_paths = GetUtmpFilePaths(
        $platform,
        $good_or_bad_login_record eq 'btmp' ? btmp : wtmp);
    # return if utmp file does not exist
    if (!$utmp_file_paths)
    {
        DEBUG_OUT("Cannot find the $good_or_bad_login_record file" .
                  " good/bad login mechanism is not enable");
        return undef;
    }

    foreach my $utmp (@$utmp_file_paths)
    {
        # All the utmp file size should be divisible by $size_of_utmp_struct
        my $file_size = -s $utmp;
        next if ($file_size % $size_of_utmp_struct);

        open my $FD, '<', $utmp
            or die("Cannot open file $utmp");
        my $buffer;
        while(read($FD, $buffer, $size_of_utmp_struct))
        {
            # Get the user name, user login time and user hosts from the utmp
            # record
            my ($rc, $user, $login_time, $host) = 
                ParseUtmpBinaryRecord($platform, $buffer);
            # Assume it's not a regular utmp file
            last if ($rc == -1);

            # Consider the utmp file begin time as the time when creating the
            # earliest utmp record
            $begin_time = $login_time if ($login_time and $begin_time < $login_time);

            # only get the USER_PROCESS and BOOT_TIME utmp records.
            next if ($rc == 0);
            # Ignore the records if it was older than $threshold
            next if ($login_time < $threshold);

            if ($user)
            {
                $result->{'users'}->{$user} = $user;

                # Get the latest login time of user
                $result->{'ltime'}->{$user} = $login_time
                    if ($result->{'ltime'}->{$user} < $login_time);

                # Keep the host amount of every host for every login user.
                $host = "Unkown" if (!$host);
                $result->{'hosts'}->{$user}->{$host}++;
            }
            else
            {
                WARN_OUT("The username is null in the utmp record");
            }
        }
        close $FD;
    }
    # The time when creating the earliest utmp record.
    $result->{'ltime'}->{'__begin_time'} = $begin_time;
    # The local machine time zone.
    $result->{'ltime'}->{'__time_zone'} = $time_zone;

    return (1, $result);
}


GetUtmpRecords;

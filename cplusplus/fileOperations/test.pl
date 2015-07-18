use lib '/usr/share/centrifydc/perl';

use strict;
use CentrifyDC::GP::General qw(ReadFile);
use File::Basename;

sub getFilesFromDir()
{
    my $dir = "/var/centrifydc";
    opendir my $FD, $dir;
    my @files = grep {/^core.*/} readdir($FD);
    closedir $FD;
    foreach my $f (@files)
    {
        print $f . "\n";
        my ($mode, $mtime) = (stat("/$dir/$f"))[2,9];
        $mode &= 07777;
        print "mode: [$mode], mtime: [$mtime]\n";
        my $ctime = time();
        print "current time: [$ctime]\n";

        my $time_gap = $ctime - $mtime;
        my $time_age = $time_gap - 31 * 2400 * 36;
        print "time gap: [$time_age] days\n";
        printf("file mode [%04o]\n", $mode & 07777);
    }
}

sub getFilebase()
{
     my $core_conf = "/proc/sys/kernel/core_pattern";
     my $config = ReadFile($core_conf);
     if ($config)
     {
         chomp $config;
         print "conf: [$config]\n";
         my $location = dirname($config);
         print "yes\n" if ($location eq ".");
         my $pattern = basename($config);
         print "dir: [$location], pattern: [$pattern]\n";
     }
}

my $CDC_LOCATION = "/var/centrifydc";
sub GetLinuxDumpCoreLocation()
{
    my $core_conf = "/proc/sys/kernel/core_pattern";
    my $config = ReadFile($core_conf);
    print "get [$config]";
    if ($config)
    {
        if (-d $config)
        {
                return $config;
        }
        else
        {
            my $dir = dirname($config);
            return $CDC_LOCATION if ($dir eq ".");
            return "/var" if ($dir eq "..");
            return $dir;
        }
    }
    #By default.
    return "$CDC_LOCATION";
}

sub GetSolarisDumpCoreLocation($)
{
    my $para = shift;
    print "parameter: [$para]\n";
    my $core_conf = "coreadm.conf";
    my $config = ReadFile($core_conf);
    my $pattern = "";
    if ($config)
    {
        my $glob_enabled = ($config =~ qr/.*COREADM_GLOB_ENABLED=(.*)[\s]*/)[0];
        if ($glob_enabled eq "yes")
        {
            $pattern = ($config =~ qr/.*COREADM_GLOB_PATTERN=(.*)[\s]*/)[0];
        }
        else
        {
            $pattern = ($config =~ qr/.*COREADM_INIT_PATTERN=(.*)[\s]*/)[0];
        }
    }
    print "pattern [$pattern]\n";
    if ($pattern)
    {
        if (-d $pattern)
        {
            return $pattern;
        }
        else
        {
            my $dir = dirname($pattern);
            return $CDC_LOCATION if ($pattern eq ".");
            return $dir;
        }
    }
    # By default.
    return "$CDC_LOCATION";
}

sub GetAixDumpCoreLocation()
{
    my $core_conf = "user";
    my $rc = open FD, '<', $core_conf;
    if (! $rc)
    {
        return $CDC_LOCATION;
    }
    my $find_root = 0;
    my $config = "";
    while (<FD>)
    {
        my $line = $_;
        next if ($line =~ qr/^\*/);
        if ($line =~ qr/^root:/)
        {
            while (<FD>)
            {
                last if (/^[\w]+:/);
                $config .= $_;
            }
            $find_root = 1;
        }

        last if ($find_root);
    }

    if ($config)
    {
        #print $config . "\n";
        if (($config =~ qr'[\s]*core_path = ([\w]*)[\s]*')[0] eq "on")
        {
            print "file path on\n";
            my $pattern = ($config =~ qr'[\s]*core_pathname = ([\w/]*)[\s]*')[0];
            return $pattern;
        }
    }
    return $CDC_LOCATION;
}

my $dir = GetLinuxDumpCoreLocation();
print "\ndir $dir\n";
if ($dir !~ '^/')
{
    print "related path.\n";
}
print dirname("|/core ");

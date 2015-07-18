#!/usr/bin/perl
##############################################################################
#
# Copyright (C) 2014 - 2014 Centrify Corporation. All rights reserved.
#
# This script helps to generate a human readable report of group policies
# applied on local machine base on file gp.report.
#
##############################################################################

use strict;
use File::Basename;
use POSIX qw(strftime);
use Getopt::Long;
use lib '/usr/share/centrifydc/perl';
use CentrifyDC::Config;
use CentrifyDC::GP::General qw(:debug);

use constant ERR_USAGES => 7;
use constant GP_PATTERN =>
{
    NAME           => qr/^name: (.*)/,
    LASTUPDATE     => qr/^lastupdate: (.*)/,
    NEXTUPDATE     => qr/^nextupdate: (.*)/,
    REFRESHRATE    => qr/^refreshRate: (.*)/,
    REFRESHOFFSET  => qr/^refreshOffset: (.*)/,
    DENYRSOP       => qr/^denyRsop: (.*)/,
    LOOPBACKMODE   => qr/^loopbackMode: (.*)/,

    GP_GROUP       => qr/^\[(.*)\]$/,
    GP_SETTINGS    => qr/([^:]*):([^;]*);([^;]*);([^;]*);(.*)/
};

my $regBaseUser = $CentrifyDC::Config::properties{"gp.reg.directory.user"};
my $regBaseMachine = $CentrifyDC::Config::properties{"gp.reg.directory.machine"};
if (! -d $regBaseUser)
{
    $regBaseUser = "/var/centrifydc/reg/users";
    TRACE_OUT("Use default user registry base dir: [$regBaseUser].");
}
if (! -d $regBaseMachine)
{
    $regBaseMachine = "/var/centrifydc/reg/machine";
    TRACE_OUT("Use default machine registry base dir: [$regBaseMachine].");
}

my @GP_HEADERS = qw/name lastupdate nextupdate refreshrate refreshoffset denyrsop loopbackmode/;
my @LOOPBACK = ("Not Configure", "Merge", "Replace", "Disabled");
my $IN1 = "    ";
my $IN2 = "        ";
my %opts;
my @users;

#>>>>>> Subroutine >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sub usage
{
    my $program = basename($0);
    print <<EOF;
usage: $program [option]
    e.g. $program -a
    or $program -m -u uname1 -u uname2 ...
options:
    -a, --all           dump both the gp settings deployed in machine and current
                        user loaded from AD.
    -m, --machine       dump the computer gp settings.
    -u, --user <name>   dump the specified user's gp settings.
    -h, --help          print this help information and exit.
    default applied with -a.
EOF
    exit ERR_USAGES;
}

#
# Transform the gp report headers to human readable format.
#
sub _parseHeadersValues
{
    my ($headers) = @_;
    my $result = {};
    
    foreach my $key (@GP_HEADERS)
    {
        my $upkey = uc $key;
        $result->{$key} = $headers->{$key};
    }

    # Convert the lastupdate and nextupdate time to man readable time format.
    $result->{lastupdate} = strftime "%a %b %e %H:%M:%S %Y", localtime($result->{lastupdate});
    $result->{nextupdate} = strftime "%a %b %e %H:%M:%S %Y", localtime($result->{nextupdate});

    $result->{denyrsop} = $result->{denyrsop} ? "Yes" : "No";

    $result->{loopbackmode} = $LOOPBACK[$result->{loopbackmode}];

    return $result;
}

#
# Transform the policy value data to human readable format.
#
sub _parseValueData
{
    my ($type, $value) = @_;

    my $result = $value;
    # Mainly convert the "true/false" to "enabled/disabled".
    if ("$value" eq "true")
    {
        $result = "Enabled";
    }
    elsif ("$value" eq "false")
    {
        $result = "Disabled";
    }
    return $result;
}

#
# Parse the gpo name, policy setting value and corresponding value data.
#
sub _parseGPValues
{
    my ($keys, $values) = @_;
    my $policy = {};
    my $valueName = {};
    my $valueData = {};
    foreach my $key (@$keys)
    {
        foreach my $value (@{$values->{$key}})
        {
            next if (!$value);
            $value =~ GP_PATTERN->{GP_SETTINGS};
            
            # Every reg key might have several gpo.
            ${$policy->{$key}}{$1} = "1";

            # Every gpo might have several gp settings.
            push (@{$valueName->{$key}->{$1}}, $2);

            # Store the gp settings value and value data in a hash ref.
            ${$valueData->{$key}->{$1}}{$2} = _parseValueData($3, $5);
        }
    }

    my $result = {
        keys => $keys,
        policyName => $policy,
        valueName => $valueName,
        valueData => $valueData,
    };

    return $result;
}

#
# Construct a hash ref contains all the required details to dump to the end user.
#
# $_[0]: $headers - a hash ref contains:
#           name => frhel3u8-lueg$
#           lastupdate => 1398205514
#           nextupdate => 1398211754
#           refreshRate => 90
#           refreshOffset => 30
#           denyRsop => 0
#           loopbackMode => 2
# $_[1]: $regKeys - an array ref contains all the registry keys.
#                 e.g. software/policies/microsoft/systemcertificates/efs/crls
# $_[2]: $values - array ref contains all the policy setting entries.
#                e.g. @{$values->{$regKey}}
#
# return: $result - a hash ref contains:
#           _name => scalar string, the name of policy owner;
#           _lastupdate => scalar string, the last update time of gp settings;
#           _nextupdate => scalar string, the next update time of gp settings;
#           _refreshrate => scalar string, the refresh rate;
#           _refreshoffset => scalar string, the refresh offset;
#           _denyrsop => scalar string, whether deny the rsop or not;
#           _loopbackmode => scalar string, the user policy loopback mode;
#
#           _gpKeys => array ref, contains all the registry keys from gp.report;
#           _gpPolicyName => hash ref, contains all the gpo names in
#                            %{$result->{_gpPolicyName}->{<regKey>}};
#           _gpValueName => array ref, contains all the gp settings value name
#                           for "gpo/policy setting value" in
#                           @{$result->{_gpValueName}->{regKey}->{$policyName}}
#           _gpValueData => hash ref, contains all the gp settings value data
#                           for "gpo/policy setting value" in
#                           ${$result->{_gpValueData}->{$regKey}->{$policyName}}
#                           {$valueName}
#
sub new
{
    my ($headers, $keys, $values) = @_;

    my $h = _parseHeadersValues($headers);
    my $result = _parseGPValues($keys, $values);
    
    my $self = {
        _gpKeys => $result->{keys},
        _gpPolicyName => $result->{policyName},
        _gpValueName => $result->{valueName},
        _gpValueData => $result->{valueData},
    };

    foreach my $key (@GP_HEADERS)
    {
        $self->{"_$key"} = $h->{$key};
    }

    return $self;
}

#
# Guarantee there're no duplicative elements in array.
#
# $_[0]: the array ref.
#
sub unique
{
    my ($key) = @_;
    my %key_hash = map {$_ => 1} @{$key}; 
    @{$key} = sort keys %key_hash;
}

sub getMyOptions
{
    GetOptions( "a|all" => \$opts{a},
                "m|machine!" => \$opts{m},
                "u|user=s" => \@users,
                "h|help" => \$opts{h}) or usage();
    usage() if ($opts{h});

    # By default, applied with -a option.
    $opts{a} = 1 if (!$opts{a} and !$opts{m} and scalar(@users) == "0");
}

#
# Get the policy settings applied to local machine or AD users.
#
# $_[0]: $path - the file path of gp report file gp.report
#
# return: a hash ref, refer to constructor method new.
#
sub getPolicySettings
{
    my ($regFilePath) = @_;
    my $headers = {};
    my @regKeys;
    my $values = {};

    my $rc = open FD, "<", $regFilePath;
    if(!$rc)
    {
        DEBUG_OUT("Cannot open gp report file [$!].");
        return undef;
    }

    # Get the headers
    foreach my $key (@GP_HEADERS)
    {
        my $line = <FD>;
        chomp $line;
        $line =~ GP_PATTERN->{uc $key};
        $headers->{$key} = lc $1;
    }

    # Get the rest settings
    my $regKey = "";
    while (my $line = <FD>)
    {
        chomp $line;
        # Push all the registry keys into array.
        if ($line =~ GP_PATTERN->{GP_GROUP})
        {
            $regKey = $1;
            push(@regKeys, $regKey);
        }
        else # Store the setting entries to corresponding array.
        {
            push(@{$values->{$regKey}}, $line);
        }
    }
    close FD;

    # Make sure that all the registry keys are unique.
    unique(\@regKeys);
    return new($headers, \@regKeys, $values);
}

#
# Dump the gp result to the end users.
#
# $_[0]: a hash ref came from constructor method new.
#
sub dumpGP
{
    my ($gpResult) = @_;
    print "Name: $gpResult->{_name}\n";
    print "Last update: $gpResult->{_lastupdate}\n";
    print "Next update: $gpResult->{_nextupdate}\n";
    print "Deny RSoP: $gpResult->{_denyrsop}\n";
    print "Loopback Mode: $gpResult->{_loopbackmode}\n";

    print "\nResult Set of Policy\n";
    print "-----------------------------------------------------------------\n";
    my $regKeys = $gpResult->{_gpKeys};
    my $policyName = $gpResult->{_gpPolicyName};
    my $valueName = $gpResult->{_gpValueName};
    my $valueData = $gpResult->{_gpValueData};

    foreach my $key (sort @$regKeys)
    {
        next if (!$key);
        print "$key:\n";
        foreach my $pol (sort keys %{$policyName->{$key}})
        {
            if (!$pol)
            {
                print "${IN1}N/A\n";
                next;
            }
            my $result ="$IN1$pol:";
            my $detail = "";
            foreach my $val (sort @{$valueName->{$key}->{$pol}})
            {
                if ($val)
                {
                    $detail .= "$IN2$val=";
                    my $test = ${$valueData->{$key}->{$pol}}{$val};
                    if ($test eq '')
                    {
                        $detail .= "N/A";
                    }
                    else 
                    {
                        $detail .= $test;
                    }
                    $detail .= ",\n";
                }
            }
            if($detail) 
            {
                $result .= "\n$detail";
            }
            else
            {
                $result .= "N/A\n";
            }
            print $result;
        }
        print "\n";
    }
    print "-----------------------------------------------------------------\n";
}

sub dumpMachineGP
{
    my $gpFilePath = "$regBaseMachine/gp.report";
    if (!-f $gpFilePath)
    {
        DEBUG_OUT("No machine gp report file found.");
        return undef;
    }
    my $rsop = getPolicySettings($gpFilePath);
    if ($rsop)
    {
        dumpGP($rsop);
    }
}

sub dumpUserGP
{
    my ($uname) = @_;
    my $gpFilePath = "$regBaseUser/$uname/gp.report";
    if (!-f $gpFilePath)
    {
        DEBUG_OUT("No gp report file found for user $uname.");
        return undef;
    }
    my $rsop = getPolicySettings($gpFilePath);
    if ($rsop)
    {
        dumpGP($rsop);
    }
}

#>>>>>> Main >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
my $curUser = getpwuid($<);
my $euid = $>;
getMyOptions();

# Dump the machine gp settings when specified or by default
if($opts{m} or $opts{a})
{
    dumpMachineGP();
}

# Dump the current user gp settings by default
if($opts{a})
{
    push(@users, $curUser);
}

if (scalar @users)
{
    unique(\@users);
    foreach my $u (@users)
    {
        if ($euid != 0 and "$u" ne "$curUser")
        {
            ERROR_OUT "Error: Must be root to dump the other user's gp settings\n";
            next;
        }
        dumpUserGP($u);
    }
}
    

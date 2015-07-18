#!/usr/bin/perl

# gpresult.pl
#

use POSIX qw(strftime);
use strict;
use lib '/usr/share/centrifydc/perl';
use CentrifyDC::Config;

use constant GP_PATTERN =>
{
    NAME           => qr/^name: (.*)/,
    LAST_UPDATE    => qr/^lastupdate: (.*)/,
    NEXT_UPDATE    => qr/^nextupdate: (.*)/,
    REFRESH_RATE   => qr/^refreshRate: (.*)/,
    REFRESH_OFFSET => qr/^refreshOffset: (.*)/,
    DENYRSOP       => qr/^denyRsop: (.*)/,
    LOOPBACKMODE   => qr/^loopbackMode: (.*)/,

    GP_GROUP       => qr/^\[(.*)\]$/,
    GP_SETTINGS    => qr/(.*):(.*);(.*);(.*);(.*)/
};

my @LOOPBACK = ("Not Configure", "Merge", "Replace", "Disabled");
# variable to hold the location of the registry
my $regbaseuser = $CentrifyDC::Config::properties{"gp.reg.directory.user"};
my $regbasemachine = $CentrifyDC::Config::properties{"gp.reg.directory.machine"};

my $name;

if (defined $ARGV[0])
{
    $name = $ARGV[0];
}
else
{
    $name = (getpwuid($<))[0];
}

my $reportname = "gp.report";

sub getStringFormatTime
{
    my ($time) = @_;
    return strftime "%a %b %e %H:%M:%S %Y", localtime($time);
}

sub printGPSettings
{
    my ($set) = @_;
    chomp $set;
    my $result = "";
    $set =~ GP_PATTERN->{GP_SETTINGS};
    $result .= "    $1:$2 = ";
    if ($5 eq "true")
    {
        $result .= "Enabled";
    }
    elsif ($5 eq "false") 
    {
        $result .= "Disabled";
    }
    elsif ($5 or $5 eq "0")
    {
        $result .= "$5";
    }
    else 
    {
        return undef;
    }
    $result .= "\n";

    return $result;
}

sub parseGpReportor
{
    my $gpo = {};
    my $gpSettings = {};
    my @gpGroups;
    my ($gpType, $gpFile) = @_;
    print "--- Results for $gpType:\n";

    my $rc = open report, $gpFile;
    if (!$rc)
    {
        print "cannot open $gpFile\n";
        return;
    }
    my $line;

    $line = <report>;
    chomp $line;
    $line =~ GP_PATTERN->{NAME};
    $gpo->{name} = $1;

    $line = <report>;
    chomp $line;
    $line =~ GP_PATTERN->{LAST_UPDATE};
    $gpo->{last_update} = getStringFormatTime($1);

    $line = <report>;
    chomp $line;
    $line =~ GP_PATTERN->{NEXT_UPDATE};
    $gpo->{next_update} = getStringFormatTime($1);

    $line = <report>;
    chomp $line;
    $line =~ GP_PATTERN->{REFRESH_RATE};
    $gpo->{refresh_rate} = $1;

    $line = <report>;
    chomp $line;
    $line =~ GP_PATTERN->{REFRESH_OFFSET};
    $gpo->{refresh_offset} = $1;

    $line = <report>;
    chomp $line;
    $line =~ GP_PATTERN->{DENYRSOP};
    $gpo->{denyrsop} = $1 ? "Yes" : "No";

    $line = <report>;
    chomp $line;
    $line =~ GP_PATTERN->{LOOPBACKMODE};
    $gpo->{loopback_mode} = $LOOPBACK[$1];

    my $groupName = "";
    while ($line = <report>)
    {
        chomp $line;
        if ($line =~ GP_PATTERN->{GP_GROUP})
        {
           $groupName = $1; 
           push(@gpGroups, $1);
        }
        else
        {
            push (@{$gpSettings->{$groupName}}, $line);
        }
    }
    close report;
    my $gp_result = {
        gpo       => $gpo,
        gpGroups  => \@gpGroups,
        gpSettings => $gpSettings,
    };

    return $gp_result;
}

sub printGPResult
{
    my ($rsop) = @_;
    my $gpo = $rsop->{gpo};
    print "Name: $gpo->{name}\n";
    print "Last update: $gpo->{last_update}\n";
    print "Next update: $gpo->{next_update}\n";
    print "Deny RSoP: $gpo->{denyrsop}\n";
    print "Loopback Mode: $gpo->{loopback_mode}\n";

    print "\nResult Set of Policy\n";
    print "------------------------------------------------\n";

    my $gpGroups = $rsop->{gpGroups};
    my $gpSettings= $rsop->{gpSettings};
    foreach my $grp (@$gpGroups)
    {
        print "$grp\n";
        foreach my $set (@{$gpSettings->{$grp}})
        {
            last if (!$set);
            my $s = printGPSettings($set);
            if (defined $s)
            {
                print $s;
            }
            else
            {
                print "    N/A\n";
            }
        }
        print "\n";
    }
}

my $reportfile = $regbaseuser . "/" . $name . "/" . $reportname;

my $RSoP = parseGpReportor("user $name", "$reportfile");
printGPResult($RSoP) if($RSoP);

$reportfile = $regbasemachine . "/" . $reportname;
$RSoP = {};
$RSoP = parseGpReportor("computer", "$reportfile");
printGPResult($RSoP) if($RSoP);


#!/usr/bin/perl

use strict;
use lib '/usr/share/centrifydc/perl';
use lib '/usr/share/centrifydc/samples/hadoop/perl';
use CentrifyDC::GP::General qw(RunCommand ReadFile);
use CentrifyDC::Hadoop::Logger qw(:debug_user :debug_verbose);
my $file = "aaa.txt";

my $ofile = "/home/flueg/workspace/perl/escapeChar/bbb.txt";
$ofile = "bbb.txt";
open FD, "> $ofile" or die("cannot open file $ofile: $!");
print (FD "testing....\n");
my ($rc, $ctent) = RunCommand("ssh -t frhel65-lueg \'grep -in aaa /home/flueg/workspace/perl/escapeChar/aaa.txt\'");
foreach (split '\n', $ctent)
{
    s/[\r]//g;
    my $line = $_;
    print FD "$line";
    print "\n";
    print "line is [$line]". quotemeta($_)  ."\n";
    
    my $end = (split / /, $line)[-1];
    if ("$end" eq '\\')
    {
        printf("ending is $end]\n");
        VERBOSE_INFO("ending is $end]\n");
    }
    $line =~ s/\\$//g;
    print "subs line is [$line]\n";
}
close FD;

#!/usr/bin/perl

use strict;


my $pat = qr/\bhttp\b\s*|\s*\bhttp\b\s*$/;
my $str = "ftp cifs https http    nfs fluegfs    http     ";
print "before substituted: [$str]\n";

foreach (split " ", $str)
{
    next if(!m/http/);
    print "match $_\n";
}

if ($str =~ $pat)
{
    print "matched.\n";
    $str =~ s/$pat//g;
    print "after substituted: [$str]\n";
}


my $line = "aa /flueg/liu/name.schema bb/";
my $patt = qw"/flueg/liu/name.schema";
$line =~ s'/$''g;
if ($line =~ /$patt/s)
{
    print "after: [$line]\n";
}


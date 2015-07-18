#!/usr/bin/perl

my $match = "adinfo (CentrifyDC 5.2.3-379)";
my $pattern = qr/CentrifyDC\s+(.*)-/;

my $version = ($match =~ /$pattern/)[0];
print"Version is [$version].\n";

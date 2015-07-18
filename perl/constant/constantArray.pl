#!/usr/bin/perl
use strict;
use constant INCLUDE_SCHEMAS => qw(required standard inetOrg 2307 solaris);

foreach (INCLUDE_SCHEMAS)
{
    print $_ . " ";
}

print "\n";

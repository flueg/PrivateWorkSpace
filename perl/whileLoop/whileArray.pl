#!/usr/bin/perl
use strict;
use constant INCLUDE_SCHEMAS => qw(required standard inetOrg 2307 solaris);
my @INCLUDE_SCHEMAS = qw(required standard inetOrg 2307 solaris);
my @accept = [];

while (defined(my $item = shift @INCLUDE_SCHEMAS))
{
    print $item . " ";
}
continue
{
    #print("sleeping...\n");
    push @accept, $item;
    #sleep 1;
}

print @accept;
print "\n";

print scalar INCLUDE_SCHEMAS;
foreach (INCLUDE_SCHEMAS)
{
    print("$_ ");
}
print "\n";

#!/usr/bin/perl

sub EscapeSingleQuote($)
{
    my $str = $_[0];
    $str =~ s/'/'\\''/g;
        return $str;
}

my $file = "/tmp; rm '/tmp/test.tmp'";
my $cmd = "ls '" . EscapeSingleQuote($file) . "'";
#my $cmd = "ls '" . $file . "'";

print $cmd;
my $rc = `$cmd`;
print $rc;

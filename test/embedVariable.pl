#!/bin/sh /usr/share/centrifydc/perl/run

use strict;

my $file = {
    'write_data' => '$value $data\n',
};

my $value = "[flueg]";
my $data = "liu";

open my $tmp, '>', "/tmp/aaaxxx.config";
(my $output = $file->{'write_data'}) =~ s/(["'])/\\$1/g;
eval "print(\$tmp \"$output\")";
eval "print(\"$output\")";
close $tmp;
if (defined($file->{'flueg'}->{raw_key}))
{
    print "defined\n";
}

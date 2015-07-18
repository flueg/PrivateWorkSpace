#!/usr/bin/perl
use strict;
use File::stat;

my $file = "do_slapd_restart";
my $sb = stat($file);
printf("List modify time of $file is: %s\n", $sb->mtime);

printf("Time now is: %s\n", time());
if(time() - $sb->mtime < 3600)
{
    print("within 1 hour.\n");
}



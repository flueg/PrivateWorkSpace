#!/usr/bin/perl

use File::Basename;

my $program = $0;
print"$program\n";

$bname = basename($program);
print("base name: $bname\n");

$dname = dirname($program);
print("dir name: $dname\n");

$dname = "$ENV{PWD}/$dname" if ($dname !~ '^/');
print("dir name again: $dname\n");
print("ENV pwd is: $ENV{PWD}\n");

printf("cmd pwd is %s", `pwd`);

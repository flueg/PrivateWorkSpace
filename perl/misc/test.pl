#!/usr/bin/perl

my $ddn = "win2k8.flueg.test";
my $DN = ();
push @$DN, $ddn;
$dn = shift @$DN;
$dn =~ s/\./,dc=/g;
$dn = "DC=" . "\U$dn";

print "$dn\n";

my $line = "  include         /etc/centrifydc/openldap/schema/cosine.schema   ";
$line =~ /([^\s]+)\s*(.*)/;
print "[$1]\t\t[$2]\n";
my ($key, $value) = ($1, $2);
$value =~ s/\s*$//g;
print "[$key]\t\t[$value]\n";

my $hash = {};
print "hash ref already defined\n" if (defined $hash);

my $fname = "/usr/bin/ab";
my $realName = readlink($fname);
print "real name: $realName\n";


#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
my %test;

print "command: $0\n";
my $u1 = "flueg";
my $u2 = "aucean";
my $file = "my_file";

sub gethash();

push (@{$test{$u1}}, "\npush1\n");
push (@{$test{$u2}}, "\npush2\n");
push (@{$test{$u1}}, "\npush3\n");

foreach my $key (keys %test)
{
    $test{$key} = \@{$test{$key}};
}
foreach my $key (keys %test)
{
    #print "[$key]Ahhhhh! @{$test{$key}}";
}

my $hash = gethash();
print "shift!!\n" if defined $hash;
foreach my $k (keys %$hash)
{
    print "get hash $k" . "\n";
}
delete $hash->{a};

sub gethash()
{
    my %h;
    #$h{'a'} = b;
    return \%h;
}

open my $fd, "<", $file;
my $cl;
while ($cl = <$fd>)
{
    last if ("$cl" eq "0");
    print $cl;
}

sub maskDeclaration
{
    my ($var) = "First declare";
    print $var ."\n";
    foreach (qw/1 2/)
    {
        my ($var) = "Second declare $_\n";
        print $var;
    } 
}

#maskDeclaration
sub mD()
{
    my @arr = qw/aaa aab aac aaab aaaa aaba/;
    print "@arr";
    print "\n";
    @arr = grep {$_ ne 'aaa' and $_ ne 'aab'} @arr;
    foreach (@arr)
    {
        print "$_ ";
    }
    print "\n";
}


sub testfilebase()
{
    #my $match = "/tmp/cores/core.a.a.%u|/usr/libexec/abrt-hook-ccpp %s %c %p %u %g %t e";
    my $match = "/tmp/";
    my $match = ($match =~ /([^|]*|.*)/)[0];
    print "after cut: [$match]\n";
    my $fname = basename($match);
    my $dname = dirname($match);
    $fname = ($fname =~ /([^%\.]*).*/)[0];
    print "dir name: [$dname], base name: [$fname]\n";
    if ("coreaaaaa" =~ qr/$fname/)
    {
        print "$fname match 'coreaaaaa'\n";
    }
    if ("core.a" =~ qr/$fname/)
    {
        print "$fname match 'core.a.a.'\n";
    }

    my $bb = "c";
    my $aa = \$bb;
    print $$aa;
}

sub subparameter
{
    my ($msg) = @_;
    print $msg;
}

my $ss = "I;m bean zhang. I dont know you anyway.";
if ($ss =~ /(aucean|bean|flueg) zhang/)
{
    print "Match!!\n";
}

subparameter("I like it.");

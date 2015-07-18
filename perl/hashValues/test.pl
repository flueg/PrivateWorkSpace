#!/usr/bin/perl

my $hash = {
    'a' => 5,
    'b' => 2,
    'c' => 7,
    'd' => 10,
    'e' => -1,
};

my @arr = sort {$a <=> $b} values %$hash;
my $min = $arr[0];

printf("the minimal number is %d\n", $min);

my @arrtest = ();
if (defined(\@arrtest))
{
    print("array ref is defined: \@arrtest\n");
}

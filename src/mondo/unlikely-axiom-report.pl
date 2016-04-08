#!/usr/bin/perl
my @axs = ();
while(<>) {
    if (m@\* (.*) Pr= (\S+)@) {
        push(@axs, [$2, $1]);
    }
}
@axs = sort { $a->[0] <=> $b->[0] } @axs;
foreach (@axs) {
    print "$_->[0]\t$_->[1]\n";
}

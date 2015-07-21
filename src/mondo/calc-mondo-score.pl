#!/usr/bin/perl
while(<>) {
    my ($dis,$depth) = split(/\t/,$_);
    $tot_depth += $depth;
    $n++;
}
my $score = $tot_depth / $n;
print "SCORE\t$score\n";

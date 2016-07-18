#!/usr/bin/perl -w
use strict;
my %maph = ();
my %nh = ();
my $num = 0;
while(<>) {
    chomp;
    my ($id,$n,$x,$xn,$stem) = split(/\t/,$_);
   
    if ($id =~ m@UMLS@) {
        $num++;
        my $s = $x;
        $s =~ s@:.*@@;
        my $tuple = [$s, $x,$xn,$stem];
        if (!$maph{$id}) {
            $maph{$id} = $tuple;
        }
        else {
            my $curr = $maph{$id};
            my $replace = 0;
            if ($stem eq 'true' && $curr->[3] eq 'false') {
                # never replace a non-stem with a stemmed
                $replace = 0;
            }
            elsif ($stem eq 'false' && $curr->[3] eq 'true' && $s eq $curr->[0]) {
                # prioritize non-stem
                $replace = 1;
            }
            elsif ($s eq 'OMIM') {
                $replace = 1;
            }
            elsif ($s eq 'MESH') {
                $replace = 0;
            }
            if ($replace) {
                $maph{$id} = $tuple;
            }
        }
    }
}
print STDERR "DONE: $num\n";
foreach my $k (keys %maph) {
    my ($s, $x, $xn) = @{$maph{$k}};
    print "$k\t$x\n";
}

#!/usr/bin/perl
use strict;
my %curh = ();
my $n=0;
while(<>) {
    chomp;
    my @vals = split(/\t/,$_);
    next if m@^#@;
    next if m@^\s*$@;
    if (@vals == 1) {
        ## curated-ptable
        #
        ## OVERRIDES
        if (m@^(\S+)\s+(\S+) (.*) (SubClassOf|EquivalentTo|SuperClassOf|SiblingOf|DisjointWith) (\S+) (.*)$@) {
            my @tuple = ($1,$2,$3,$4,$5);
            my ($p,$x,$xn,$rel,$y,$yn) = @tuple;

            # VERY FRAGILE
            # flip orientation 
            # ---
            $x =~ s@_@:@;
            $y =~ s@_@:@;
            if ($x gt $y) {
                ($x,$y) = ($y,$x);
                if ($rel eq 'SuperClassOf') {
                    $rel = 'SubClassOf';
                }
                elsif ($rel eq 'SubClassOf') {
                    $rel = 'SuperClassOf';
                }
                
            }
            @tuple = ($p,$x,$xn,$rel,$y,$yn);
            # ---

            print STDERR "TUP: @tuple\n";
            push(@{$curh{"$x-$y"}}, \@tuple);
        }
        else {
            die "Line: '$_' does not match pattern";
        }
    }
    elsif (@vals == 6) {
        # auto-derived ptable
        #
        ## EXISTING
        my ($x,$y, @probs) = @vals;
        my @tuples = @{$curh{"$x-$y"} || []};
        if (@tuples) {
            print STDERR "MATCH $x-$y -- will override\n";
            foreach my $t (@tuples) {
                print STDERR "T: @$t\n";
                recalc(\@probs, $t->[3], $t->[0]);
                $n++;
            }
            delete $curh{"$x-$y"};
        }
        print join("\t", ($x,$y,@probs))."\n";
    }
    else {
        die "Line: '$_' has cols == ".scalar(@vals);
    }
}
print STDERR "FIXED: $n\n";
if (keys %curh) {
    print STDERR "LEFT BEHIND: $_\n" foreach keys %curh;
    foreach my $pair (keys %curh) {
        my ($x,$y) = ($pair =~ m@(\S+)-(\S+)@);
        my @tuples = @{$curh{$pair}};
        my @probs = (0.25, 0.25, 0.25, 0.25);
        foreach my $t (@tuples) {
            recalc(\@probs, $t->[3], $t->[0]);
        }
        print join("\t", ($x, $y, @probs))."\n";
    }
}
exit 0;

sub recalc {
    my $probs = shift;
    my $t = shift;
    my $p = shift;
    my $ix = -1;
    if ($t eq 'SubClassOf') {
        $ix = 0;
    }
    elsif ($t eq 'SuperClassOf') {
        $ix = 1;
    }
    elsif ($t eq 'EquivalentTo') {
        $ix = 2;
    }
    elsif ($t eq 'SiblingOf') {
        $ix = 3;
    }
    elsif ($t eq 'DisjointWith') {
        # we treat this as the same as SiblingOf for now, but in fact it should be stronger
        $ix = 3;
    }
    else {
        die "TYPE=$t";
    }
    my $decrease = $probs->[$ix] - $p;
    $probs->[$ix] = $p;
    my $sumrest = 0;
    print STDERR "IX=$ix\n";
    for (my $i=0; $i<4; $i++) {
        if ($i != $ix) {
            $sumrest += $probs->[$i];
        }
    }
    print STDERR "SUMREST=$sumrest\n";
    for (my $i=0; $i<4; $i++) {
        if ($i != $ix) {
            $probs->[$i] *= (1-$p)/$sumrest;
        }
    }
    
}

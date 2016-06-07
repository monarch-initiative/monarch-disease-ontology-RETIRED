#!/usr/bin/perl
use strict;
my %curh = ();
my $n=0;
while(<>) {
    chomp;
    my @vals = split(/\t/,$_);
    next if m@^#@;
    if (@vals == 1) {
        ## OVERRIDES
        if (m@^(\S+)\s+(\S+) (.*) (SubClassOf|EquivalentTo|SuperClassOf) (\S+) (.*)$@) {
            my @tuple = ($1,$2,$3,$4,$5);
            my ($p,$x,$xn,$rel,$y,$yn) = @tuple;
            $x =~ s@_@:@;
            $y =~ s@_@:@;
            if ($x gt $y) {
                ($x,$y) = ($y,$x);
                if ($tuple[3] eq 'SuperClassOf') {
                    $tuple[3] = 'SubClassOf';
                }
                if ($tuple[3] eq 'SubClassOf') {
                    $tuple[3] = 'SuperClassOf';
                }
                
            }
            push(@{$curh{"$x-$y"}}, \@tuple);
        }
        else {
            die $_;
        }
    }
    elsif (@vals == 6) {
        ## EXISTING
        my ($x,$y, @probs) = @vals;
        my @tuples = @{$curh{"$x-$y"} || []};
        if (@tuples) {
            print STDERR "MATCH $x-$y -- will override\n";
            foreach my $t (@tuples) {
                recalc(\@probs, $t->[3], $t->[0]);
                $n++;
            }
            delete $curh{"$x-$y"};
        }
        print join("\t", ($x,$y,@probs))."\n";
    }
    else {
        die "$_ has cols == ".scalar(@vals);
    }
}
print STDERR "FIXED: $n\n";
if (keys %curh) {
    print STDERR "LEFT BEHIND: $_\n" foreach keys %curh;
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

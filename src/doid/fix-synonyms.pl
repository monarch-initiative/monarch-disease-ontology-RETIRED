#!/usr/bin/perl
my $n;
while(<>) {
    chomp;
    if (m@name: (.*)@) {
        $n = $1;
    }
    if (m@synonym: \"(.*)\" EXACT (.*)@) {
        my ($syn,$x) = ($1,$2);
        if ($syn =~ /type/i) {
            $syn =~ s/,*\s+type.*//i;
            $syn =~ s/type\s+\S+//i;
            if (lc($syn) eq lc($n)) {
                print STDERR "FIXING: $_\n";
                s@EXACT@NARROW@;
            }
        }
        if ($syn =~ / \d+$/i) {
            $syn =~ s/ \d+$//i;
            if (lc($syn) eq lc($n)) {
                print STDERR "FIXING: $_\n";
                s@EXACT@NARROW@;
            }
        }
    }
    print "$_\n";
}

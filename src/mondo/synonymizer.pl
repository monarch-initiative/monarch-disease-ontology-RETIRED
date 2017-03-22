#!/usr/bin/perl
my ($init,$last);
while(<>) {
    # very hacky fix for https://github.com/monarch-initiative/monarch-disease-ontology/issues/215
    # we need to fix upstream problem as we can't hope to catch all cases this way
    s@MC<llerian@Mullerian@;
    s@WaldenstrC6m@Waldenstrom@;
    
    print $_;
    chomp;
    if (m@^name: (.*)@) {
        $n=$1;
        if ($n =~ m@(.*); (\S+)$@) {
            my $syn = $2;
            $n = $1;
            print "synonym: \"$n\" EXACT []\n";

            if (length($syn) > 4) {
                $scope = 'EXACT';
            }
            else {
                $scope = 'RELATED';
            }
            print "synonym: \"$syn\" $scope []\n";
        }
        if ($n =~ m@(.*) (\S+)$@) {
            ($init,$last) = ($1,$2);
            if ($last =~ m@^.$@) {
                yo(1, $_);
            }
            elsif ($last =~ m@^\d+$@) {
                yo(2, $_);
            }
            elsif ($last =~ m@^[ivx]+$@i) {
                yo(3, $_);
            }
            elsif ($last =~ m@^\d+.$@) {
                yo(4, $_);
            }
            elsif ($last =~ m@^[ivx]+.$@i) {
                yo(5, $_);
            }
            elsif ($last =~ m@^\d+[ivx]+$@i) {
                # e.g. Cardiomyopathy, Dilated, 1Ii
                yo(6, $_);
            }
            elsif ($last =~ m@^\d+[a-z]\d+$@i) {
                yo(7, $_);
            }
            elsif ($last =~ m@^\d+[ivx]+\d+$@i) {
                yo(8, $_);
            }
            elsif ($last =~ m@^\d+\w+$@i) {
                yo(9, $_);
            }

        }
    }
}
sub yo {
    my $t = shift;
    #print "$t: $x\n";
    if ($init =~ m@type@i) {
    }
    else {
        print "synonym: \"$init type $last\" EXACT [MONDORULE:$t]\n";
    }
}
    

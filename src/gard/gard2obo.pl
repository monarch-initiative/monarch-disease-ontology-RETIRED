#!/usr/bin/perl
use strict;

print "ontology: gard\n";
print "\n";

while(<>) {
    chomp;
    my @vals = split(/\t/,$_);
    fixq(@vals);
    my ($id, $x, $y, $n, $syns, $omim, $ordo, $url) = @vals;
    next unless $id > 0;
    $id = sprintf("%07d",$id);
    print "[Term]\n";
    print "id: GARD:$id\n";
    print "name: $n\n";
    print "synonym: \"$_\" RELATED []\n" foreach split(/;/, $syns);
    print "xref: OMIM:$_\n" foreach split(/;/, $omim);
    print "xref: Orphanet:$_\n" foreach split(/;/, $ordo);
    print "xref: $url\n";
    print "\n";

}

sub fixq {
    map { s/^\"//;s/\"$//;$_ } @_;
}

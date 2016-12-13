#!/usr/bin/perl

while(<>) {
    $idnum = $1 if m@^id: OMIM:(\d+)@;
    if (m@^def:@) {
        #$_ = "def: \"See http://www.omim.org/entry/$idnum\" []\n";
        next;
    }
    print $_;
}

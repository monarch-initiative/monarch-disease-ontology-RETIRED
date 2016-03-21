#!/usr/bin/perl
while(<>) {
    s@^xref: ORDO:@xref: Orphanet:@g;
    print $_;
}

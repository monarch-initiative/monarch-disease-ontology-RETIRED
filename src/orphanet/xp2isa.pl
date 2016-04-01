#!/usr/bin/perl
while(<>) {
    s@intersection_of: DOID@is_a: DOID@;
    s@intersection_of: has_part DOID:630 @is_a: DOID:630 @;
    next if m@^intersection@;
    print;
}

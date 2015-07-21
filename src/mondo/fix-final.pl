#!/usr/bin/perl
while(<>) {
    next if m@^owl-axioms@;
    next if m@^comment: OMIM mapping confirmed by DO@;
    print;
}

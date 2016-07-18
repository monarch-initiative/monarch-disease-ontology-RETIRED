#!/usr/bin/perl
while(<>) {
    s@ EXACT @ RELATED @;
    print $_;
    if (m@synonym: "(.*), formerly" \S+@i) {
        print "synonym: \"$1\" RELATED []\n";
    }
}

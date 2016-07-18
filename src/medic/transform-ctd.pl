#!/usr/bin/perl

print "ontology: mesh\n";
while(<>) {
    chomp;
    if (m@^id: (\S+)@) {
        $id = $1;
    }
    if ($id =~ /OMIM/) {
        next if m@^name:@;
        next if m@^synonym:@;
    }
    if (m@^synonym: "(.*)"\s+\S+\s+\[@) {
        my $s = $1;
        if ($s !~ /[a-z]/) {
            next;
        }
    }
    s@^alt_id:@xref:@;
    s@ EXACT @ RELATED @;
    print "$_\n";
}

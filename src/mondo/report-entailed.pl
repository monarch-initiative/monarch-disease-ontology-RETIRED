#!/usr/bin/perl
my $pfx = shift @ARGV;
my @lines = ();
my $n=0;
print "# Entailed/Inferred links from $pfx\n\n";
while(<>) {
    if (m@\[img\]\(target/(.*)\)@) {
        $img = $1;
    }
    if (m@MESSAGE: ENTAILED: (\w+)_(\S+) (.*) SubClassOf (\S+) (.*)@) {
        my ($mpfx, $lid1, $n1, $id2, $n2) = ($1,$2,$3,$4,$5);
        if ($mpfx eq $pfx) {
            my $url1 = mkurl($pfx . "_$lid1");
            my $url2 = mkurl($id2);
            $n++;
            my $link = lc("$n1---$n2");
            $link =~ tr@a-zA-Z0-9@-@c;
            $link = '#'.$link;
            print " $n. [$n1 -> $n2]($link)\n";
            push(@lines,  "## $n1 -> $n2\n\n");
            push(@lines,  " * [$n1]($url1) __SubClassOf__ [$n2]($url2)\n\n");
            push(@lines, "![img](target/$img)\n\n");
            `cp target/$img ../reports/new-subclass/target/`;
        }
    }
}

print "\n## REPORT\n\n";
print $_ foreach @lines;


exit 0;

sub mkurl {
    my $id = shift;
    if ($id =~ m@Orphanet_(\S+)@) {
        return "http://www.orpha.net/consor/cgi-bin/OC_Exp.php?Expert=$1";
    }
    return "http://purl.obolibrary.org/obo/$id";
}

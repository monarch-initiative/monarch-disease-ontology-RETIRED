#!/usr/bin/perl
use strict;

my %th = ();
my %rh = ();

our $PATH = "ftp.ncbi.nlm.nih.gov/pub/medgen";

open(F,"gzip -dc $PATH/MGCONSO.RRF.gz|") || die;
while(<F>) {
    chomp;
    my ($CUI, $TS, $STT, $ISPREF, $AUI, $SAUI, $SCUI, $SDUI, $SAB, $TTY, $CODE, $STR, $SUPPRESS) = split(/\|/,$_);
    #print "$CUI\n";
    $th{$CUI}->{name} = $STR if $TS eq 'P';  # choose arbitrary
    my $x = "$SAB:$CODE";
    push(@{$th{$CUI}->{synonyms}}, [$STR, $x]);
    $th{$CUI}->{xrefs}->{$x} = 1;
}
close(F);


open(F,"gzip -dc $PATH/MGREL.RRF.gz|") || die;
while(<F>) {
    chomp;
    my (
        $CUI1  , # first concept unique identifier
        $AUI1 , # first atom unique identifier, where an atom is one term from a source
        $STYPE1 , # the name of the column in MRCONSO.RRF that contains the first identifier to which the relationship is attached
        $REL , # relationship label
        $CUI2 , # second concept unique identifier
        $AUI2 , # second atom unique identifier, where an atom is one term from a source
        $RELA , # additional relationship label
        $RUI , # relationship unique identifier
        $SAB , # abbreviation for the source of the term (Defined here)
        $SL , # source of relationship label
        $SUPPRESS , # suppressed by UMLS curators
        ) = split(/\|/, $_);
    $rh{$CUI1}->{$REL}->{$CUI2} = $SL;
    #print "$CUI1 $REL $CUI2\n";
}
close(F);

print "ontology: medgen\n\n";
my @ids = keys %th;
@ids = sort @ids;
foreach my $id (@ids) {
    my $h = $th{$id};
    print "[Term]\n";
    print "id: UMLS:$id\n";
    print "name: $h->{name}\n";
    foreach my $x (keys %{$h->{xrefs}}) {
        print "xref: $x\n";
    }
    foreach my $s (@{$h->{synonyms}}) {
        my ($str, $x)= @$s;
        print "synonym: \"$str\" RELATED [$x]\n";
    }
    my $trelh = $rh{$id};
    foreach my $rel (keys %{$trelh}) {
        my $vh = $trelh->{$rel};
        foreach my $v (keys %$vh) {
            print "relationship: $rel $v {source=\"$vh->{$v}\"}\n";
        }
    }
    print "\n";
}

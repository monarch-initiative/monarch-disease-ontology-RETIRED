#!/usr/bin/perl
use strict;

my %th = ();
my %rh = ();

our $PATH = "ftp.ncbi.nlm.nih.gov/pub/medgen";

open(F,"gzip -dc $PATH/MGCONSO.RRF.gz|") || die;
while(<F>) {
    chomp;
    my ($CUI, $TS, $STT, $ISPREF, $AUI, $SAUI, $SCUI, $SDUI, $SAB, $TTY, $CODE, $STR, $SUPPRESS) = split(/\|/,$_);
    if (!$th{$CUI}->{name} || $TS eq 'P') {
        $th{$CUI}->{name} = $STR;
    }

    my $x = "$SAB:$CODE";
    if ($SAB eq 'HPO') {
        $x = $SDUI;
    }
    if ($SAB eq 'ORDO') {
        $x = $SDUI;
        $x =~ s/_/:/;
    }
    if ($x =~ /OMIM:MTHU/) {
        next;
    }
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
    next if $REL eq 'SIB';
    next if $REL eq 'inverse_isa';
    my $rn = $RELA ? $RELA : $REL;
    $rh{$CUI2}->{$rn}->{$CUI1} = $SL;
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
            unless ($v eq $id) {
                my $tag = "relationship: $rel";
                if ($rel eq 'isa') {
                    $tag = 'is_a:';
                }
                if ($rel eq 'mapped_to') {
                    $tag = 'equivalent_to:';
                }
                print "$tag UMLS:$v {source=\"$vh->{$v}\"} ! $th{$v}->{name}\n";
            }
        }
    }
    print "\n";
}

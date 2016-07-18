#!/usr/bin/perl

my @out = ();
while(<>) {
    # no longer required
    #s@&obo;http://www.obofoundry.org/ro/ro.owl#part_of@&obo;BFO_0000050@g;
    s@MeSH@MESH@;s@ICD-10@ICD10@;
    if (m@^is_a: http://www.orpha.net/ORDO/ObsoleteClass@) {
        s@^is_a: http://www.orpha.net/ORDO/ObsoleteClass.*@is_obsolete: true@;
        $out[-1] =~ s@name: @name: obsolete @;
    }
    s@^property_value: http://www.ebi.ac.uk/efo/reason_for_obsolescence "use http://www.orpha.net/ORDO/(\S+)_(\S+).*@replaced_by: $1:$2@;
    push(@out, $_);
}
print foreach @out;

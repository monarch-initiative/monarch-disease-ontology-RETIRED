#!/usr/bin/perl

while(<>) {
    s@&obo;http://www.obofoundry.org/ro/ro.owl#part_of@&obo;BFO_0000050@g;
    s@MeSH@MESH@;s@ICD-10@ICD10@;
    print;

}

#!/usr/bin/perl
while(<>) {
    s@property_value: NCIT:P207 "(\S+)" xsd:string@xref: UMLS:$1@;
    print;

}

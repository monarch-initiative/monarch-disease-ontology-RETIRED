#!/usr/bin/perl
while(<>) {
    s@^xref: ORDO:@xref: Orphanet:@g;
    s@^xref: ICD10CM:@xref: ICD10:@g;
    s@^xref: ICD9CM:@xref: ICD9:@g;
    s@^xref: SNOMEDCT_\w+:@xref: SCTID:@g;
    s@^xref: UMLS_CUI:@xref: UMLS:@g;
    s@^xref: MSH:@xref: MESH:@g;
    s@^xref: NCI:@xref: NCIT:@g;
    print $_;
}

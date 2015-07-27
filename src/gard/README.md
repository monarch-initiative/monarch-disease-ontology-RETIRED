## Alignment with GARD

See the [Makefile](Makefile) for technical details

The following are of most relevance:

 * [suggest_new.tsv](suggest_new.tsv)
    * Entries in GARD xls that have no OMIM and no Orphanet, we provide a suggestion
    * Columns: (GARD Disease, mapped MonDo disease)
    * Note the formatting looks odd if viewed from the GH webpage. Download and view in excel if preferred
 * [different.tsv](different.tsv)
    * Entries in GARD xls for which our automatic procedure disagrees with the GARD OMIM or Orphanet assignment
    * 3 Columns: (GARD disease, GARD mapping, our MonDo mapping)
    * Note if viewed on GH website the 3rd column is truncated. View raw or download excel


As an example of one where we disagree, GARD has the following lines:

    624                     Autosomal dominant Alport syndrome      Alport syndrome dominant type;Renal failure and sensorineural hearing loss      104200  63      http://rarediseases.info.nih.gov/gard/624/Autosomal-dominant-Alport-syndrome/resources/1
    625                     Autosomal recessive Alport syndrome     Alport deafness-nephropathy;Alport syndrome;Alport syndrome autosomal recessive;Alport syndrome recessive type;Nephropathy and deafness 203780    63;88919        http://rarediseases.info.nih.gov/gard/625/Autosomal-recessive-Alport-syndrome/resources/1
    ...
    5785                    Alport syndrome "Alport syndrome, X-linked;Congenital hereditary hematuria;Hemorrhagic familial nephritis;Hemorrhagic hereditary nephritis;X-linked Alport syndrome"    301050  63;88917  http://rarediseases.info.nih.gov/gard/5785/Alport-syndrome/resources/1


Note that GARD 624 and 625 both use a *specific* subtype of Alport in the name column, and for 5785, the *generic* Alport. The orphanet IDs linked are 63, 63 and 88917

However, this is the *inverse* of what is in ORDO:

 * Orphanet:63 ! Alport syndrome  `<---` *GARD 624 and 625 map here* 
    * Orphanet:88917 ! X-linked Alport syndrome  `<---` *GARD 5785 maps here* 
    * Orphanet:88918 ! Autosomal dominant Alport syndrome
    * Orphanet:88919 ! Autosomal recessive Alport syndrome

Note also that GARD uses the more specific form in the syns column (`X-linked Alport syndrome`), which justifies linking to  Orphanet:88917

This is what our [different.tsv](different.tsv) report says:

```
GARD DISEASE                                       GARD MAPPING    OUR SUGGESTION
------------                                       ------------    --------------
GARD:0000624 ! Autosomal dominant Alport syndrome  Orphanet:63     OMIM:104200 ! Autosomal dominant Alport syndrome
GARD:0000625 ! Autosomal recessive Alport syndrome Orphanet:63     OMIM:203780 ! Autosomal recessive Alport syndrome
GARD:0005785 ! Alport syndrome                     Orphanet:88917  DOID:10983 ! Alport syndrome
```

i.e. our procedures wants to 'push down' the first two to the more specific OMIM IDs, and for the last one it wants to use the generic form, as consistent with the GARD name (but not the GARD synonyms). Should we prioritize synonyms here?

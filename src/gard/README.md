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

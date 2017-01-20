# MedGen

https://www.ncbi.nlm.nih.gov/medgen/docs/help/

MedGen aggregates multiple disease vocabularies.

UMLS CUIs are used as primary IDs, except where no UMLS concept
exists. In these cases, a CN ID is provided.

MedGen does not add new classification (is_a). The UMLS hierarchy is
used (there is no hierarchy for CN IDs).

As such, MedGen inherits the issues of the UMLS hierarchy, e.g.


```
UMLS:C1335042 ! Non-Neoplastic Skin Disorder
   ^  |
   |  |
   |  v
UMLS:C0037274 ! Disease, Skin
```

With the standard OWL interpretation of SubClassOf, this renders the
two concepts equivalent. As our computations use OWL semantics, we
can't incorporate UMLS links as axioms without causing
collapsing of the graph.

This also means we cannot incorporate the UMLS axioms as hard links
into the kBOOM process. One area to explore would be to translate the
UMLS links into *probabilistic* links.

However, this is currently out of scope. For now we cross-reference
UMLS IDs (we get these from DOID).

We could add additional xrefs for the CNs. However, these seem to
recapitulate what we already have IDs for via OMIM etc. If these CNs
are being actively used to annotate useful information we will
consider adding these.





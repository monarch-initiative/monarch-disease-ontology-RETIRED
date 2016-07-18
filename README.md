[![Build Status](https://travis-ci.org/cmungall/monarch-disease-ontology.svg?branch=master)](https://travis-ci.org/cmungall/monarch-disease-ontology)
[![DOI](https://zenodo.org/badge/13996/cmungall/monarch-disease-ontology.svg)](https://zenodo.org/badge/latestdoi/13996/cmungall/monarch-disease-ontology)

## MonDO

MonDO (Monarch Disease Ontology) is a semi-automatically constructed
ontology that merges in multiple disease resources to yield a coherent
merged ontology.

The procedure is broken into the following steps:

 1. Pre-processing of ontologies -- see the [src/](src/) directory
 2. Gathering of loose ontology mappings, and translating these into __weighted candidate axioms__
 3. Estimation of the most likely Ontology using [kBOOM](https://github.com/monarch-initiative/kboom)
 4. Merging equivalence sets and post-processing.

See the Makefile in the [src/ontology](src/ontology) directory for the execution of these steps.

### Pre-Processing

Each disease resource or ontology is pre-processed. In some cases, only a subset of the ontology is used

 * [ORDO/Orphanet](orphanet/README.md)
 * [DO](doid/README.md)
 * [GARD](gard/README.md) -- aligned as post-processing step
 * [OMIM](omim/README.md) -- note we only use labels from OMIM
 * [MedGeb](medgen/README.md) -- not yet incorporated
 * [NCIT](ncit/README.md) -- aligned as post-processing step
 * [OMIA](omia/README.md) -- Mendelian diseases in non-human animals
 * [MESH](medic/README.md) -- We use MEDIC as our initial pre-processed set
 * [DiseaseClusters](clusters/README.md) -- Additional groupings of OMIM. Includes DECIPHER.

### Translating mappings to weighted candidate axioms

We use mappings as an input, but not as an end-goal. Our end goal is a
coherent merged ontology, with strictly defined relationships between
them (next step). However, we make use of mappings to generate
candidate weighted axioms.

We make use of some ready-made mappings. Additionally, we supplant
these with our own using approaches such as entity matching.




## MonDO Curators Instructions

See [README-editors](README-editors.md)

## Disease2GO

 * [disease2go.tsv](src/ontology/disease2go.tsv)
 * [disease2go.obo](src/ontology/disease2go.obo)




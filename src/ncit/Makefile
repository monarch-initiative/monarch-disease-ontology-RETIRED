all: neoplasm.obo

# ----------------------------------------
# DOWNLOAD
# ----------------------------------------
neoplasm-src.owl:
	wget build-artifacts.berkeleybop.org/ncit-obo/latest/subsets/neoplasm.owl -O $@ && touch $@
.PRECIOUS: neoplasm-src.owl

neoplasm-src.obo: neoplasm-src.owl
	owltools $< -o -f obo $@

# ----------------------------------------
# ADD DISJOINTNESS AXIOMS
# ----------------------------------------
neoplasticity.rdf: neoplasm-src.owl
	arq --query construct-malignant.sparql --data $< > $@.tmp && mv $@.tmp $@

neoplasm-combined.owl: neoplasm-src.owl neoplasticity.rdf upper.obo
	owltools $^ --merge-support-ontologies  -o $@.tmp && mv $@.tmp $@
#	owltools $^ --merge-support-ontologies --remove-annotation-assertions -l -r -d -s -o $@.tmp && mv $@.tmp $@

# ----------------------------------------
# TORTURE IDS
# ----------------------------------------
neoplasm-combined-fixiri.owl: neoplasm-combined.owl
	perl -npe 's@http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#@http://purl.obolibrary.org/obo/NCIT_@g;' $<   > $@.tmp && mv $@.tmp $@

neoplasm-combined-fixiri.obo: neoplasm-combined-fixiri.owl
	owltools $< -o -f obo $@.tmp && ./fix-xrefs.pl $@.tmp > $@

# ----------------------------------------
# REMOVE OBSOLETES
# ----------------------------------------
# Hack until: https://github.com/ontodev/ncit-obo/issues/19
obsolete.obo: neoplasm-src.obo
	blip ontol-query -i $< -query "inst_sv(ID,'P310','Obsolete_Concept',_)" -to obo > $@
retired.obo: neoplasm-src.obo
	blip ontol-query -i $< -query "inst_sv(ID,'P310','Retired_Concept',_)" -to obo > $@

neoplasm_pre.obo: neoplasm-combined-fixiri.obo obsolete.obo retired.obo
	obo-subtract.pl $^ > $@

# ----------------------------------------
# REASONING
# ----------------------------------------
# Purpose:
#  - ensure coherent
#  - remove redundant PATO SubClassOf axioms
neoplasm.obo: neoplasm_pre.obo
	robot reason -i $< -r elk reduce -o $@

# ----------------------------------------
# DEPRECATED
# ----------------------------------------
disorder.obo:
	blip ontol-query -r ncit -query "subclassRT(ID,'NCIT:C2991')" -to obo > $@.tmp && obo-subtract.pl $@.tmp obsolete.obo retired.obo > $@

# ----------------------------------------
# QUERIES
# ----------------------------------------
%.tsv: %.sparql
	arq --query $< --data neoplasm-src.owl --results TSV > $@

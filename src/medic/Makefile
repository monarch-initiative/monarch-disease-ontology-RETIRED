all: ctd-mesh-no-omim-labels.obo

CTD_diseases.obo:
	wget http://ctdbase.org/reports/CTD_diseases.obo.gz && gzip -d CTD_diseases.obo.gz

ctd.owl: CTD_diseases.obo
	owltools $< -o $@

imports/%_import.owl: seed.owl mirror/%.owl
	owltools --use-catalog $< mirror/$*.owl --merge-support-ontologies  --extract-module -s $(OBO)/$*.owl -c --extract-mingraph  --set-ontology-id $(OBO)/doid/$@ -o $@

CTD_diseases_slim.obo: CTD_diseases.obo
	owltools  CTD_diseases.obo mesh-antislim.obo --merge-support-ontologies --remove-subset mesh_antislim -o -f obo $@

# Mesh plus OMIM bridging axioms
ctd-mesh-no-omim-labels.obo: CTD_diseases_slim.obo
	./transform-ctd.pl $< > $@

combined.obo: ctd-mesh-no-omim-labels.obo ../mondo/omc-minimal.obo
	obo-cat.pl $^ | grep -v ^synonym > $@

align-omim.tsv: combined.obo
	blip-findall -i ignore.pro -u metadata_nlp -i $<   -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),id_idspace(X,'OMIM'),\\+entity_xref(_,X),\\+((subclass(X,Z),id_idspace(Z,'MESH')))" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@
###	blip-findall -i ignore.pro -u metadata_nlp -i $< -i ../mondo/omc-minimal.obo  -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),id_idspace(X,'OMIM'),\\+entity_xref(_,X),\\+((subclass(X,Z),id_idspace(Z,'MESH')))" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

align-omim-etype.tsv: combined.obo
	blip-findall -debug index -consult ../mondo/probmatch.pro -i ignore.pro -u metadata_nlp -i $<  -goal ix_ngenus "entity_ngenus_type(A,G,Type,label),entity_ngenus_type(B,G,Type,label),id_idspace(A,'OMIM')" -select "m(A,B,etype)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

xrefs-omim.obo:  align-omim.tsv align-omim-etype.tsv
	cut -f1-4 $^  | sort -u| tbl2obolinks.pl --swap --rel xref - > $@

mesh-final.obo: ctd-mesh-no-omim-labels.obo xrefs-omim.obo
	obo-merge-tags.pl -t xref $^ > $@

# ----------------------------------------
# MESH SELF-DETECTION
# ----------------------------------------
# See: https://github.com/monarch-initiative/monarch-disease-ontology/issues/81

SELFIGNORE= ignore_selfcheck.pro
#SELFIGNORE= ../mondo/super_ignore.pro

# align mesh with self
align-self.tsv: ctd-mesh-no-omim-labels.obo
	blip-findall -i $(SELFIGNORE) -u metadata_nlp -i $<  -goal index_entity_pair_label_match "entity_pair_label_match_rel/6" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@
.PRECIOUS: align-self.tsv

# filter matches that are due to syns
align-self-by-label.tsv: align-self.tsv
	egrep 'label\t\tlabel'  $< > $@
.PRECIOUS: align-self-by-label.tsv

# Do not use stemmed results (otherwise Meningitis = Meningism)
align-self-strict.tsv: align-self-by-label.tsv
	egrep '\tfalse'  $< | cut -f1-4,11 > $@

cur.pro: curated-distinct.tsv curated-duplicates.tsv
	cut -f1-4 $^ | tbl2p -p cur > $@

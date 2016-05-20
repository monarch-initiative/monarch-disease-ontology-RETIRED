all: mondo.obo mondo.owl
#all: mondo.obo mondo.owl mondo_score2.tsv mondo_score1.tsv mondo_score2.tsv mondo_unclassified.tsv
#all_rest: missing-omc.obo missing-omimps.obo sim-omc.tsv

OMIM_OBO=../omim/omim.obo
OMIA_OBO=../omia/omia.obo
OMIAG_OBO=../omia/omia-generic.obo
ORDO_OBO=../orphanet/orphanet-obostyle.obo
ORDO_SLIM=../orphanet/orphanet-slim.obo
CLUSTERS=../clusters
DOID_OBO=../doid/doid.obo
MESH_TRIM=../medic/mesh-final.obo
DEC_OBO=../medic/ctd-mesh-no-omim-labels.obo
NCIT_OBO=../ncit/ncit_disease.obo
GARD_OBO=../gard/gard.obo

## --
## INITIAL INPUTS: ONTOLOGY
## --
# Union of:
#  - DO
#  - ORDO (is_a version)
#  - disease subset of OMIM
#  - DC
#  - CTD-MESH
#
# this constitutes the initial set of ontologies
set-1.obo: $(DOID_OBO) $(ORDO_SLIM) omc-minimal.obo $(MESH_TRIM) $(DEC_OBO) $(OMIA_OBO) ixrefs-doid-to-omia.obo xrefs-doid-to-ordo.obo xlinks-curated.obo
	owltools $^ --merge-support-ontologies -o -f obo --no-check $@.tmp && egrep -v '^(namespace|property_value):' $@.tmp > $@

foobar:
	grep -H '^id: http' $(DOID_OBO) $(ORDO_SLIM) omc-minimal.obo $(MESH_TRIM) $(DEC_OBO) $(OMIA_OBO) ixrefs-doid-to-omia.obo xrefs-doid-to-ordo.obo xlinks-curated.obo

set-%.owl: set-%.obo
	owltools $< -o $@

## --
## INITIAL INPUTS: PROBABILISTIC EDGES
## --
# translate xrefs to estimates of prior probabilities of equivalence
set-%-ptable.tsv: set-%.obo
	blip-findall -debug index -debug prob -goal nlp_index_all,ix_ngenus -i $<  xref_ptable/6 -consult probmatch.pro -no_pred > $@.tmp && mv $@.tmp $@
.PRECIOUS: set-%-ptable.tsv

set-%-ptable-debug.tsv: set-%.obo
	blip-findall -debug index -debug prob -goal nlp_index_all,ix_ngenus -i $<  -consult probmatch.pro "normalized_xref(A,B),pair_relationship_scores(A,B,S)" -select "x(A,B,S)" -no_pred -label > $@

set-%-amended-ptable.tsv: curated-ptable.tsv set-%-ptable.tsv 
	fix-probs.pl $^ > $@.tmp && mv $@.tmp $@

## --
## kBOOM - MERGE ONTOLOGIES
## --

# lBOOM parameters
# MAX_E := 9  -- failing..?
MAX_E := 9

linked-%.owl: set-%-amended-ptable.tsv set-%.owl
	kboom --experimental  --splitSize 50 --max $(MAX_E) -m linked-$*-rpt.md -j linked-$*-rpt.json -n -o $@ -t $^
.PRECIOUS: linked-%.owl

test-%.owl: set-1-amended-ptable.tsv set-1.owl
	kboom --experimental -c $*  --splitSize 9999 --max $(MAX_E) -m linked-$*-rpt.md -j linked-$*-rpt.json -n -o $@ -t $^

# use pandoc to convert markdown to html
linked-%-rpt.md: linked-%.owl
%-rpt.html: %-rpt.md
	pandoc $*-rpt.md -o $@

# Merging most probable axioms plus original ontologies
PRIORITIES_SYN := -s OMIM 10 -s DOID 9 -s Orphanet 8 -s MESH 7
PRIORITIES_LABEL := -l DOID 10 -l Orphanet 5  -l OMIM 3 -l MESH 1
PRIORITIES_DEF := -l Orphanet 10 -l DOID 5  -l MESH 3 -l OMIM 1

# we do not include omia in set-1, as it's xrefs are potentially problematic
#OTHERS_TO_MERGE := $(OMIA_OBO)
OTHERS_TO_MERGE := 
lmerged-%.owl: set-%.owl linked-%.owl $(OTHERS_TO_MERGE)
	owltools $^ --merge-support-ontologies --reasoner elk --merge-equivalence-sets $(PRIORITIES_SYN) $(PRIORITIES_LABEL) --set-ontology-id $(OBO)/mondo/$@ -o $@
.PRECIOUS: lmerged-%.owl

lmerged-%.obo: lmerged-%.owl
	owltools $< --remove-dangling -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

mondo_pre.obo: lmerged-1.obo
	owltools $< --set-ontology-id $(OBO)/upheno/mondo.owl -o -f obo --no-check $@

mondo.obo: mondo_pre.obo mesh-mega-antislim.obo
	owltools $^ --merge-support-ontologies --remove-subset mesh_antislim --assert-inferred-subclass-axioms --removeRedundant -o -f obo --no-check $@

equiv_axioms.owl: linked-1.owl
	owltools $< --extract-axioms -t EquivalentClasses -o -f ofn $@

mondo.owl: mondo.obo equiv_axioms.owl
	owltools $^ --merge-support-ontologies -o $@.tmp && ./fix-ordo-uris.pl $@.tmp > $@

mondoe.obo: mondo.owl
	owltools $< -o -f obo --no-check $@

mesh-mega-antislim.obo: mondo_pre.obo
	blip-findall -i $< -consult checker.pro write_mesh_antislim > $@

## REPORT

unlikely.md: linked-1-rpt.md
	./unlikely-axiom-report.pl $< | head -200 > $@

## --
## DO
## --
# @Deprecated
disease_nosyn.obo: $(DOID_OBO)
	grep -v ^synonym $< > $@

## --
## OMIM-clusters (maintained by MGI and Monarch)
## --

# TODO: this can all be simplified post moving to kBOOM

# local copy of MGI's file
# todo: add def back later, but watch for multiple def tags
# xrefs to: PS
omimclusters.obo: $(CLUSTERS)/omimclusters.obo $(OMIM_OBO)
	obo-merge-tags.pl  -t synonym -t name -t xref -t def $^ > $@.tmp && obo2obo $@.tmp -o $@

# TODO:
#omiaclusters.obo: $(CLUSTERS)/omiaclusters.obo $(OMIA_OBO)
#	obo-merge-tags.pl  -t synonym -t name -t def $^ > $@.tmp && obo2obo $@.tmp -o $@

# subset that includes only the clusters/groupings
omc.obo: omimclusters.obo
	obo-grep.pl -r 'id: DC' $< > $@.tmp && mv $@.tmp $@

omimclusters_plus_bridge.obo: omimclusters.obo $(CLUSTERS)/omimclusters_bridge_to_doid.obo 
	obo-merge-tags.pl -t is_a -t equivalent_to $^ > $@

# DO-mapped clusters
# Some DCs will be replaced by DOIDs
omc-mapped-to-do.obo: omimclusters_plus_bridge.obo xrefs-doid-to-omc.obo
	obo-map-ids.pl --use-xref-inverse xrefs-doid-to-omc.obo  xrefs-doid-to-omc-edited.obo $< > $@

omim-genes.obo: $(OMIM_OBO)
	blip ontol-query -consult munger.pro -i $< -i ordo.obo -query "omim_gene(ID)" -to obo > $@

# omimclusters with DO dupes carved out (and genes removed too)
# TODO: consider PS
omc-minimal.obo: omc-mapped-to-do.obo omim-genes.obo $(DOID_OBO)
	obo-subtract.pl $< $(DOID_OBO) omim-genes.obo  > $@.tmp && obo-grep.pl --neg -r is_obsolete $@.tmp > $@

## --
## OMIM Phenotypic Series
## --

omim-leaf.obo: $(OMIM_OBO)
	obo-grep.pl --neg -r 'id: OMIM:PS' $< > $@.tmp && grep -v ^owl-ax $@.tmp | grep -v ^is_a > $@

omimps.obo: $(OMIM_OBO)
	obo-grep.pl -r 'id: OMIM:PS' $< > $@.tmp && grep -v ^owl-ax $@.tmp > $@

omimps-min.obo: $(OMIM_OBO)
	grep -v ^def: $< | obo-grep.pl -r 'OMIM:PS' - > $@.tmp && grep -v ^owl-ax $@.tmp > $@

## --
## Textual alignment based on labels/syns
## --
# NOTE: Consider moving this to a different folder.
# For now we primarily use assrted xrefs, and perform additional lexical scoring of these using probmatch

DOID = $(DOID_OBO)
align-doid-to-omim.tsv: omim-leaf.obo
	blip-findall -i ignore.pro -u metadata_nlp -i $< -i $(DOID_OBO) -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

align-doid-to-decipher.tsv: $(CLUSTERS)/decipherclusters.obo
	blip-findall -i super_ignore.pro -u metadata_nlp -i $< -i $(DOID_OBO) -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

align-doid-to-mesh.tsv: mesh.obo
	blip-findall -i super_ignore.pro -u metadata_nlp -i $< -i $(DOID_OBO) -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

align-doid-to-ncit.tsv: $(NCIT_OBO)
	blip-findall -i super_ignore.pro -u metadata_nlp -i $< -i $(DOID_OBO) -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

align-doid-to-omc.tsv: omc.obo
	blip-findall -i super_ignore.pro -u metadata_nlp -i $< -i $(DOID_OBO) -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

align-doid-to-omia.tsv: $(OMIAG_OBO)
	blip-findall -i super_ignore.pro -u metadata_nlp -i $< -i $(DOID_OBO) -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

align-doid-to-omimps.tsv: omimps.obo
	blip-findall -i ignore.pro -u metadata_nlp -i $< -i $(DOID_OBO) -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

align-doid-to-ordo.tsv: ../orphanet/orphanet-phenome-obostyle.obo $(DOID)
	blip-findall -i ignore.pro -i ignore_rare_genetic.pro -u metadata_nlp -i $< -i $(DOID_OBO) -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

align-doid-to-ordo-nosyn.tsv: ordo_nosyn.obo disease_nosyn.obo
	blip-findall -i ignore.pro -u metadata_nlp -i $< -i disease_nosyn.obo -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,false),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@


align-doid-to-hp.tsv: $(DOID)
	blip-findall -i ignore.pro -u metadata_nlp -r HP -i $(DOID_OBO) -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@




## --
## Extract xrefs
## --

xrefs-%.obo: align-%.tsv
	cut -f1-4 $< | sort -u | grep ^DOID | tbl2obolinks.pl --rel xref > $@.tmp && mv $@.tmp $@.tmp && (echo "ontology: mondo/$*" && echo && cat $@.tmp) > $@

ixrefs-%.obo: align-%.tsv
	cut -f1-4 $< | sort -u | grep -v ^DOID | tbl2obolinks.pl --rel xref > $@.tmp && (echo "ontology: mondo/$*" && echo && cat $@.tmp) > $@

isa-%.obo: align-%.tsv
	cut -f1-4 $< | sort -u | grep -v ^DOID | tbl2obolinks.pl --rel is_a > $@.tmp && mv $@.tmp $@

# @Deprecated
mesh.obo: ../medic/CTD_diseases.obo
	perl -npe 's@\s+EXACT\s+@ RELATED @ if m@^synonym@' $< > $@ && add-ontology-tag.pl $@ mesh

## --
## EXPERIMENTAL
## --

gene_disease.tsv:
	golr-fetcher.py -t gene-disease -k -n -m 50000  > $@.tmp && grep ^NCBITaxon:9606 $@.tmp | cut -f2,4 | sort -u > $@

te.out:
	owltools mondo.obo go-min.obo go-group.obo --merge-support-ontologies --load-instances gene_disease.tsv --load-instances gene2term.tsv --all-by-all-enrichment-analysis -m 100 -p 0.0001 DOID:4 GOROOT:0 > $@.tmp && mv $@.tmp $@

# moved to genesets-human-go
#gene2term.tsv

te.tsv: te.out
	./enr2tsv.pl $< > $@

disease2go.tsv:
	blip-findall -i go-min.obo -i mondo.obo  -i te.pro -consult elim_redundant.pro -goal ix -debug index nr/10 -no_pred > $@
.PRECIOUS: disease2go.tsv

disease2go.obo: disease2go.tsv
	cut -f1-4 $< | tbl2obolinks.pl --rel has_pathway - 

sync-report:
	cp set-1.owl linked-1*{md,json,html} set-1-ptable*tsv ~/Dropbox/MonDO-Reports/
	rsync -az target ~/Dropbox/MonDO-Reports/target

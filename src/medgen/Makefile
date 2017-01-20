MEDGEN = medgen-disease-extract.obo

all: fetch $(MEDGEN)

# ----------------------------------------
# ETL
# ----------------------------------------
fetch:
	wget -r -np ftp://ftp.ncbi.nlm.nih.gov/pub/medgen/

uid2cui.tsv:
	./make_uid2cui.pl > $@

# ----------------------------------------
# Hacky conversion to obo
# ----------------------------------------
medgen.obo:
	./medgen2obo.pl > $@.tmp && mv $@.tmp $@

# we only care about diseases for now
medgen-disease-extract.obo: medgen.obo
	owltools $< --extract-subset Disease-or-Syndrome -o -f obo $@


# ----------------------------------------
# Alignment/mapping
# ----------------------------------------
align-medgen.tsv: $(MEDGEN)
	blip-findall -debug index -i ../mondo/super_ignore.pro -u metadata_nlp -i $< -r mondo -goal index_entity_pair_label_match "class(X),id_idspace(X,'UMLS'),entity_pair_label_reciprocal_best_intermatch(X,Y,S)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

xrefs-%.obo:  align-%.tsv
	cut -f1-4 $^  | sort -u| tbl2obolinks.pl --swap --rel xref - > $@

# ----------------------------------------
# Cycles	
# ----------------------------------------

%-cycles.tsv: %.obo
	blip-findall -i $< "subclass_cycle/2" -label -no_pred -use_tabs > $@

# ----------------------------------------
# Mapping reports
# ----------------------------------------

# extract IDs
mg.pro: medgenid_count.txt
	cut -f1 $<  | tbl2p -p mg > $@

# All medgen diseases we can't map
unmapped.tsv:
	blip-findall -i medgen-disease-extract.obo  -i xrefs-medgen.obo -r mondo -i mg.pro "mg(X),\+entity_xref(_,X),class(X)" -select X -label > $@

# Medgen mappings by category
mg_cat.tsv:
	blip-findall -i medgen.obo  -i xrefs-medgen.obo -r mondo -i mg.pro "mg(X),entity_partition(X,S)" -select X-S -no_pred -label > $@

# counts with labels
medgenid_count_labeled.txt: medgenid_count.txt
	blip labelify -i medgen.obo $< > $@

# ----------------------------------------
# Experimental
# ----------------------------------------

# takes too long
mprobs-medgen.tsv: $(MEDGEN)
	blip-findall -debug index -i ../mondo/super_ignore.pro -u metadata_nlp -i $< -r mondo -goal index_entity_pair_label_match "class(B),id_idspace(B,'UMLS'),entity_pair_mprobs(A,B,P1,P2,P3,P0)" -select "entity_pair_mprobs(A,B,P1,P2,P3,P0)" -no_pred > $@.tmp && mv $@.tmp $@

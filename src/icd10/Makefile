CODES = icd10cm_codes_2017.txt

all: icd10.obo

# ----------------------------------------
# CODES FILES FROM CDC
# ----------------------------------------
$(CODES):
	wget ftp://ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10CM/2017/$@


icd10-method-hack.obo: $(CODES)
	icd10-to-obo.pl $<  > $@
#	perl -npe 's@(...)(.*)@ICD10:$$1.$$2@' $< | tbl2obo.pl > $@

# ----------------------------------------
# OWL version from https://dkm.fbk.eu/technologies/icd-10-ontology
# ----------------------------------------
# seems to have only 12437 leaf classes; misses last digit?
# 

ICD10_1.0.zip:
	wget https://dkm.fbk.eu/images/e/e1/$@
icd10-i.owl:  ICD10_1.0.owl
	owltools $< --remove-disjoints -o $@
icd10.owl: icd10-i.owl
	./fix-dkm-owl.pl $< > $@

icd10-method-ext.obo: icd10.owl
	owltools $< -o -f obo $@

# ----------------------------------------
# Merge
# ----------------------------------------
icd10-merged.obo: icd10-method-hack.obo icd10-method-ext.obo
	owltools $^ --merge-support-ontologies -l -o -f obo $@

icd10-links.obo: icd10-merged.obo
	blip-findall -i $< "class(A),atom_concat(B,Rest,A),atom_length(Rest,1),class(B,NB),\+subclassRT(A,B)" -select A-B -label -no_pred | sort -u | tbl2obolinks.pl -k --rel is_a - > $@.tmp && mv $@.tmp $@

icd10.obo: icd10-merged.obo icd10-links.obo
	owltools $^ --merge-support-ontologies -o -f obo $@

# ----------------------------------------
# Alignment
# ----------------------------------------
align-%.tsv: icd10.obo	
	blip-findall -i ../mondo/ignore.pro -u metadata_nlp -i $< -r $* -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

icd10.json: icd10.obo
	owltools $< -o -f json $@

ontobio-align-%.tsv: icd10.json
	ontobio-lexmap.py -l True -u unmapped-icd10-$*.tsv $< $*  > $@.tmp && cut -f2- $@.tmp > $@


# ----------------------------------------
# FUNNY HAHA
# ----------------------------------------
funny1.txt: $(CODES)
	grep 'as the place of occurrence of the external cause' $< > $@
funny2.txt: $(CODES)
	grep 'Portug' $< > $@

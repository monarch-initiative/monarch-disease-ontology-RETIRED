#PATTERNS = hereditary acquired location_top location rare genetic dependence
PATTERNS = hereditary acquired location_top rare genetic dependence

all: all_disease  all_ordo all_ncit all_icd all_snomed

all_disease_ld: $(patsubst %,ld-disease-%.tsv,$(PATTERNS))
all_disease: $(patsubst %,lx-disease-%.tsv,$(PATTERNS))
all_ordo: $(patsubst %,lx-ordo-%.tsv,$(PATTERNS))
all_ncit: $(patsubst %,lx-ncit-%.tsv,$(PATTERNS))
all_icd: $(patsubst %,lx-icd10-%.tsv,$(PATTERNS))
all_snomed: $(patsubst %,lx-snomed_disorder-%.tsv,$(PATTERNS))

all_yaml: $(patsubst %,%.yaml,$(PATTERNS))

# lexical
lx-$(Ont)-$(P).tsv:
	blip-findall -r $(Ont) -goal "load_onts($(P))" -consult helper.pro -u odputil -i disease_patterns.pro "tuple_from_lex($(P),C,V),disease_id(C)" -select C-V -no_pred -use_tabs -label > $@.tmp && mv $@.tmp $@

%.yaml:
	blip-findall -u odputil -i disease_patterns.pro "write_yaml($*)" > $@.tmp && grep -v ^write_yaml $@.tmp > $@

#$(Ont)-$(P)-ld.tsv: $(P).yaml $(Ont).owl
#	dosdp-tools --prefixes=prefixes.yaml --ontology=$(Ont).owl --reasoner=elk --obo-prefixes=true --template=$< --outfile=$@.tmp query && ./util/fix-tsvs.pl $@.tmp > $@

ld-$(Ont)-$(P).csv: $(Ont).obo
	blip-findall -i $(Ont).obo -r uberonp  -u odputil -i disease_patterns.pro -goal "load_onts($(P))" "write_tuple($(P))" -select C-V -no_pred -use_tabs -label > $@.tmp && mv $@.tmp $@

ld-%.tsv: ld-%.csv
	csv2tsv.py $< $@

%.obo: %.owl
	owltools $< --merge-imports-closure --add-obo-shorthand-to-properties -o -f obo --no-check $@

lx-$(Ont)-$(P).owl: lx-$(Ont)-$(P).tsv 
	apply-pattern.py  -P curie_map.yaml -b http://purl.obolibrary.org/obo/ -i $< -p $(P).yaml  > $@.tmp && mv $@.tmp $@

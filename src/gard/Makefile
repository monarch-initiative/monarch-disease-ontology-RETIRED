 ONT=gard
O=$(ONT).obo

all: suggest_new.txt

#$(ONT).obo: $(ONT).txt
#	./gard2obo.pl $< > $@

gard.obo: gard.json
	./gardjson2obo.pl $< > $@

align-gard-to-mondo.tsv: $(O)
	blip-findall -debug index -i ../mondo/super_ignore.pro -u metadata_nlp -i $< -r mondo -goal index_entity_pair_label_match "class(X),id_idspace(X,'GARD'),entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

mprobs-gard.tsv: $(O)
	blip-findall -debug index -i ../mondo/super_ignore.pro -u metadata_nlp -i $< -r mondo -goal "entity_pair_mprobs(A,B,P1,P2,P3,P0),(id_idspace(A,'GARD');id_idspace(B,'GARD'))" -select "entity_pair_mprobs(A,B,P1,P2,P3,P0)" > $@.tmp && mv $@.tmp $@


gard-to-mi-urls.tsv: align-gard-to-mondo.tsv
	align2best.pl $< > $@.tmp && sort -u $@.tmp > $@

map_g2m.pro: align-gard-to-mondo.tsv
	cut -f1,3 $< | tbl2p -p m > $@

gard-xrefs.obo: gard-to-mi-urls.tsv
	perl -npe 's@http.*/@@' $<  | tbl2obolinks.pl --swap --rel xref - > $@.tmp && mv $@.tmp $@


suggest_new.tsv: map_g2m.pro
	blip-findall -i gard.obo -r mondo -i $< -consult compare.pro good_new_xref/2 -label -no_pred > $@.tmp && sort -u $@.tmp > $@

different.tsv: map_g2m.pro
	blip-findall -i gard.obo -r mondo -i $< -consult compare.pro diff_xref/3 -label -no_pred  > $@.tmp && sort -u $@.tmp > $@

consistent.tsv: map_g2m.pro
	blip-findall -i gard.obo -r mondo -i $< -consult compare.pro consistent_xref/3 -label > $@.tmp && mv $@.tmp $@

no_map.tsv: map_g2m.pro
	blip-findall -i gard.obo -r mondo -i $< -consult compare.pro no_map/1 -label > $@.tmp && mv $@.tmp $@


gard.owl: gard.obo
	owltools $< -o $@

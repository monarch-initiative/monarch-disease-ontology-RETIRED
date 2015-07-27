ONT=gard
O=$(ONT).obo

all: suggest_new.txt

$(ONT).obo: $(ONT).txt
	./gard2obo.pl $< > $@

align-gard-to-mondo.tsv: $(O)
	blip-findall -debug index -i ../mondo/super_ignore.pro -u metadata_nlp -i $< -r mondo -goal index_entity_pair_label_match "class(X),id_idspace(X,'GARD'),entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@

map_g2m.pro: align-gard-to-mondo.tsv
	cut -f1,3 $< | tbl2p -p m > $@

suggest_new.txt: map_g2m.pro
	blip-findall -i gard.obo -r mondo -i $< -consult compare.pro good_new_xref/2 -label -no_pred > $@.tmp && sort -u $@.tmp > $@

different.txt: map_g2m.pro
	blip-findall -i gard.obo -r mondo -i $< -consult compare.pro diff_xref/2 -label > $@.tmp && mv $@.tmp $@

consistent.txt: map_g2m.pro
	blip-findall -i gard.obo -r mondo -i $< -consult compare.pro consistent_xref/3 -label > $@.tmp && mv $@.tmp $@

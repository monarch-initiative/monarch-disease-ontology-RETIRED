all: omia.obo omia-generic.obo

mirror-omia.ttl: 
	wget http://data.monarchinitiative.org/ttl/omia.ttl -O $@
.PRECIOUS: omia.ttl

omia.owl: mirror-omia.ttl
	owltools $< --set-ontology-id $(OBO)/doid/$@ -o $@
.PRECIOUS: omia.owl

omia.obo: omia.owl
	owltools $< -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp | grep -v ^property_value | perl -npe 's@xref: OMIM:@relationship: RO:HOM0000001 OMIM:@' | obo-grep.pl --neg -r 'id: http' - | ./fix-omia-names.pl > $@.tmp.obo && robot reduce -i $@.tmp.obo -o $@

# generic only
omia-to-align.obo: omia.obo
	obo-grep.pl -r 'id: OMIA:\d+\n' $< | perl -npe 's@ \(in other animals\)@@'  > $@

## REQUIRED FOR MONDO
## There are no externally supplied mappings for OMIA to grouping classes
align-doid-to-omia.tsv: omia-to-align.obo
	blip-findall -i ../mondo/super_ignore.pro -u metadata_nlp -i $< -i ../doid/doid.obo -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S),class(X),class(Y),\\+disjoint_from(X,Y),\\+disjoint_from(Y,X)" -select "m(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && sort -u $@.tmp > $@


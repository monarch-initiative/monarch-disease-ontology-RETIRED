all: omia.obo omia-generic.obo

mirror-omia.ttl: 
	wget http://data.monarchinitiative.org/ttl/omia.ttl -O $@
.PRECIOUS: omia.ttl

omia.owl: mirror-omia.ttl
	owltools $< --set-ontology-id $(OBO)/doid/$@ -o $@
.PRECIOUS: omia.owl

omia.obo: omia.owl
	owltools $< -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp | grep -v ^property_value | perl -npe 's@xref: OMIM:@relationship: RO:HOM0000001 OMIM:@' | ./fix-omia-names.pl > $@

omia-generic.obo: omia.obo
	obo-grep.pl -r 'id: OMIA:\d+\n' $< > $@

OMIM= ../omim/omim.obo
many_to_one.tsv: omia.obo $(OMIM)
	blip-findall -i $< -i $(OMIM) "many_to_one_xref(X,Y,'OMIM')" -label > $@.tmp && mv $@.tmp $@
many_to_many.tsv: omia.obo $(OMIM)
	blip-findall -i $< -i $(OMIM) "many_to_many_xref(X,Y,'OMIM')" -label > $@.tmp && mv $@.tmp $@
one_to_many.tsv: omia.obo $(OMIM)
	blip-findall -i $< -i $(OMIM) "one_to_many_xref(X,Y,'OMIM')" -label > $@.tmp && mv $@.tmp $@

non_one_to_one.tsv: many_to_one.tsv many_to_many.tsv one_to_many.tsv
	cat $^ > $@

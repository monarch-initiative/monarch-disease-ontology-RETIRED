all: omia.obo

mirror-omia.ttl: 
	wget http://nif-crawler.neuinfo.org/monarch/ttl/omia.ttl -O $@
.PRECIOUS: omia.ttl

omia.owl: mirror-omia.ttl
	owltools $< --set-ontology-id $(OBO)/doid/$@ -o $@
.PRECIOUS: omia.owl

omia.obo: omia.owl
	owltools $< -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp | grep -v ^property_value > $@

OMIM= ../omim/omim.obo
many_to_one.tsv: omia.obo $(OMIM)
	blip-findall -i $< -i $(OMIM) "many_to_one_xref(X,Y,'OMIM')" -label > $@.tmp && mv $@.tmp $@
many_to_many.tsv: omia.obo $(OMIM)
	blip-findall -i $< -i $(OMIM) "many_to_many_xref(X,Y,'OMIM')" -label > $@.tmp && mv $@.tmp $@
one_to_many.tsv: omia.obo $(OMIM)
	blip-findall -i $< -i $(OMIM) "one_to_many_xref(X,Y,'OMIM')" -label > $@.tmp && mv $@.tmp $@

non_one_to_one.tsv: many_to_one.tsv many_to_many.tsv one_to_many.tsv
	cat $^ > $@

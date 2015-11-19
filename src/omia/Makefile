all: omia.obo

mirror-omia.ttl: 
	wget http://nif-crawler.neuinfo.org/monarch/ttl/omia.ttl -O $@
.PRECIOUS: omia.ttl

omia.owl: mirror-omia.ttl
	owltools $< --set-ontology-id $(OBO)/doid/$@ -o $@
.PRECIOUS: omia.owl

omia.obo: omia.owl
	owltools $< -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp | grep -v ^property_value > $@

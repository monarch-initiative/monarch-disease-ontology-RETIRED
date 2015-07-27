all: omim.obo

mirror-omim.ttl: 
	wget http://nif-crawler.neuinfo.org/monarch/ttl/omim.ttl -O $@
.PRECIOUS: omim.ttl

omim.owl: mirror-omim.ttl
	owltools $< --set-ontology-id $(OBO)/doid/$@ -o $@
.PRECIOUS: omim.owl

omim.obo: omim.owl
	owltools $< -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp > $@

all: omim.obo

mirror-omim.ttl: 
	wget http://data.monarchinitiative.org/ttl/omim.ttl -O $@
.PRECIOUS: omim.ttl

omim.owl: mirror-omim.ttl
	owltools $< --set-ontology-id $(OBO)/doid/$@ -o $@
.PRECIOUS: omim.owl

omim.obo: omim.owl blacklist.obo
	owltools $^ --merge-support-ontologies -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp | perl -npe 's@ EXACT @ RELATED @'  | ./hide-defs.pl	 > $@

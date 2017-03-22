all: omim.obo

mirror-omim.ttl: 
	wget http://data.monarchinitiative.org/ttl/omim.ttl -O $@
.PRECIOUS: omim.ttl

omim.owl: mirror-omim.ttl
	owltools $< --set-ontology-id $(OBO)/doid/$@ -o $@
.PRECIOUS: omim.owl

omim.obo: omim.owl blacklist.obo
	owltools $^ --merge-support-ontologies -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp | ./fix-syns.pl  | ./hide-defs.pl > $@

omim-diseases.obo: omim.obo
	obo-grep.pl --neg -r '(equivalent_to|is_a: SO|property_value: RO:0002524)' $< | obo-grep.pl -r 'id: OMIM' - | ./add-parents.pl  > $@.tmp && mv $@.tmp $@

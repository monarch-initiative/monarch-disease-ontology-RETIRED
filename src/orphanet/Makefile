all: orphanet-obostyle.obo

# UPDATE THIS REGULARLY
orphanet-orig.owl:
	wget -nd -P download http://www.orphadata.org/data/ORDO/ordo_orphanet.owl.zip
	unzip  download/ordo_orphanet.owl.zip -d download && rm download/ordo_orphanet*.zip
	mv download/orphadata*.owl download/orphanet-orig-1.owl
	fix-ordo.pl download/orphanet-orig-1.owl > orphanet-orig.owl && rm download/orphanet-orig-1.owl
	rm download/ontology_version_* >/dev/null 2>&1 || true
	touch download/ontology_verion_2

# use OBO tags/vocabulary; keep hierarchy in place
orphanet-obostyle.obo: orphanet-orig.owl part_of.obo
	owltools $^ --merge-support-ontologies --rename-entity $(EFO)/definition $(OBO)/IAO_0000115 --rename-entity $(EFO)/alternative_term $(OIO)hasExactSynonym  --add-obo-shorthand-to-properties -o -f obo $@

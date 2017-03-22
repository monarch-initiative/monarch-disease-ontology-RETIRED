EFO = http://www.ebi.ac.uk/efo
OBO = http://purl.obolibrary.org/obo
OIO = http://www.geneontology.org/formats/oboInOwl\#

all: orphanet-obostyle.obo orphanet-phenome-obostyle.obo

# UPDATE THIS REGULARLY
orphanet-orig.owl:
	wget -nd -P download http://www.orphadata.org/data/ORDO/ordo_orphanet.owl.zip
	unzip  download/ordo_orphanet.owl.zip -d download && rm download/ordo_orphanet*.zip
	mv download/orphadata.owl $@
	touch $@

# use OBO tags/vocabulary; keep hierarchy in place
orphanet-obostyle.obo: orphanet-orig.owl part_of.obo
	owltools $^ --merge-support-ontologies --rename-entity $(EFO)/definition $(OBO)/IAO_0000115 --rename-entity $(EFO)/alternative_term $(OIO)hasExactSynonym  --add-obo-shorthand-to-properties -o -f obo --no-check $@.tmp && ./fix-ordo.pl $@.tmp > $@

# phenome subset only, with partonomy turned to subclass
orphanet-phenome-obostyle.obo: orphanet-obostyle.obo orphanet-subsets.pro
	blip ontol-query -i $< -i orphanet-subsets.pro -query "class(R,phenome),subclassRT(ID,R)" -to obo | perl -npe 's@relationship: part_of@is_a:@' > $@.tmp && mv $@.tmp $@

orphanet-subsets.pro: orphanet-obostyle.obo
	blip-findall -i $< "class(R,phenome),subclass(X,R),subclassT(ID,X)" -select "metadata_db:entity_partition(ID,X)" -write_prolog > $@

slim.tsv: orphanet-phenome-obostyle.obo
	blip-findall -i $< -consult ordo_slimmer.pro in_subset/1 -no_pred > $@

orphanet-slim.obo: orphanet-phenome-obostyle.obo slim.tsv
	owltools $< --extract-ontology-subset -i slim.tsv --set-ontology-id $(OBO)/mondo/$@ -o -f obo --no-check $@

orphanet_xp.obo: orphanet-slim.obo	
	obol  qobol -i $< -r pato -r DOID -tag orphanet -idspace Orphanet -export obo > $@

orphanet-logrel.pro: orphanet-obostyle.obo
	./xref2logic.pl $< > $@

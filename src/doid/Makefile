OBO=http://purl.obolibrary.org/obo
doid.obo: doid_orig.obo
	fix-xrefs.pl $< | ./fix-synonyms.pl > $@
doid_orig.obo:
	wget --no-check-certificate $(OBO)/doid.obo -O $@
.PRECIOUS: doid_orig.obo

%-c.obo: %.obo
	obo-add-comments.pl -t xref ../omim/omim.obo $< > $@


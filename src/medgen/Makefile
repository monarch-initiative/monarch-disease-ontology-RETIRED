
fetch:
	wget -r -np ftp://ftp.ncbi.nlm.nih.gov/pub/medgen/

uid2cui.tsv:
	./make_uid2cui.pl > $@

medgen.obo:
	./medgen2obo.pl > $@.tmp && mv $@.tmp $@

medgen-disease-extract.obo: medgen.obo
	owltools $< --extract-subset Disease-or-Syndrome -o -f obo $@

#medgen-disease-subset.obo: medgen-disease-extract.obo
#	


fetch:
	wget -r -np ftp://ftp.ncbi.nlm.nih.gov/pub/medgen/

uid2cui.tsv:
	./make_uid2cui.pl > $@

medgen.obo:
	./medgen2obo.pl > $@

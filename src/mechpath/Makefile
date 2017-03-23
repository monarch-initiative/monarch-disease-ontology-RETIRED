omim-pathies.tsv: ../omim/omim.obo ./opathy-finder.pl
	./opathy-finder.pl $< | sort -u > $@

pathy-list.csv: omim-pathies.tsv
	cut -f1 $< | sort -u > $@

clingen.pro: rpt_clingen_gene_pheno_6.19.15.txt
	unicode-to-ascii  $< | cut -f1,3  | tbl2p -dequote -p g2p > $@

# now wrotes to genes/
rpt: clingen.pro
	blip-findall -consult matcher.pro -debug index -goal nlp_index_all -u metadata_nlp -r mondoe -i $< -goal wall > $@




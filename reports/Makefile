##SRC = rpt_clingen_gene_pheno_6.19.15.txt
SRC = rpt_to_pheno_wg_072915.txt 

clingen.pro: $(SRC)
	unicode-to-ascii  $< | cut -f1,3  | tbl2p -dequote -p g2p > $@

# now wrotes to genes/
rpt: clingen.pro all_labels.pro
	blip-findall -consult matcher.pro -debug index -goal nlp_index_all -u metadata_nlp -i all_labels.pro -r mondoe -i $< -goal wall > $@

t: clingen.pro all_labels.pro
	blip-findall -debug matcher -consult matcher.pro -debug index -goal ix -u metadata_nlp -i all_labels.pro -r mondoe -i $< -goal t

all_labels.txt:
	blip-findall -r omim -r disease -r ordo -r dmesh class/2 -no_pred > $@

all_labels.pro: all_labels.txt
	tbl2p -p lbl $<  > $@


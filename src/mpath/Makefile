NCIT_OBO=../ncit/ncit_disease.obo

OBO = http://purl.obolibrary.org/obo

all: linked.owl


mpath.obo:
	wget --no-check-certificate $(OBO)/$@ -O $@
.PRECIOUS: mpath.obo



neoplasm.owl:
	wget build-artifacts.berkeleybop.org/ncit-obo/latest/subsets/neoplasm.owl -O $@

neoplasm-fixiri.owl: neoplasm.owl
	perl -npe 's@http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#@http://purl.obolibrary.org/obo/NCIT_@g' $< > $@

neoplasm-all.obo: neoplasm-fixiri.owl
	owltools $< --remove-annotation-assertions -l -r -d -s -o -f obo $@.tmp && mv $@.tmp $@

obsolete.obo:
	blip ontol-query -r ncit -query "inst_sv(ID,'P310','Obsolete_Concept',_)" -to obo > $@
retired.obo:
	blip ontol-query -r ncit -query "inst_sv(ID,'P310','Retired_Concept',_)" -to obo > $@

# Hack until: https://github.com/ontodev/ncit-obo/issues/19
neoplasm.obo: neoplasm-all.obo obsolete.obo retired.obo
	obo-subtract.pl $^ > $@

combined.obo: mpath.obo neoplasm.obo
	owltools $^ --merge-support-ontologies -o -f obo --no-check $@.tmp && egrep -v '^(namespace|property_value):' $@.tmp > $@

ptable.tsv: combined.obo
	blip-findall -debug index -i $< -u metadata_nlp -goal index_entity_pair_label_match entity_pair_mprobs/6 -no_pred > $@

combined.owl: combined.obo
	owltools $< -o $@

linked.owl: ptable.tsv combined.owl
	kboom --experimental  --splitSize 50 --max 4 -m linked-rpt.md -j linked-rpt.json -n -o $@ -t $^

linked-pathology.obo: combined.obo linked.owl
	owltools $^ --merge-support-ontologies -o -f obo $@

unlikely.md: linked-rpt.md
	../mondo/unlikely-axiom-report.pl $< | head -200 > $@

target/%.png: target/%.dot
	dot  -Grankdir=BT -T png -o $@ $<

sync-report:
	cp unlikely.md combined.owl linked*{md,json} ptable*tsv ~/Dropbox/MonDO-Reports/mpath/
	rsync -az target ~/Dropbox/MonDO-Reports/mpath/

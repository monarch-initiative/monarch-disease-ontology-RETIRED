import json
import logging

print('ontology: gard')
print('subsetdef: gard "gard"')

obj = json.load(open('gard.json'))
for d in obj:
    print(f'[Term]')
    print(f"id: GARD:{d['diseaseId']}")
    n = d['diseaseName'].strip()
    n = n.replace("\t","")
    print(f"name: {n}")
    if 'websiteUrl' in d:
        print(f"property_value: http://www.w3.org/2000/01/rdf-schema#seeAlso {d['websiteUrl']}")
    if 'isRare' in d:
        print(f"subset: gard_rare")
        print(f"relationship: has_modifier MONDO:0021136 ! rare")
    for s in d['synonyms']:
        s = s.replace('"','')
        print(f"synonym: \"{s}\" RELATED []")
    for x in d['identifiers']:
        prefix = x['identifierType'].strip()
        if prefix == 'ORPHANET':
            prefix = 'Orphanet'
        if prefix == 'NCI Thesaurus':
            prefix = 'NCIT'
        if prefix == 'SNOMED CT':
            prefix = 'SCTID'
        if prefix == 'ICD 10':
            prefix = 'ICD10'
        if prefix == 'ICD 9':
            prefix = 'ICD9'
        localId = x['identifierId'].strip()
        if ' ' in localId:
            logging.warn(f'BadID: {x}')
        else:
            print(f"xref: {prefix}:{localId}")
    print()
    

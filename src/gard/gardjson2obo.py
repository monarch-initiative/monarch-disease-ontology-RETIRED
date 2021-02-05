import json
obj = json.load(open('gard.json'))
for d in obj:
    print(f'[Term]')
    print(f"id: GARD:{d['diseaseId']}")
    print(f"name: {d['diseaseName']}")
    if 'websiteUrl' in d:
        print(f"property_value: http://www.w3.org/2000/01/rdf-schema#seeAlso {d['websiteUrl']}")
    if 'isRare' in d:
        print(f"subset: gard_rare")
        print(f"relationship: has_modifier MONDO:0021136 ! rare")
    for s in d['synonyms']:
        print(f"synonym: \"{s}\" RELATED []")
    for x in d['identifiers']:
        prefix = x['identifierType']
        if prefix == 'ORPHANET':
            prefix = 'Orphanet'
        localId = x['identifierId']
        print(f"xref: {prefix}:{localId}")
    print()
    

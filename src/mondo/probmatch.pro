:- use_module(bio(metadata_nlp)).
:- use_module(bio(index_util)).

ix_ngenus :-
        materialize_index(entity_nlabel_scope_stemmed(+,-,-,-)),
        materialize_index(entity_ngenus_type(+,+,-,-)).

entity_synonym_scopeI(E,N,label) :-
        entity_label(E,N).
entity_synonym_scopeI(E,N,label_or_exact) :-
        entity_label(E,N).
entity_synonym_scopeI(E,N,label_or_exact) :-
        entity_synonym_scope(E,N,exact).
entity_synonym_scopeI(E,N,Scope) :-
        entity_synonym_scope(E,N,Scope).
entity_synonym_scopeI(E,N,inexact) :-
        entity_synonym_scope(E,N,related).
entity_synonym_scopeI(E,N,inexact) :-
        entity_synonym_scope(E,N,broad).
entity_synonym_scopeI(E,N,inexact) :-
        entity_synonym_scope(E,N,narrow).

%% entity_ngenus_type(E,G,T,Scope)
%
% as entity_ngenus_type_1/4, but include type syn (e.g. III->3)
entity_ngenus_type(E,G,T,Scope) :-
        entity_ngenus_type_1(E,G,T,Scope).
entity_ngenus_type(E,G,T,Scope) :-
        entity_ngenus_type_1(E,G,T1,Scope),
        type_token_syn(T1,T).


% e.g. Foo type 1
% uses tokenizer
entity_ngenus_type_1(E,G,T,Scope) :-
        entity_synonym_scopeI(E,N,Scope),
        tokenize_atom_wrap(N,TL),
        maplist(downcase_atom,TL,TL2),
        tokens_ngenus_type(TL2,G,T),
        T\=''.

% Foo, bar, baz type
entity_ngenus_type_1(E,G,T,Scope) :-
        entity_synonym_scopeI(E,N,Scope),
        % e.g. Primary dystonia, DYT13 type
        concat_atom(TL,', ',N),
        maplist(downcase_atom,TL,TL2),
        reverse(TL2,[Last|TLR]),
        atom_concat(T,' type',Last),
        concat_atom(TLR,', ',GenusTerm),
        term_nlabel_stemmed(GenusTerm,G,true),
        T\=''.


% note that '2A' is tokenized as [2,a]

% type 1 Foo
tokens_ngenus_type([type|Toks],G,T) :-
        consume_type(Toks,T,Rest),
        concat_atom(Rest,' ',RestTerm),
        term_nlabel_stemmed(RestTerm,G,true).

% Foo type 1
% Foo type 1 A
% Foo type 1 A (Bar)
tokens_ngenus_type(Toks,G,T) :-
        append(Start,[type|TypeToks],Toks),
        concat_atom(Start,' ',StartTerm),
        concat_atom(TypeToks,T),
        term_nlabel_stemmed(StartTerm,G,true).
tokens_ngenus_type(Toks,G,T) :-
        append(Start,[complementation,group|TypeToks],Toks),
        concat_atom(Start,' ',StartTerm),
        concat_atom(TypeToks,T),
        term_nlabel_stemmed(StartTerm,G,true).

% Foo 1
tokens_ngenus_type(Toks,G,T) :-
        append(Start,TypeToks,Toks),
        consume_type(TypeToks,T,[]),
        T\='',
        concat_atom(Start,' ',StartTerm),
        term_nlabel_stemmed(StartTerm,G,true).


consume_type(Toks,Type,Rest) :-
        consume_type_1(Toks,TypeToks,Rest),
        concat_atom(TypeToks,Type).

consume_type_1([T|L],[T|L2],Rest) :-
        is_type_token(T),
        !,
        consume_type_1(L,L2,Rest).
consume_type_1(L,[],L) :- !.


is_type_token(T) :- atom_number(T,_).
is_type_token(T) :- atom_length(T,1).
is_type_token('i').
is_type_token('ii').
is_type_token('iii').
is_type_token('iv').
is_type_token('v').
is_type_token('vi').
is_type_token('vii').
is_type_token('viii').
is_type_token('ix').
is_type_token('x').
is_type_token('xi').
is_type_token('xii').




is_left_sub_atom_of(A,B) :-
        atom_concat(A,Rest,B),
        Rest\=''.

not_broad_or_narrow(Sc) :-
        Sc\=broad,
        Sc\=narrow,
        !.
label_or_exact(label) :- !.
label_or_exact(exact) :- !.




%% ========================================
%% Foo-type-N Matches
%% ========================================

% Foo-type-N, label match
pair_relationship_scores_typematch(A,B,m(etype,0,0,200,0)) :-
        entity_ngenus_type(A,G,Type,label),
        entity_ngenus_type(B,G,Type,label),
        !.
% Foo-type-N, label/exact match
pair_relationship_scores_typematch(A,B,m(etype,0,0,150,0)) :-
        entity_ngenus_type(A,G,Type,label_or_exact),
        entity_ngenus_type(B,G,Type,label_or_exact),
        !.

% Foo-type-N < Foo-type-NX, label/exact match
% Note, this is fallible, e.g. parenthetical qualifiers
pair_relationship_scores_typematch(A,B,m(etype,0,100,0,0)) :-
        entity_ngenus_type(A,G,TypeA,label_or_exact),
        entity_ngenus_type(B,G,TypeB,label_or_exact),
        is_left_sub_atom_of(TypeA,TypeB),
        !.
% Foo-type-NX > Foo-type-N, label/exact match
pair_relationship_scores_typematch(A,B,m(etype,100,0,0,0)) :-
        entity_ngenus_type(A,G,TypeA,label_or_exact),
        entity_ngenus_type(B,G,TypeB,label_or_exact),
        is_left_sub_atom_of(TypeB,TypeA),
        !.

% Foo-type-N, label/exact/related match
% note non-exacts can be very
% unreliable; consider MESH, where MESH:D010013 ! Osteogenesis
% Imperfecta has "type 1" as a related syn
pair_relationship_scores_typematch(A,B,m(etype,0,0,20,0)) :-
        entity_ngenus_type(A,G,Type,Sc1),
        not_broad_or_narrow(Sc1),
        entity_ngenus_type(B,G,Type,Sc2),
        not_broad_or_narrow(Sc2),
        !.
pair_relationship_scores_typematch(A,B,m(etype,0,0,0,500)) :-
        entity_ngenus_type(A,G,Type1,label),
        entity_ngenus_type(B,G,Type2,label),
        atom_number(Type1,Num1),
        atom_number(Type2,Num2),
        Num1\=Num2,
        !.

% this is scored very weakly, as related synonyms can be v misleading
pair_relationship_scores_typematch(A,B,m(etype,1,2,1,0)) :-
        entity_ngenus_type(A,G,TypeA,Sc1),
        not_broad_or_narrow(Sc1),
        entity_ngenus_type(B,G,TypeB,Sc2),
        not_broad_or_narrow(Sc2),
        is_left_sub_atom_of(TypeA,TypeB),
        !.
% Foo-type-NX > Foo-type-N, label match
pair_relationship_scores_typematch(A,B,m(etype,2,1,1,0)) :-
        entity_ngenus_type(A,G,TypeA,Sc1),
        not_broad_or_narrow(Sc1),
        entity_ngenus_type(B,G,TypeB,Sc2),
        not_broad_or_narrow(Sc2),
        is_left_sub_atom_of(TypeB,TypeA),
        !.

%% ========================================
%% basic lexical matches
%% ========================================

% identical labels
pair_relationship_scores_lexical(A,B,m(lexical,5,5,30,0)) :-
        class(A,NA),
        class(B,NB),
        downcase_atom(NA,X),
        downcase_atom(NB,X),
        !.
% identical labels/exact syns
pair_relationship_scores_lexical(A,B,m(lexical,5,5,20,0)) :-
        entity_label_or_exact_synonym(A,NA),
        entity_label_or_exact_synonym(B,NB),
        term_nlabel_stemmed(NA,X,false),
        term_nlabel_stemmed(NB,X,false),
        !.
pair_relationship_scores_lexical(A,B,m(lexical,5,5,15,0)) :-
        entity_label_or_exact_synonym(A,NA),
        entity_label_or_exact_synonym(B,NB),
        term_nlabel_stemmed(NA,X,_),
        term_nlabel_stemmed(NB,X,_),
        !.
% A>B if same synonym and B is NARROW
pair_relationship_scores_lexical(A,B,m(lexical,0,30,0,1)) :-
        entity_nlabel_scope_stemmed(A,N,Scope1,_),
        label_or_exact(Scope1),
        entity_nlabel_scope_stemmed(B,N,narrow,_),
        !.
% A<B if same synonym and B is BROAD
pair_relationship_scores_lexical(A,B,m(lexical,30,0,0,1)) :-
        entity_nlabel_scope_stemmed(A,N,Scope1,_),
        label_or_exact(Scope1),
        entity_nlabel_scope_stemmed(B,N,broad,_),
        !.
% substrings
pair_relationship_scores_lexical(A,B,m(lexical,21,1,2,1)) :-
        entity_label_or_exact_synonym(A,NA),
        entity_label_or_exact_synonym(B,NB),
        sub_atom(NA,_,_,_,NB),  % NB is a substring of NA, and thus a superclass of NA
        !.
pair_relationship_scores_lexical(A,B,m(lexical,1,21,2,1)) :-
        entity_label_or_exact_synonym(A,NA),
        entity_label_or_exact_synonym(B,NB),
        sub_atom(NB,_,_,_,NA),  % NA is a substring of NB, and thus a superclass of NB
        !.

% match, but where at least one scope is unreliable
pair_relationship_scores_lexical(A,B,m(lexical,2,2,5,1)) :-
        entity_nlabel_scope_stemmed(A,N,_,_),
        entity_nlabel_scope_stemmed(B,N,_,_),
        !.

% substrings; non-exact syn; weak score as relateds are unreliable
pair_relationship_scores_lexical(A,B,m(lexical,4,1,2,1)) :-
        entity_label_scope(A,NA,SA),
        entity_label_scope(B,NB,SB),
        not_broad_or_narrow(SA),
        not_broad_or_narrow(SB),
        sub_atom(NA,_,_,_,NB),  % NB is a substring of NA, and thus a superclass of NA
        !.
pair_relationship_scores_lexical(A,B,m(lexical,1,4,2,1)) :-
        entity_label_scope(A,NA,SA),
        entity_label_scope(B,NB,SB),
        not_broad_or_narrow(SA),
        not_broad_or_narrow(SB),
        sub_atom(NB,_,_,_,NA),  % NA is a substring of NB, and thus a superclass of NB
        !.
% lexical match weighted by scope. S3 (=) is double either < or >
pair_relationship_scores_lexical(A,B,m(lexical,S1,S1,S3,1)) :-
        entity_nlabel_scope_stemmed(A,N,SA,St),
        entity_nlabel_scope_stemmed(B,N,SB,St),
        scope_pair_score(SA,SB,St,S3),
        S1 is S3/2,
        !.

% even if no lexical match can be found
% we assume a default of equivalence
% (essentially trusting the curator who supplied the xref)
% EXAMPLE:  Hallux Varus and Preaxial Polysyndactyly 
% COUNTER:, e.g. OMIM PCDH15 = orphanet protocadherin-related 15
pair_relationship_scores_lexical(_,_,m(lexical,2,2,3,1)) :- !.

%% scope_pair_score(+ScopeA,+ScopeB,+IsStemmed,?Score) is det
scope_pair_score(label,label,false,25) :- !.
scope_pair_score(exact,exact,false,20) :- !.
scope_pair_score(label,exact,false,20) :- !.
scope_pair_score(exact,label,false,20) :- !.
scope_pair_score(_,_,false,10) :- !.
scope_pair_score(label,label,true,15) :- !.
scope_pair_score(exact,exact,true,12) :- !.
scope_pair_score(label,exact,true,12) :- !.
scope_pair_score(exact,label,true,12) :- !.
scope_pair_score(_,_,true,2) :- !.

%% ========================================
%% scoring based on xref counts
%% ========================================
/*
pair_relationship_scores_xref(_A,B,m(xref,5,5,5,2)) :-
        id_idspace(B,BS),
        many_to_many_xref(_,B,BS),
        !.
pair_relationship_scores_xref(A,_B,m(xref,5,5,5,2)) :-
        id_idspace(A,AS),
        many_to_many_xref(A,_,AS),
        !.
*/

% in general, ontologies have fewer parents than children, so
% we can assume that 1:M indicates child-parent;
% an exception is Orphanet, where the same OMIM can be under multiple different Orphanets
% (e.g.  OMIM:278150  under Woolly hair & Hypotrichosis simplex)
pair_relationship_scores_xref1(A,B,m(xrefSub,2,4,2,0)) :-
        id_idspace(B,BS),
        BS \= 'Orphanet',
        entity_xrefS(A,B),
        entity_xrefS(A,B2),
        B\=B2,
        id_idspace(B2,BS),
        !.
pair_relationship_scores_xref2(A,B,m(xrefSup,4,2,2,0)) :-
        id_idspace(A,AS),
        AS \= 'Orphanet',
        entity_xrefS(A,B),
        entity_xrefS(A2,B),
        A\=A2,
        id_idspace(A2,AS),
        !.
pair_relationship_scores_xref3(A,B,m(xrefMesh,2,2,3,1)) :-
        % xrefs to mesh are assumed to be more likely to be equivalent
        % rationale: mesh is roughly the same granularity as ontologies that make xrefs
        (   id_idspace(A,'MESH');
            id_idspace(B,'MESH')),
        \+ id_idspace(A,'OMIM'),
        \+ id_idspace(B,'OMIM'),
        !.

% TODO
% having multiple OMIM xrefs decreases chance these are equivalent or superclass
pair_relationship_scores_xref4(A,B,m(xrefCard,0,ScoreSub,0,1)) :-
        % TODO - assume A<B, e,g, A=DOID:nnn
        id_idspace(B,'OMIM'),
        aggregate(count,Z,entity_xref_idspace(A,Z,'OMIM'),Num),
        Num>1,
        ScoreSub is floor((1 - (0.9 ** Num)) * 100),
        !.

pair_relationship_scores_xref(A,B,S) :- pair_relationship_scores_xref1(A,B,S).
pair_relationship_scores_xref(A,B,S) :- pair_relationship_scores_xref2(A,B,S).
pair_relationship_scores_xref(A,B,S) :- pair_relationship_scores_xref3(A,B,S).
pair_relationship_scores_xref(A,B,S) :- pair_relationship_scores_xref4(A,B,S).


/*
pair_relationship_scores_xref(A,B,m(xref,20,5,5,0)) :-
        id_idspace(A,AS),
        one_to_many_xref(_,B,AS), % A likely to be subclass of B
        true.
*/

%% ========================================
%% scoring based on prior knowledge
%% ========================================
% See: https://github.com/monarch-initiative/monarch-disease-ontology/issues/139
% ordo assignments may not always be reliable
pair_relationship_scores_prior(A,B,m(prior,1,1,25,1)) :-
        logrel_symm(A,B,e),
        !.
pair_relationship_scores_prior(A,B,m(prior,1,75,1,1)) :-
        logrel_symm(A,B,btnt),
        !.
pair_relationship_scores_prior(A,B,m(prior,75,1,1,1)) :-
        logrel_symm(A,B,ntbt),
        !.

logrel_symm(A,B,T) :- logrel(A,B,T).
logrel_symm(A,B,e) :- logrel(B,A,e).
logrel_symm(A,B,btnt) :- logrel(B,A,ntbt).
logrel_symm(A,B,ntbt) :- logrel(B,A,btnt).

/*

IMPORTANT NOTE:
logrel(Ordo,Omim,Type) is loaded from the ordo obo file

not clear what the direction of btnt vs ntbt is

$ grep -c btnt z
3549
  
here, the obvious interpretation is consistent with the facts:
  
Orphanet:91378 ! Hereditary angioedema  OMIM:106100 ! Angioedema, Hereditary, Type 1    btnt
Orphanet:91378 ! Hereditary angioedema  OMIM:610618 ! Angioedema, Hereditary, Type 3    btnt
  
Orphanet:93387 ! Brachydactyly type E   OMIM:113300 ! Brachydactyly, Type E1    e
Orphanet:93387 ! Brachydactyly type E   OMIM:613382 ! Brachydactyly, Type E2    btnt

Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:115700 ! Cataract 4, Multiple Types        btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:116100 ! Cataract 20, Multiple Types       btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:116200 ! Cataract 1, Multiple Types        btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:116600 ! Cataract 6, Multiple Types        btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:116700 ! Cataract 13 With Adult I Phenotype        btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:116800 ! Cataract 5, Multiple Types        btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:600881 ! Cataract 10, Multiple Types       btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:601547 ! Cataract 3, Multiple Types        btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:601885 ! Cataract 14, Multiple Types       btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:604219 ! Cataract 9, Multiple Types        btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:604307 ! Cataract 2, Multiple Types        btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:605387 ! Cataract 31, Multiple Types       btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:609741 ! Cataract 22, Multiple Types       btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:610202 ! Cataract 21, Multiple Types       btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:610623 ! Cataract 11, Multiple Types       btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:611544 ! Cataract 17, Multiple Types       btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:613763 ! Cataract 16, Multiple Types       btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:615188 ! Cataract 39, Multiple Types       btnt
Orphanet:91492 ! Early-onset non-syndromic cataract     OMIM:615274 ! Cataract 15, Multiple Types       btnt

and similarly, from ntbt, we assume the orphanet is the broader, which is consistent:
  
Orphanet:93612 ! Cystinuria type A      OMIM:220100 ! Cystinuria        ntbt
Orphanet:93613 ! Cystinuria type B      OMIM:220100 ! Cystinuria        ntbt

  
blip-findall  -i orphanet-logrel.pro -r ordo -r omim "logrel(A,B,ntbt),subclass(A,T),id_idspace(B,'OMIM')" -select T -label | count-occ.pl | mysort -k1 -n
1       Orphanet:231692 ! Isolated growth hormone deficiency type III
1       Orphanet:98995 ! Early-onset zonular cataract
1       Orphanet:377792 ! clinical syndrome
1       Orphanet:98992 ! Early-onset partial cataract
2       Orphanet:377794 ! group of disorders
2       Orphanet:182067 ! Glial tumor
4       Orphanet:166081 ! Von Willebrand disease type 2
6       Orphanet:377797 ! histopathological subtype
15      Orphanet:377795 ! etiological subtype
27      Orphanet:377791 ! morphological anomaly
50      Orphanet:377789 ! malformation syndrome
77      Orphanet:377796 ! clinical subtype
231     Orphanet:377788 ! disease

  
  */


%% ========================================
%% scoring based on ontology structure
%% ========================================
pair_relationship_scores_ont(_,B,m(ont,1,95,1,1)) :-
        id_idspace(B,'OMIA'),  %
        !.
pair_relationship_scores_ont(A,B,m(ont,100,0,0,1)) :-
        entity_partition(B,'Orphanet:377794'), % group of disorders
        id_idspace(A,'OMIM'),
        !.
pair_relationship_scores_ont(A,B,m(ont,10,10,20,1)) :-
        entity_partition(B,'Orphanet:377788'), % disease
        id_idspace(A,'OMIM'),
        !.
pair_relationship_scores_ont(A,B,m(ont,1,20,1,1)) :-
        \+ \+ subclass(_,A),          % has a subclass - not a leaf
        id_idspace(B,'OMIM'),
        !.
pair_relationship_scores_ont(A,B,m(ont,20,1,1,1)) :-
        \+ \+ subclass(_,B),          % has a subclass - not a leaf
        id_idspace(A,'OMIM'),
        !.
pair_relationship_scores_ont(A,B,m(ont,1,2,10,1)) :-
        id_idspace(A,'DOID'),   % is in DO and
        \+ subclass(_,A),       % is a leaf
        id_idspace(B,'OMIM'),
        !.
pair_relationship_scores_ont(A,B,m(ont,0,8,4,1)) :-
        id_idspace(A,'DOID'),   % is in DO and
        id_idspace(B,'Orphanet'), % Orphanet
        class(B,BN),
        atom_concat('Rare ',_,BN),   % Orphanet name is Rare X
        !.

%% ========================================
%% scoring based on shared xref
%% ========================================
pair_relationship_scores_shared(A,B,M) :-
        shared_xref_card(A,B,_,S,C),
        downcase_atom(S,S2),
        shared_scores(S2,C,M),
        !.

shared_scores(umls,1-1-1,m(umls,2,2,20,0)) :- !.
shared_scores(umls,_-1-1,m(umls,2,2,10,1)) :- !.
shared_scores(umls,_-_-1,m(umls,1,2,1,1)) :- !.
shared_scores(umls,_-1-_,m(umls,2,1,1,1)) :- !.
shared_scores(umls,_-_-_,m(umls,1,1,1,1)) :- !.

%% ========================================
%% scoring based on probabilstic axiomatization
%% ========================================
pair_relationship_scores_paxiom(A,B,m(hered,1,1,1,15)) :-
        class(A,AN),
        id_idspace(B,'OMIM'),
        % non-hereditary class should not be linked to OMIM
        downcase_atom(AN,AN2),
        hered(T,false),
        sub_atom(AN2,_,_,_,T),
        class(B,BN),
        downcase_atom(BN,BN2),
        % we make an exception for the small number of cases in omim
        % where there are idiopathic
        \+ sub_atom(BN2,_,_,_,T),
        !.

hered(idiopathic,false).
hered(sporadic,false).
hered('non-hereditary',false).

hered(hereditary,true).
hered(familial,true).
hered(genetic,true).


%% ========================================
%% score aggregation
%% ========================================

pair_relationship_scores(A,B,ST) :-
        %% logrel
        pair_relationship_scores_prior(A,B,ST).

pair_relationship_scores(A,B,ST) :-
        %% Foo-type-N matches
        pair_relationship_scores_typematch(A,B,ST).

pair_relationship_scores(A,B,ST) :-
        %% basic lexical
        pair_relationship_scores_lexical(A,B,ST).

pair_relationship_scores(A,B,ST) :-
        %% xref cardinality
        pair_relationship_scores_xref(A,B,ST).

pair_relationship_scores(A,B,ST) :-
        %% ontology
        pair_relationship_scores_ont(A,B,ST).

pair_relationship_scores(A,B,ST) :-
        %% shared
        pair_relationship_scores_shared(A,B,ST).

pair_relationship_scores(A,B,ST) :-
        %% prob axiom
        pair_relationship_scores_paxiom(A,B,ST).




% calculates probabilities by assigning a score to each of the 3
% relationship categories. The final probabilities are ratios
% of each score to the sum of scores
ptable(A,B,P1,P2,P3,P0) :-
        setof(T-S1-S2-S3-Sn,pair_relationship_scores(A,B,m(T,S1,S2,S3,Sn)),L),
        aggregate(sum(S1),T^S2^S3^Sn^member(T-S1-S2-S3-Sn,L),TotalSubClass),
        aggregate(sum(S2),T^S1^S3^Sn^member(T-S1-S2-S3-Sn,L),TotalSuperClass),
        aggregate(sum(S3),T^S1^S2^Sn^member(T-S1-S2-S3-Sn,L),TotalEquiv),
        aggregate(sum(Sn),T^S1^S2^S3^member(T-S1-S2-S3-Sn,L),TotalNull),
        Sum is TotalEquiv + TotalSubClass + TotalSuperClass + TotalNull,
        P1 is TotalSubClass / Sum,
        P2 is TotalSuperClass / Sum,
        P3 is TotalEquiv / Sum,
        P0 is TotalNull / Sum.

% ----------------------------------------
% MAIN CALL
% ----------------------------------------


%% xref_ptable(?A,?B,?P1,?P2,?P3,?P0)
%
% given any asserted xref between A and B, calculate the probabilities 
% of the relationship between A and B being (SubClassOf, SuperClassOf, EquivalentTo, Sibling)
xref_ptable(A,B,P1,P2,P3,P0) :-
        normalized_xref(A,B),
        \+ entity_obsolete(A,_),
        \+ entity_obsolete(B,_),
        debug(prob,'testing: ~w ~w',[A,B]),
        ptable(A,B,P1,P2,P3,P0).

% symmetric xref, normalized so that A alphabeticallly before B
entity_xrefS(A,B) :- entity_xrefN(A,B), A@<B.
entity_xrefS(A,B) :- entity_xrefN(B,A), A@<B.

entity_xrefS(A,B) :- shared_xref_card_umls(A,B), A@<B.

shared_xref_card_umls(A,B) :-
        shared_xref_card(A,B,_,'UMLS',_),
        id_idspace(A,SA),
        id_idspace(B,SB),
        SA\=SB.


% we restict to named classes; this prevents:
%  - OMIM genes from resurfacing
%  - obsoletes
entity_xrefN(A,B) :- entity_xref(A,B),class(A),class(B). 

% A@<B
normalized_xref(A,B) :-
        setof(A-B,entity_xrefS(A,B),L),
        member(A-B,L).


type_token_syn('i','1').
type_token_syn('ii','2').
type_token_syn('iii','3').
type_token_syn('iv','4').
type_token_syn('v','5').
type_token_syn('vi','6').
type_token_syn('vii','7').
type_token_syn('viii','8').
type_token_syn('ix','9').
type_token_syn('x','10').
type_token_syn('xi','11').
type_token_syn('xii','12').


/*

  TODO: decide on pattern for e.g. DC_0000634 Autoimmune Thyroid Disease, Susceptibility to <-> DOID_7188 autoimmune thyroiditis

*/

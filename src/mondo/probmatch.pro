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
pair_relationship_scores_typematch(A,B,m(etype,0,0,50,0)) :-
        entity_ngenus_type(A,G,Type,Sc1),
        not_broad_or_narrow(Sc1),
        entity_ngenus_type(B,G,Type,Sc2),
        not_broad_or_narrow(Sc2),
        !.

pair_relationship_scores_typematch(A,B,m(etype,0,25,0,0)) :-
        entity_ngenus_type(A,G,TypeA,Sc1),
        not_broad_or_narrow(Sc1),
        entity_ngenus_type(B,G,TypeB,Sc2),
        not_broad_or_narrow(Sc2),
        is_left_sub_atom_of(TypeA,TypeB),
        !.
% Foo-type-NX > Foo-type-N, label match
pair_relationship_scores_typematch(A,B,m(etype,25,0,0,0)) :-
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
pair_relationship_scores_lexical(A,B,m(lexical,10,10,30,0)) :-
        class(A,NA),
        class(B,NB),
        downcase_atom(NA,X),
        downcase_atom(NB,X),
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
% lexical match weighted by scope. S3 (=) is double either < or >
pair_relationship_scores_lexical(A,B,m(lexical,S1,S1,S3,1)) :-
        entity_nlabel_scope_stemmed(A,N,SA,St),
        entity_nlabel_scope_stemmed(B,N,SB,St),
        scope_pair_score(SA,SB,St,S3),
        S1 is S3/2,
        !.
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
pair_relationship_scores_xref1(A,B,m(xrefSub,5,20,5,0)) :-
        id_idspace(B,BS),
        BS \= 'Orphanet',
        entity_xrefS(A,B),
        entity_xrefS(A,B2),
        B\=B2,
        id_idspace(B2,BS),
        !.
pair_relationship_scores_xref2(A,B,m(xrefSup,20,5,5,0)) :-
        id_idspace(A,AS),
        AS \= 'Orphanet',
        entity_xrefS(A,B),
        entity_xrefS(A2,B),
        A\=A2,
        id_idspace(A2,AS),
        !.
pair_relationship_scores_xref3(A,B,m(xrefMesh,2,2,5,1)) :-
        % xrefs to mesh are assumed to be more likely to be equivalent
        % rationale: mesh is roughly the same granularity as ontologies that make xrefs
        (   id_idspace(A,'MESH');
            id_idspace(B,'MESH')),
        \+ id_idspace(A,'OMIM'),
        \+ id_idspace(B,'OMIM'),
        !.

pair_relationship_scores_xref(A,B,S) :- pair_relationship_scores_xref1(A,B,S).
pair_relationship_scores_xref(A,B,S) :- pair_relationship_scores_xref2(A,B,S).
pair_relationship_scores_xref(A,B,S) :- pair_relationship_scores_xref3(A,B,S).


/*
pair_relationship_scores_xref(A,B,m(xref,20,5,5,0)) :-
        id_idspace(A,AS),
        one_to_many_xref(_,B,AS), % A likely to be subclass of B
        true.
*/

%% ========================================
%% scoring based on ontology structure
%% ========================================
pair_relationship_scores_ont(A,B,m(ont,100,0,0,1)) :-
        subset(B,'Orphanet:377794'), % group of disorders
        id_idspace(A,'OMIM'),
        !.
pair_relationship_scores_ont(A,B,m(ont,10,10,20,1)) :-
        subset(B,'Orphanet:377788'), % disease
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
pair_relationship_scores_ont(A,B,m(ont,1,1,10,1)) :-
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
%% score aggregation
%% ========================================

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



% calculates probabilities by assigning a score to each of the 3
% relationship categories. The final probabilities are ratios
% of each score to the sum of scores
ptable(A,B,P1,P2,P3,P0) :-
        setof(S1-S2-S3-Sn,MatchType^pair_relationship_scores(A,B,m(MatchType,S1,S2,S3,Sn)),L),
        aggregate(sum(S1),S2^S3^Sn^member(S1-S2-S3-Sn,L),TotalSubClass),
        aggregate(sum(S2),S1^S3^Sn^member(S1-S2-S3-Sn,L),TotalSuperClass),
        aggregate(sum(S3),S1^S2^Sn^member(S1-S2-S3-Sn,L),TotalEquiv),
        aggregate(sum(Sn),S1^S2^S3^member(S1-S2-S3-Sn,L),TotalNull),
        Sum is TotalEquiv + TotalSubClass + TotalSuperClass + TotalNull,
        P1 is TotalSubClass / Sum,
        P2 is TotalSuperClass / Sum,
        P3 is TotalEquiv / Sum,
        P0 is TotalNull / Sum.


%% xref_ptable(?A,?B,?P1,?P2,?P3,?P0)
%
% given any asserted xref between A and B, calculate the probabilities 
% of the relationship between A and B being (SubClassOf, SuperClassOf, EquivalentTo, Sibling)
xref_ptable(A,B,P1,P2,P3,P0) :-
        normalized_xref(A,B),
        debug(prob,'testing: ~w ~w',[A,B]),
        ptable(A,B,P1,P2,P3,P0).

entity_xrefS(A,B) :- entity_xrefN(A,B), A@<B.
entity_xrefS(A,B) :- entity_xrefN(B,A), A@<B.
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

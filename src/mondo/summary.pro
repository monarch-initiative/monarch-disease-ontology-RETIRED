
solutions(X,Goal,Xs):-
        (   setof(X,Goal^Goal,Xs)
        ->  true
        ;   Xs=[]).

entity_xref_from(Grp,D,S) :-
        entity_xref(Grp,D),
        id_idspace(Grp,S).

d2group(D,Grp,dc) :-
        subclass(D,Grp),
        id_idspace(Grp,'DC'),
        Grp \= 'DC:0000138'.
d2group(D,Grp,ordo) :-
        entity_xref_from(Grp,D,'Orphanet').
d2group(D,Grp,ps) :-
        subclass(D,Grp),
        atom_concat('OMIM:PS',_,Grp).
d2group(D,Grp,doid) :-
        entity_xref_from(Grp,D,'DOID').
d2group(D,Grp,efo) :-
        entity_xref_from(Grp,D,'EFO').

d2groups(D,L,GN) :-
        solutions(Grp,d2group(D,Grp,GN),L).



d(D) :-
        setof(D,P^d2p(D,P),Ds),
        member(D,Ds).


s(D,G1,G2,G3,G4,G5) :-
        d(D),
        d2groups(D,G1,dc),
        d2groups(D,G2,ordo),
        d2groups(D,G3,ps),
        d2groups(D,G4,doid),
        d2groups(D,G5,efo).

gn(dc).
gn(ordo).
gn(ps).
gn(doid).
gn(efo).

missing(D,GN) :-
        gn(GN),
        d2groups(D,[],GN).

disease_lineage(D,NumParents,Parents) :-
        d(D),
        solutions(P,d_parent(D,P),Parents),
        length(Parents,NumParents).

d_parent(D,P) :- subclassT(D,P).
d_parent(D,P) :- entity_xref(D1,D),subclassT(D1,P).
d_parent(D,P) :- equivalent_class_symm(D,D1),subclassT(D1,P).

/*
  blip-findall -i d2p.pro -i ordo.obo -consult summary.pro ad_orpharoot/2 -label 
  */
ad_orpharoot(D,A) :-
        d(D),
        id_idspace(D,'Orphanet'),
        c_orpharoot(D,A).

c_orpharoot(D,A) :-
        subclassT(D,A),
        orpharoot(A),
        !.

orpharoot(A) :- subclass(A,'Orphanet:C001'), !.
orpharoot(A) :- \+ subclass(A,_),A\='Orphanet:C001', !.


mondo_score(S) :-
        aggregate(sum(NP),D^Ps^disease_lineage(D,NP,Ps),TotAncs),
        aggregate(count,D,d(D),NumDs),
        AvgAncs is TotAncs/NumDs,
        aggregate(count,C,class(C),NumCs),
        S is (AvgAncs/NumCs) * 1000.

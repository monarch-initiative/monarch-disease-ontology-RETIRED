new_xref(X,Y) :-
        m(X,Y),
        \+ entity_real_xref(X,_).

% don't choose mesh if there is a better option
good_new_xref(X,Y) :-
        new_xref(X,Y),
        \+ ((
             id_idspace(Y,'MESH'),
             new_xref(X,Z),
             Z\=Y)).



diff_xref(X,Y,Mappings) :-
        class(X),
        id_idspace(X,'GARD'),
        setof(Z,m(X,Z),Mappings), 
        entity_real_xref(X,Y),
        \+ member(Y,Mappings),
        \+ ((member(A,Mappings),
             entity_xref(A,Y))).



        
consistent_xref(X,Y,Z) :-
        m(X,Y),
        entity_real_xref(X,Z),
        (   X=Z
        ;   entity_real_xref(Y,Z)).

no_map(X) :-
        class(X),
        id_idspace(X,'GARD'),
        \+ m(X,_),
        \+ entity_real_xref(X,_).


entity_real_xref(X,Y) :-
        entity_xref(X,Y),
        \+ atom_concat(http,_,Y).


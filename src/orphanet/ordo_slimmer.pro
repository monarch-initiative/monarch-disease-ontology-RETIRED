cn(C,N) :- class(C,N1),downcase_atom(N1,N).

in_subset(C) :-
        in_subset(C,_).
in_subset(C,ordo_slim) :-
        class(C),
        \+ is_superfluous(C).


is_superfluous(C) :-
        cn(C,N),
        trimR(N,N2),
        cn(_,N2),
        \+ entity_xref_idspace(C,_,'OMIM').

% if the class is a metaclass (subset) it is superfluous
is_superfluous(C) :- \+ \+ entity_partition(_,C).



trimR(In,Out) :-
        trim(In,Out).
trimR(In,Out) :-
        trim(In,Z),
        trimR(Z,Out).



trim(In,Out) :-
        atom_concat('rare ',Out,In).
trim(In,Out) :-
        atom_concat('genetic ',Out,In).

g(G) :- setof(G,P^g2p(G,P),Gs),member(G,Gs).

g2fn(G,File) :-
        concat_atom(L,/,G),
        concat_atom(L,-,G2),
        concat_atom(['genes/',G2,'.md'],File).

        

wall :-
        g(G),
        g2fn(G,File),
        told,
        tell(File),
        format('~n## GENE: ~w~n',[G]),
        g2p(G,P),
        wallp(P),
        fail.

wallp(P) :-
        format('~n### ~w~n',[P]),
        label_query_results(P,true,Results1),
        label_query_results(P,false,Results2),
        best_results(Results1,Results2,Results),
        [Score-_|_] = Results,
        format('~nScore: ~w~n~n',[Score]),
        forall(member(Score-E,Results),
               wmatch(E)).

wmatch(E) :-
        format(' * '),
        wentity(E),
        nl,
        forall(equivalent_class_symm(E,X),
               (   format('    * '),
                   wentity(X),
                   nl)).

wentity(X) :-
        (   class(X,N)
        ->  true
        ;   N='-'),
        format('[~w ~w](http://beta.monarchinitiative.org/disease/~w)',[X,N,X]).

best_results(L1,L2,L1) :-
        L1=[S1-_|_],
        L2=[S2-_|_],
        S1>S2,
        !.
best_results(_,L2,L2).

        
        


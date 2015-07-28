:- use_module(bio(index_util)).

g(G) :- setof(G,P^g2p(G,P),Gs),member(G,Gs).

g2fn(G,File) :-
        concat_atom(L,/,G),
        concat_atom(L,-,G2),
        concat_atom(['genes/',G2,'.md'],File).

t :- t('LMNA').

t(G):-
        g2p(G,P),
        wallp(P),
        fail.
        

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
        \+ is_excluded(P),
        format('~n### ~w~n',[P]),
        find(P,E,Conf),
        wmatch(E,Conf).

/*
old_wallp(P) :-
        format('~n### ~w~n',[P]),
        label_query_results(P,true,Results1),
        label_query_results(P,false,Results2),
        best_results(Results1,Results2,Results),
        [Score-_|_] = Results,
        format('~nScore: ~w~n~n',[Score]),
        forall(member(Score-E,Results),
               wmatch(E)).
*/

wmatch(E,Conf) :-
        format(' * '),
        wentity(E),
        format(' Confidence: ~w',[Conf]),
        nl,
        forall(equivalent_class_symm(E,X),
               (   format('    * Equiv:'),
                   wentity(X),
                   nl)).

wentity(X) :-
        best_label(X,N),
        format('[~w ~w](http://beta.monarchinitiative.org/disease/~w)',[X,N,X]).

best_label(X,N) :- class(X,N),!.
best_label(X,N) :- lbl(X,N),!.
best_label(_,'-') :- !.




best_results(L1,L2,L1) :-
        L1=[S1-_|_],
        L2=[S2-_|_],
        S1>S2,
        !.
best_results(_,L2,L2).

        
        
find(Term,E,Conf) :-
        term_nlabel_stemmed(Term,N1,false),
        term_nlabel_stemmed(Term,N2,true),
        findn(N1,N2,E,Conf),
        !.
find(Term,E,low/Score) :-
        debug(matcher,'falling back on LRQ for ~w',[Term]),
        label_query_results(Term,true,[S-E|_]),
        Score is S/8,
        !.



        
findn(N1,_N2,E,high) :- entity_nlabel_scope_stemmed(E,N1,label,false), !.
findn(N1,_N2,E,high) :- entity_nlabel_scope_stemmed(E,N1,_,false), !.
findn(_N1,N2,E,medium) :- entity_nlabel_scope_stemmed(E,N2,label,true), !.
findn(_N1,N2,E,medium) :- entity_nlabel_scope_stemmed(E,N2,_,true), !.




ix :-
	materialize_index(entity_nlabel_scope_stemmed(1,1,-,-)).

is_excluded(P) :-
        downcase_atom(P,P2),
        concat_atom(L,' ',P2),
        concat_atom(L,'',P3),
        skip(P3),
        debug(matcher,'Skipping ~w',[P]),
        !.


skip('allhighlypenetrant').
skip('notspecified').
skip('notprovided').
skip('variantofunknownsignificance').


:- use_module(bio(index_util)).

:- dynamic gpmatch/2.

g(G) :- setof(G,P^g2p(G,P),Gs),member(G,Gs).


g2fn(G,File) :-
        g2fn(G,File,md).
g2fn(G,File,Suffix) :-
        deslash(G,G2),
        concat_atom(['genes/',G2,'.',Suffix],File).

deslash(G,G2) :-
        concat_atom(L,/,G),
        concat_atom(L,-,G2).



t :- t('LMNA').

t(G):-
        wallg(G).


write_tbl :-
        r7(G,G2,CN,CUI,PN,Sub,InG),
        match_phenotype(CN,Match,MatchName,Conf),
        findall(Eq-N,
                (   equivalent_class_symm(Match,Eq),
                    best_label(Eq,N)),
                MatchEqs),
        write_row([G,G2,CN,CUI,PN,Sub,InG,Match,MatchName,Conf,MatchEqs]),
        fail.

match_phenotype(P,Match,MatchName,Conf) :-
        \+ is_excluded(P),
        find(P,Match,Conf),
        class(Match,MatchName),
        !.
match_phenotype(_,'','','') :- !.

write_row(L) :-
        maplist(mk_atom,L,L2),
        concat_atom(L2,'\t',Row),
        writeln(Row).

mk_atom(T,A) :-
        sformat(A,'~w',[T]).

        

wall :-
        g(G),
        g2fn(G,File),
        told,
        tell(File),
        wallg(G),
        fail.

wallg(G) :-
        format('~n## GENE: ~w~n',[G]),
        nl,
        deslash(G,G2),
        format('![image](~w.png)~n',[G2]),
        format('[matched diseases visual](~w.png)  <-- click on raw to zoom~n',[G2]),
        nl,
        g2p(G,P),
        wallp(G,P),
        fail.
wallg(G) :-
        append('mkimg.sh'),
        setof(P,gpmatch(G,P),Ps),
        format('mondo'),
        forall(member(P,Ps),
               format(' -id ~w',[P])),
        g2fn(G,File,png),
        format(' -to png > ~w~n',[File]).


wallp(G,P) :-
        \+ is_excluded(P),
        format('~n### ~w~n',[P]),
        find(P,E,Conf),
        assert(gpmatch(G,E)),
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
                   nl)),
        forall(entity_synonym_scope(E,X,_),
               format('    * Syn: "~w"~n',[X])).


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


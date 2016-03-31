write_mesh_antislim :-
        mesh_antislim(X),
        format('[Term]~n'),
        format('id: ~w~n',[X]),
        format('subset: mesh_antislim~n'),
        nl,
        fail.
               

mesh_antislim(X) :-
        class(X),
        id_idspace(X,'MESH'),
        forall(subclassT(X,Y),
               id_idspace(Y,'MESH')).



bad(X) :-
        class(X),
        id_idspace(X,'OMIM'),
        forall(subclassT(X,Y),
               id_idspace(Y,'MESH')).

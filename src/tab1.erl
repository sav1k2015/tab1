-module (tab1).
-export([create_table/1]).
-export([add_rec/3, update_rec/3]).
-export([lookup_index/2, find_by_daterange/13]). 
-export([del_rec/2, close_table/1]).
-include_lib("stdlib/include/ms_transform.hrl").

create_table(Table) ->
    Table = ets:new(Table, [set, named_table]).


add_rec(Table, Index, Rec) ->
    ets:insert(Table, {Index, Rec, Time = erlang:localtime()}).

update_rec(Table, Index, Rec) ->
    ets:insert(Table, {Index, Rec, Time = erlang:localtime()}).
   
lookup_index(Table, Index) ->
    ets:lookup(Table,Index).


find_by_daterange(Table, Y1, M1, D1, Hour1, Min1, Sec1, Y2, M2, D2, Hour2, Min2, Sec2) -> 
    Date1 = {{Y1, M1, D1},{Hour1, Min1, Sec1}},
    Date2 = {{Y2, M2, D2}, {Hour2, Min2, Sec2}},
    MS = ets:fun2ms(fun({Key, Param, Datestamp}) 
        when Datestamp > Date1 andalso Datestamp < Date2 ->
            [Key, Param, Datestamp] end),
    ets:select(Table, MS).

del_rec(Table,Index) ->
    ets:delete(Table,Index).


close_table(Table) ->
    ets:delete(Table).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

tab1_test_()->[
    ?_assertEqual(animal, create_table(animal)),
    ?_assertEqual(true, add_rec(animal, 1, 'dog')), 
    ?_assertEqual([{1, 'dog', erlang:localtime()}], lookup_index(animal, 1)),
    ?_assertEqual(true, update_rec(animal, 1, 'cat')),
    ?_assertEqual([{1, 'cat', erlang:localtime()}], lookup_index(animal, 1)),
    ?_assertEqual([[1, 'cat', erlang:localtime()]], find_by_daterange(animal,2015,4,4,0,0,0,2017,8,8,11,11,11)),
    ?_assertEqual(true, del_rec(animal, 1)),
    ?_assertEqual([], lookup_index(animal, 1)),
    ?_assertEqual(true, close_table(animal))].
-endif.
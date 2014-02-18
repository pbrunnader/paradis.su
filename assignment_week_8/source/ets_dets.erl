% 
% This is the "week8 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 


-module(ets_dets).

-export([start/2,time/2,benchmark/1,name/0,phone/0]).

benchmark(Type) when Type == dets; Type == ets ->
	List = lists:seq(10, 90, 10) ++ lists:seq(100, 900, 100) ++ lists:seq(1000, 9000, 1000) ++ lists:seq(10000, 90000, 10000) ++ lists:seq(100000, 1000000, 100000),
	io:format("# Records Time Status ~n"),
	benchmark(Type, List).

benchmark(_, List) when List == [] ->
	ok;
benchmark(Type, [Head|Tail]) ->
	time(Type, Head),
	benchmark(Type, Tail).

time(Type, Number) when Type == dets; Type == ets ->
	{Time,Result} = timer:tc(ets_dets,start,[Type, Number]),
	io:format("~p ~p ~p~n",[Number, Time/1000000, Result]),
	ok.


start(ets, Number) when Number > 0 ->
	Table = ets:new(name_phone, [set,named_table]),
	ets:insert(Table, [{ets_dets:name(), ets_dets:phone()} || _ <- lists:seq(1, Number)]),
	ets:delete(Table);
start(dets, Number) when Number > 0 ->
	{ok, Table} = dets:open_file("ets_dets_" ++ integer_to_list(Number) ++ ".txt",[]),
	ok = dets:insert(Table, [{ets_dets:name(), ets_dets:phone()} || _ <- lists:seq(1, Number)]),
	dets:close(Table).


name() ->
	Length = crypto:rand_uniform(5, 11),
	name(Length,{97,123}).	

name(1,_) ->
	[crypto:rand_uniform(65, 91)];
name(Length,{Begin,End}) ->
	name(Length-1,{Begin,End}) ++ [crypto:rand_uniform(Begin, End)].


phone() ->
	Length = crypto:rand_uniform(6, 13),
	phone(Length,{48,58}).	

phone(1,_) ->
	[48];
phone(2,{Begin,End}) ->
	phone(1,{Begin,End}) ++ [crypto:rand_uniform(Begin+1, End)];
phone(Length,{Begin,End}) ->
	phone(Length-1,{Begin,End}) ++ [crypto:rand_uniform(Begin, End)].


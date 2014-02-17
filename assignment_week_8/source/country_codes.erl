% 
% This is the "week8 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(country_codes).
-export([start/0,lookup/2]).


load_file(File) ->
	Table = ets:new(country_codes, [set,named_table]),
	{ok, Data} = file:consult(File),
	load_line(Table, Data),
	Table.

load_line(_, Data) when Data == [] ->
	end_of_file;
load_line(Table, [Head|Tail]) ->
	ets:insert(Table, Head),
	load_line(Table, Tail).

start() -> 
	load_file("country_codes.txt").
	
lookup(EtsTable, Code) ->
	case ets:lookup(EtsTable, Code) of
		[{Code,Name}] ->
			{ok,Name};
		_ -> 
			error
	end.

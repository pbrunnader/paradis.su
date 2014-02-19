% 
% This is the "week8 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(country_codes).
-export([start/0,lookup/2,stop/1]).


load_file(File) ->
	Table = ets:new(country_code, [set,named_table]),
	{ok, Data} = file:consult(File),
	ets:insert(Table, Data),
	Table.

start() -> 
	load_file("country_codes.txt").
	
stop(EtsTable) ->
	ets:delete(EtsTable),
	ok.
	
lookup(EtsTable, Code) ->
	case ets:lookup(EtsTable, Code) of
		[{Code,Name}] ->
			{ok,Name};
		_ -> 
			error
	end.

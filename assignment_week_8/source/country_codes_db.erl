% 
% This is the "week8 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(country_codes_db).
-export([do_this_once/0,start/0,select/1,update/2]).

-record(country_codes, {code, name}).

do_this_once() ->
	case mnesia:create_schema([node()]) of
		ok ->
			mnesia:start(),
			mnesia:create_table(country_codes, [{attributes, record_info(fields, country_codes)}]),
			mnesia:stop(),
			init:stop(),
			ok;
		_ -> 
			error
	end.

start() ->
	mnesia:clear_table(country_codes),
	mnesia:start(),
	reset("country_codes.txt").

reset(File) ->
	{ok, Data} = file:consult(File),
	List = load(Data),
	initialize(List).

load(Data) when Data == [] ->
	[];
load([Head|Tail]) ->
	{Code, Name} = Head,
	[{country_codes, Code, Name}] ++ load(Tail).

initialize(List) ->
	F = fun() ->
			lists:foreach(fun mnesia:write/1,List)
		end,
	{_, ok} = mnesia:transaction(F),
	ok.

update(Code,Name) ->
	{ok, _} = select(Code),
	F = fun() ->
		mnesia:write({country_codes, Code, Name})
	end,
	{_, ok} = mnesia:transaction(F),
	ok.
	
select(Code) ->
	F = fun() -> 
		mnesia:read({country_codes, Code}) 
	end, 
	case mnesia:transaction(F) of
		{atomic, [{country_codes, Code, Value}]} ->
			{ok, Value};
		_ ->
			{error, does_not_exist}
	end.

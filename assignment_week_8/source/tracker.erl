% 
% This is the "week8 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(tracker).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start/0,stop/0,i_want/2,i_am_leaving/1,who_wants/1,ping/1]).

start() -> 
	gen_server:start_link({local,?MODULE}, ?MODULE, {dict:new(), dict:new()}, []).

i_want(File, IP) -> 
	gen_server:call(?MODULE, {i_want, File, IP}). 

i_am_leaving(IP) -> 
	gen_server:call(?MODULE, {i_am_leaving, IP}). 

who_wants(File) -> 
	gen_server:call(?MODULE, {who_wants, File}).

ping(IP) ->
	gen_server:call(?MODULE, {ping, IP}).

stop() ->
	gen_server:cast(?MODULE, stop).

init(State) -> 
	{ok, State}.

clean_up({Dict ,Time}) ->
	clean_up(dict:fetch_keys(Time), {Dict ,Time}).

clean_up(List, {Dict ,Time}) when List == [] ->
	{ok, {Dict, Time}};
clean_up([IP|Tail], {Dict, Time}) ->
	case dict:find(IP, Time) of
		{ok, Value} -> 
			T = timer:now_diff(erlang:now(), Value),
			case T > 10000000 of
				true ->
					{ok, NewTime} = delete(IP, Time),
					NewDict = dict:map( fun(_,V) -> [IPs || IPs <- V,  IPs /= IP] end, Dict),
					clean_up(Tail,{NewDict, NewTime});
				false ->
					clean_up(Tail,{Dict, Time})
			end;
		error ->
			clean_up(Tail,{Dict, Time})
	end.
	
create(IP, Time) ->
	{ok, dict:store(IP, erlang:now(), Time)}.

update(IP, Time) ->
	case dict:is_key(IP, Time) of
		true ->
			create(IP, Time);
		false ->
			{ok, Time}
	end.

delete(IP, Time) ->
	{ok, dict:erase(IP, Time)}.

handle_call({i_want, File, IP}, _, {Dict, Time}) -> 
	{ok, {NewDict, NewTime}} = clean_up({Dict, Time}),
	List = case dict:find(File, NewDict) of
		{ok, Value} ->
			[IPs || IPs <- Value,  IPs /= IP] ++ [IP];
		error ->
			[IP]
	end,
	{ok, NewTime2} = create(IP, NewTime),
	NewDict2 = dict:store(File, List, NewDict),
	{reply, List, {NewDict2, NewTime2}};

handle_call({i_am_leaving, IP}, _, {Dict, Time}) -> 
	{ok, NewTime} = delete(IP, Time),
	NewDict = dict:map( fun(_,Value) -> [IPs || IPs <- Value,  IPs /= IP] end, Dict),
	{reply, ok, {NewDict, NewTime}};

handle_call({who_wants, File}, _, {Dict, Time}) -> 
	{ok, {NewDict, NewTime}} = clean_up({Dict, Time}),
	List = case dict:find(File,NewDict) of
		{ok, Value} ->
			Value;
		error ->
			[]
	end,
	{reply, List, {NewDict, NewTime}};

handle_call({ping, IP}, _, {Dict, Time}) -> 
	{ok, {NewDict, NewTime}} = clean_up({Dict, Time}),
	{ok, NewTime2} = update(IP, NewTime),
	{reply, ok, {NewDict, NewTime2}}.

handle_cast(stop, State) -> {stop, normal, State};
handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
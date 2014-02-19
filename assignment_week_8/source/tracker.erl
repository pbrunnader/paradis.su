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
	gen_server:start_link({local,?MODULE}, ?MODULE, dict:new(), []).
		

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

init(Dict) -> 
	{ok, Dict}.

handle_call({i_want, File, IP}, _, Dict) -> 
	List = case dict:find(File, Dict) of
		{ok, Value} ->
			[IPs || IPs <- Value,  IPs /= IP] ++ [IP];
		error ->
			[IP]
	end,
	NewDict = dict:store(File, List, Dict),
	{reply, List, NewDict};
		
handle_call({i_am_leaving, IP}, _, Dict1) -> 
	Dict2 = dict:map( fun(_,Value) -> [IPs || IPs <- Value,  IPs /= IP] end, Dict1),
	{reply, ok, Dict2};

handle_call({who_wants, File}, _, Dict) -> 
	List = case dict:find(File,Dict) of
		{ok, Value} ->
			Value;
		error ->
			[]
	end,
	{reply, List, Dict};

handle_call({ping, IP}, _, Dict) -> 
	io:format("ping: ~p~n",[IP]),
	{reply, ok, Dict, 2000}.

handle_cast(stop, State) ->
	{stop, normal, State};
handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.

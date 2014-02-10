% 
% This is the "week6 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(store).
-compile(export_all).

start() ->
	Dict = dict:new(),
	register(master, spawn(?MODULE, master, [Dict])),
	register(replica, spawn(?MODULE, replica, [Dict])).

store(Key, Value) ->
	Status = whereis(master),
	if
		Status == undefined ->
			whereis(replica) ! {store, Key, Value};
		true ->
			whereis(master) ! {store, Key, Value}
	end.

fetch(Key) ->
	Status = whereis(master),
	if
		Status == undefined ->
			whereis(replica) ! {fetch, Key};
	true ->
			whereis(master) ! {fetch, Key}
	end.
	
master(Dict) ->
	P = whereis(replica),
	link(P),
	process_flag(trap_exit, true),
	receive
		{store, Key, Value} -> 
			NewDict = dict:store(Key, Value, Dict),
			io:format("MASTER: store: ~p => ~p~n",[Key,Value]),
			whereis(replica) ! {store, Key, Value},
			master(NewDict);
		{fetch, Key} ->
			io:format("MASTER: fetch: ~p~n",[Key]),
			Found = dict:is_key(Key, Dict),
			if 
				Found ->
					Value = dict:fetch(Key, Dict),
					io:format("MASTER: fetch: ~p => ~p.~n",[Key,Value]);
				true ->
					io:format("MASTER: fetch: ~p => NOT EXIST.~n",[Key])
			end,
			master(Dict);
		{'EXIT',Pid, Why} ->
			io:format("Process with Pid ~p chrashed because ~p.~n",[Pid,Why]),
			print("MASTER: Restart REPLICA process and sync dictionary."),
			register(replica, spawn(?MODULE, replica, [Dict])),
			master(Dict);
		_ -> 
			exit("MASTER: Unexpected function called.")
	end.
	
replica(Dict) ->
	P = whereis(master),
	link(P),
	process_flag(trap_exit, true),
	receive
		{store, Key, Value} -> 
			NewDict = dict:store(Key, Value, Dict),
			io:format("REPLICA: store: ~p => ~p~n",[Key,Value]),
			replica(NewDict);
		{fetch, Key} ->
			Found = dict:is_key(Key, Dict),
			if 
				Found ->
					Value = dict:fetch(Key, Dict),
					io:format("REPLICA: fetch: ~p => ~p.~n",[Key,Value]);
				true ->
					io:format("REPLICA: fetch: ~p => NOT EXIST.~n",[Key])
			end,
			replica(Dict);
		{'EXIT',Pid, Why} ->
			io:format("Process with Pid ~p chrashed because ~p.~n",[Pid,Why]),
			print("REPLICA: Restart MASTER process and sync dictionary."),
			register(master, spawn(?MODULE, master, [Dict])),
			replica(Dict);
		_ -> 
			exit("REPLICA: Unexpected function called.")
	end.

sleep(T) ->
	receive
		after T*1000 ->
			true
	end.
	
print(X) ->
	io:format("~p~n",[X]).


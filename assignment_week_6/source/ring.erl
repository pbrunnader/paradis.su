% 
% This is the "week6 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(ring).
-compile(export_all).

% N = number of processes
% M = number of rounds

start(M, N) ->
	Pid = spawn_link(ring, create_node, [N]),
	io:format("Root Process ~p ~n", [self()]),
	Pid ! {M, 0},
	io:format("End.").

create_node(N) ->
	    % io:format("Create Process ~p (~p)~n", [self(), N]),
	    Pid = spawn_link(ring, create_node, [N-1, self()]),
	    loop(Pid,false).

create_node(1, Last) ->
	    % io:format("Connect first and last Process ~p - ~p~n", [self(), Last]),
	    loop(Last,true);
create_node(N, Last) ->
	    % io:format("Create Process ~p (~p)~n", [self(), N]),
	    Pid = spawn_link(ring, create_node, [N-1, Last]),
	    loop(Pid,false).

loop(Pid,Round) ->
	link(Pid),
	process_flag(trap_exit, true),

	receive
		{0, I} -> I,
	    	io:format("~p ~p ~p ~n", [self(), 0, I]),
			{0, I};
	    {TTL, I} ->
	    	io:format("~p ~p ~p ~n", [self(), TTL, I]),
	    	if
				Round == true ->
					Pid ! {TTL-1, I+1};
				Round == false ->
					Pid ! {TTL, I+1}
			end,
	        loop(Pid,Round)
	    end. 
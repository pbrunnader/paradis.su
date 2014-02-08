% 
% This is the "week6 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(ring).
-compile(export_all).

start(N,M) when is_integer(N), N > 0, is_integer(M), M > 0 ->
	    Nodes = [spawn_link(ring, node, [ID, self()]) || ID <- lists:seq(1, N)],
	
		% build ring COPY first Node to the end of the list
	    ring:build(Nodes ++ [hd(Nodes)]),

	    hd(Nodes) ! {M, 0},
	
		% waitung for result
		receive
			{'EXIT', _, Value} ->
				io:format("Pid List ~p.~n",[Nodes]),
				stop(Nodes),
				Value
		end.

stop([]) ->
	stopped;
stop([Pid|L]) ->
	stop(L),
	Run = erlang:is_process_alive(Pid),
	if 
		Run == false -> 
			io:format("Not!~n");
		true ->
			io:format("Kill!~n")
			% exit(Pid,"something")
	end.
	

%connects the nodes to form a ring
build([_]) ->
	done;
build([N1, N2 | Nodes]) ->
	N1 ! {self(), '->', N2},
	build([N2 | Nodes]).

node(ID, Pid) ->
	link(Pid),
	% process_flag(trap_exit, true),
	receive
		{Pid, '->', PidNext} ->
			node(ID, Pid, PidNext)
	end.

node(ID, Pid, PidNext) ->
	receive
		{TTL, Count} ->
		    if
				TTL > 0, ID == 1 ->
			    	PidNext ! {TTL-1, Count + 1},
			    	node(ID, Pid, PidNext);
				TTL == 0, ID == 1 ->
					Pid ! {'EXIT', self(), Count};
				true ->
					PidNext ! {TTL, Count + 1},
					node(ID, Pid, PidNext)
		    end
	end.

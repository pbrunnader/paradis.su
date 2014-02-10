% 
% This is the "week6 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(ring).
-compile(export_all).

benchmark() ->
	N = lists:seq(1000, 10000, 1000),
	M = lists:seq(1000, 10000, 1000),
	io:format("# Nodes Rounds Time Sum ~n"),
	benchmark(N,M).
	
% benchmark(_,[]) ->
% 	done;
benchmark([Node|Nodes],[Round|[]]) when Node > hd(Nodes), is_integer(Round) ->
	ring:time(Node, Round);
benchmark([Node|Nodes],[Round|[]]) when is_integer(Round) ->
	ring:time(Node, Round),
	benchmark(Nodes ++ [Node], [Round]);
benchmark([Node|Nodes],[Round|Rounds]) when Node > hd(Nodes) ->
	ring:time(Node, Round),
	benchmark(Nodes ++ [Node], Rounds);
benchmark([Node|Nodes],[Round|Rounds]) ->
	ring:time(Node,Round),
	benchmark(Nodes ++ [Node], [Round] ++ Rounds).

time(N,M) ->
	{Time,Result} = timer:tc(ring,start,[N,M]),
	io:format("~p ~p ~p ~p~n",[N,M,Time,Result]),
	ok.

start(N,M) when is_integer(N), N > 0, is_integer(M), M > 0 ->
	    Nodes = [spawn_link(ring, node, [ID, self()]) || ID <- lists:seq(1, N)],
	
		% build ring COPY first Node to the end of the list
	    ring:build(Nodes ++ [hd(Nodes)]),

	    hd(Nodes) ! {M, 0},
	
		% waitung for result
		receive
			{'EXIT', _, Value} ->
				Value
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
		{TTL, Count} when is_integer(TTL) ->
		    if
				TTL > 0, ID == 1 ->
					PidNext ! {TTL-1, Count + 1},
					node(ID, Pid, PidNext);
				TTL == 0, ID == 1 ->
					PidNext ! {'EXIT', self()},
					Pid ! {'EXIT', self(), Count};
				true ->
					PidNext ! {TTL, Count + 1},
					node(ID, Pid, PidNext)
		    end;
		{'EXIT', _ } ->
			PidNext ! {'EXIT', self()}
	end.

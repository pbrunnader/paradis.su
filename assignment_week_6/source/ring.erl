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

start(N,M) ->
	Pid = build(N),
	Pid ! {0, M},
	loop(Pid, true).

build(N) ->
	Nodes = fun(_Num, Pid) -> 
		spawn(ring, loop, [Pid, false]) end,
		lists:foldl(Nodes, self(), lists:seq(1, N-1)).

loop(Pid, Last) ->
	link(Pid),
	process_flag(trap_exit, true),
	receive
		{Number, 0} ->
			io:format("Process ~p received ~p (X), forwarding to ~p~n", [self(), Number, Pid]),
			exit("Ende.");
		{Number, 1} ->
			io:format("Process ~p received ~p (X), forwarding to ~p~n", [self(), Number, Pid]),
			Pid ! {Number+1, 1};
		{Number, TTL} ->
			io:format("Process ~p received ~p (~p), forwarding to ~p~n", [self(), Number, TTL, Pid]),
			case Last of
				true -> Pid ! {Number+1, TTL - 1};
				false -> Pid ! {Number+1, TTL}
			end,
			loop(Pid, Last)
	end.
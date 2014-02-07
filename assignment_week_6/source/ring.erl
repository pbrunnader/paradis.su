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
	Pid = spawn_link(ring, loop, []),
	register(root, Pid),
	io:format("Root ~p!~n",[Pid]),
	startProcess(N-1,Pid),
	io:format("=====================================~n"),
	Pid ! {M, 0}.

startProcess(1,_) ->
	P = whereis(root),
	Pid = spawn_link(ring, loop, [P]),
	io:format("Created ~p -> ~p ~n",[P, Pid]),
	Pid;

startProcess(N,P) ->
	Pid = spawn_link(ring, loop, [P]),
	io:format("Created ~p -> ~p ~n",[P, Pid]),
	startProcess(N-1,Pid).

loop() ->
	loop(whereis(root)).

loop(Pid) -> 
	link(Pid),
	io:format("~p <==> ~p ~n",[Pid, self()]),
	process_flag(trap_exit, true),
	receive
		{0, Integer} ->
			io:format("TTL=0; Integer:~p; ~n!!!!!!!!!!!! ~n",[Integer]);
		{TTL,Integer} -> 
			io:format("TTL=~p; Integer:~p; ~n",[TTL,Integer]),
			Root = whereis(root),
			if
				Pid == Root ->
					Pid ! {TTL-1,Integer+1};
				true ->
					Pid ! {TTL,Integer+1}
			end,
			loop(Pid);
		_ -> 
			exit("Unexpected data type.")
	end.
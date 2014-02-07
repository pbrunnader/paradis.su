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
	io:format("Masterprocess!~n"),
	Pid = createNode(N,nil),
	Result = Pid ! {M,0},
	io:format("RESULT: ~p ~n",[Result]).


createNode(N,nil) ->
	Pid = spawn_link(ring, loop, [nil]),
	createNode(N-1,Pid),
	Pid;
createNode(0,P) ->
	Pid = spawn_link(ring, loop, [P]),
	register(circle, Pid);
createNode(N,P) ->
	Pid = spawn_link(ring, loop, [P]),
	createNode(N-1,Pid).

loop(nil) -> 
	receive
		{TTL,Integer} -> 
			Pid = whereis(circle),
			io:format("~p ... ~p!~n",[Pid,Integer]),
			Pid ! {TTL-1,Integer+1},
			io:format("~n"),
			loop(nil);
		_ -> 
			exit("Unexpected data type.")
	end;
loop(Pid) -> 
	link(Pid),
	process_flag(trap_exit, true),
	receive
		{0, Integer} ->
			io:format("~p ... ~p!~n",[Pid,Integer]),
			{0, Integer};
		{TTL,Integer} -> 
			io:format("~p ... ~p?~n",[Pid,Integer]),
			Pid ! {TTL,Integer+1},
			loop(Pid)
	end.
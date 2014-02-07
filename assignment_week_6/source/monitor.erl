% 
% This is the "week6 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(monitor).
-compile(export_all).

start() ->
	Pid = double:start(),
	io:format("Process 'double' with Pid ~p is (re)startet.~n",[Pid]),
	spawn_link(monitor, loop, [Pid]).
	
loop(Pid) -> 
	link(Pid),
	process_flag(trap_exit, true),
	io:format("Process with Pid ~p is monitored.~n",[Pid]),
	receive 
		{'EXIT',Pid, Why} ->
			io:format("Process with Pid ~p chrashed because ~p.~n",[Pid,Why]),
			monitor:start()
	end.
	
	
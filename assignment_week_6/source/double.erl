% 
% This is the "week6 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(double).
-compile(export_all).

start() ->
	Pid = spawn(double, loop, []),
	register(double, Pid),
	Pid.
	
loop() -> 
	receive
		X when is_integer(X) -> 
			io:format("~p~n",[X*2]),
			loop();
		_ -> 
			exit("Unexpected data type.")
	end.
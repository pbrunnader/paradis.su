% 
% This is the "week6 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(reliable).
-compile(export_all).
	
start() ->
	print("START: 'double' process."),
	register(double, spawn(?MODULE, double, [])),
	print("START: 'crash' process with randomness."),
	spawn(?MODULE, crash, []),
	print("START: 'monitor' process."),
	spawn_link(?MODULE, monitor, []),
	print("START: usage to run a client process is:"),
	print("START: reliable:client(<integer>).").


monitor() -> 
	print("MONITOR: Monitor the 'double' process."),
	Pid = whereis(double),
	link(Pid),
	process_flag(trap_exit, true),
	receive 
		{'EXIT',Pid, _} ->
			N = random(30),
			print("MONITOR: Waiting for " ++ integer_to_list(N) ++ " seconds to restart."),
			sleep(N),
			print("MONITOR: Restart 'double' process NOW."),
			register(double, spawn_link(?MODULE, double, [])),
			monitor()
	end.


double() ->
	receive
		{From, Value} when is_integer(Value) -> 
			From ! {self(), Value * 2}, 
			double();
		_ -> 
			exit("Invalid value given.")
	end.


crash() ->
	sleep(random(30)),
	print("CRASH: Send invalid message to 'double' process."),
	try
		whereis(double) ! {self(), crash}
	after
		print("CRASH: 'double' process not running."),
		crash()
	end.


client(Number) when is_integer(Number) ->
	client(whereis(double), 1, Number).

client(_, 11, _) ->
	print("Client: Stop trying to send message!");
client(undefined, Try, Number) ->
	sleep(1),
	print("Client: Non successful attempt #" ++ integer_to_list(Try) ++ "."),
	client(whereis(double), Try+1, Number);
client(Pid, Try, Number) when is_integer(Try), Try > 0, Try < 11 ->
	try
		Pid ! {self(), Number}
	after
		receive
			{Pid, Value} when is_integer(Value) -> 
				print("Client: Received result: " ++ integer_to_list(Number) ++ " * 2 => " ++ integer_to_list(Value) ++ "."),
				Value;
			_ ->
				print(crash_detected)
		after 1000 ->
			print("Client: Non successful attempt #" ++ integer_to_list(Try) ++ "."),
			client(whereis(double), Try+1, Number)
		end
	end.


sleep(T) ->
	receive
		after T*1000 ->
	    	true
	end.


print(X) ->
 	io:format("~p~n",[X]).


random(Max) ->
	crypto:rand_uniform(1, Max).

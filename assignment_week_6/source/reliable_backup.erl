% 
% This is the "week6 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(reliable_backup).
-compile(export_all).

start() ->
	PidDouble = spawn(?MODULE, double, []),
	register(double, PidDouble),
	io:format("Registered server called double started: ~p~n",[PidDouble]),
	% PidCrash = spawn(?MODULE, crash, []),
	% io:format("Server started to send invalid messages: ~p~n",[PidCrash]),
	PidMonitor = spawn_link(?MODULE, monitor, [PidDouble]),
	io:format("Monitor started to watch started double server: ~p~n",[PidMonitor]),
	ok.
	
client() ->
	sleep(2),
	client(1).
	
client(10) ->
	Pid = whereis(double),
	Pid ! {self(), 2},
	receive
		{From, Value} when is_integer(Value) -> 
			io:format(self(),"Server response: ~p~n",[Value])
	% after 
	% 	2000 ->
	% 		io:format(self(),"Server response: missing abort!~p ~n",[self()])
	end;
client(X) when is_integer(X), X > 0 ->
	Pid = whereis(double),
	Pid ! {self(), 2},
	receive
		{From, Value} when is_integer(Value) ->
			io:format(self(),"Server response: ~p~n",[Value])
	% after 
	% 	2000 ->
	% 		io:format(self(),"Server response: waiting!~p ~n",[self()]),
	% 		client(X+1)
	end.
	
double() -> 
	io:format("JIHI:~p~n",[self()]),
	receive
		{From, Value} when is_integer(Value) -> 
			io:format("JAHA: ~p~n",[Value*2]),
			From ! {self(), Value * 2},
			reliable:double();
		% {_, Value} when is_atom(Value) ->
		% 	exit("Invalid value given.");
		_ -> 
			exit("Invalid value given.")
	end.
	
monitor(Pid) -> 
	link(Pid),
	process_flag(trap_exit, true),
	io:format("Process with Pid ~p is monitored.~n",[Pid]),
	receive 
		{'EXIT',Pid, Why} ->
			io:format("Process with Pid ~p chrashed because ~p.~n",[Pid,Why]),
			sleep(crypto:rand_uniform(1, 10)),
			PidDouble = spawn(?MODULE, double, []),
			register(double, PidDouble),
			io:format("Registered server called double restarted: ~p~n",[PidDouble]),
			PidMonitor = spawn_link(?MODULE, monitor, [PidDouble]),
			io:format("Monitor started to watch restarted double server: ~p~n",[PidMonitor])
	end.
	
crash() ->
	sleep(crypto:rand_uniform(10, 20)),
	Pid = whereis(double),
	Pid ! {self(), crash},
	crash().
	
	
sleep(T) ->
	%% sleep for T milliseconds
	receive
		after T*1000 ->
	    	true
	end.
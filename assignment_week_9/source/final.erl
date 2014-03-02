% 
% This is the "week9 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(maps).
-compile(export_all).

% Double = fun(X) -> X*10 end.

smap(_, []) -> 
	[];
smap(F, [H|T]) -> 
	[F(H) | smap(F, T)].

pmap_maxtime(F, L, MaxTime, Max) ->
	S = self(),
	{L1, L2} = case length(L) < Max of
		true ->
			{L, []};
		false ->
			lists:split(Max, L)
	end,
	Time = erlang:now(),
	Pids = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- L1],
	io:format("Start.~n"),
	spawn(?MODULE, timer, [Pids, MaxTime]),
	replies_stable(Pids, L2, F) ++ [{time, timer:now_diff(erlang:now(), Time)/1000000}].


timer(Pids, MaxTime) ->
	io:format("xxxxx = ... ~n"),
	receive
		X ->
			io:format("oh, oh, ... ~p ~n",[X])
	after
		MaxTime ->
			killall(Pids)
	end,
	io:format("end!!!~n").

pmap_timeout(F, L, MaxTime, Max) ->
	S = self(),
	{L1, L2} = case length(L) < Max of
		true ->
			{L, []};
		false ->
			lists:split(Max, L)
	end,
	Time = erlang:now(),
	Pids = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- L1],
	replies_stable(Pids, L2, F, MaxTime) ++ [{time, timer:now_diff(erlang:now(), Time)/1000000}].


replies_timeout([Pid|Pids], MaxTime) ->
	receive
		{Pid,{'EXIT',_}} ->
			[error];
		{Pid, Value} -> 
			[Value]
	after
		MaxTime ->
			exit(Pid,kill),
			[timeout]
	end ++ replies_timeout(Pids, MaxTime);
replies_timeout([], _) ->
	[].


% a stable processing of each element (in order) with TIMEOUT
replies_stable([Pid|Pids], [], _, MaxTime) ->
	Result = receive
		{Pid,{'EXIT',_}} ->
			[error];
		{Pid, Value} ->
			[Value]
	after
		MaxTime ->
			exit(Pid,kill),
			[timeout]
	end,	
	Result ++ replies_stable(Pids, [], nil, MaxTime);
replies_stable([Pid|Pids], [L|T], F, MaxTime) ->
	S = self(),
	Result = receive
		{Pid,{'EXIT',_}} ->
			NewPid = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- [L]],
			[error];
		{Pid, Value} ->
			NewPid = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- [L]],
			[Value]
	after
		MaxTime ->
			exit(Pid,kill),
			NewPid = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- [L]],
			[timeout]
	end,
	Result ++ replies_stable(Pids ++ NewPid, T, F, MaxTime);
replies_stable([],[],_,_) ->
	[].




pmap_any_tagged_max_time(F, L, MaxTime) ->
	S = self(),
	Pids = [spawn(fun() -> S ! {self(), {I, catch F(I)}} end) || I <- L],
	Result = replies_non_stable_timeout(Pids, MaxTime),
	killall(Pids),
	Result.



killall([Pid|Pids]) ->
	io:format("KILL ~p : ~p~n",[self(), Pid]),
	killall(Pids),
	exit(Pid,kill);
killall([]) ->
	[].



% a NON stable processing of each element with TIMEOUT
replies_non_stable_timeout([_|Pids], MaxTime) ->
	replies_non_stable_timeout(Pids, MaxTime) ++ receive
		{_, Value} ->
			[Value]
	after
		MaxTime ->
			[]
	end;
replies_non_stable_timeout([],_) ->
	[].




replies([Pid|Pids], MaxTime) ->
	replies(Pids, MaxTime) ++ receive
		{_, Value} -> 
			[Value]
	after
		MaxTime ->
			exit(Pid,kill),
			[]
	end;
replies([], _) ->
	[].


pmap_any_tagged(F, L) ->
	S = self(),
	Pids = [spawn(fun() -> S ! {self(), {I, catch F(I)}} end) || I <- L],
	replies_non_stable(Pids,[],nil).

pmap_any(F, L) ->
 	S = self(),
	Pids = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- L],
	replies_non_stable(Pids,[],nil).

pmap_max(F, L, Max) ->
	S = self(),
	{L1, L2} = case length(L) < Max of
		true ->
			{L, []};
		false ->
			lists:split(Max, L)
	end,
	Pids = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- L1],
	replies_stable(Pids,L2,F).




% a stable processing of each element (in order)
replies_stable([Pid|Pids],[],_) ->
	replies_stable(Pids, [], nil) ++ receive
		{_, {'EXIT',_}} ->
			io:format("4~n"),
			[error_and_so_on];
		{Pid, Value} ->
			io:format("3~n"),
			[Value];
		X ->
			io:format("5 : ~p ~n",[X]),
			[else]
		end;
replies_stable([Pid|Pids],[L|T],F) ->
	S = self(),
	replies_stable(Pids ++ [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- [L]], T, F) ++ receive
		{_, {'EXIT',_}} ->
			io:format("1~n"),
			[error_and_so_on];
		{Pid, Value} ->
			io:format("2~n"),
			[Value];
		X ->
			io:format("6~n"),
			[else]
	end;
replies_stable([],[],_) ->
	[].

% a NON stable processing of each element
replies_non_stable([_|Pids],[],_) ->
	Result = receive
		{_, Value} ->
			[Value]
	end,
	Result ++ replies_non_stable(Pids, [], nil);
replies_non_stable([_|Pids],[L|T],F) ->
	S = self(),
	Result = receive
		{_, Value} ->
			NewPid = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- [L]],
			[Value]
	end,
	Result ++ replies_non_stable(Pids ++ NewPid, T, F);
replies_non_stable([],[],_) ->
	[].





pmap(F, L) ->
	S = self(),
	Pids = [spawn(fun() -> S ! {self(),catch F(I)} end) || I <- L],
	gather_replies(Pids).

gather_replies([Pid|T]) ->
	gather_replies(T) ++ receive
		{Pid, Val} -> [Val]
	end;

gather_replies([]) ->
	[].	


replies(_) -> [].


fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).
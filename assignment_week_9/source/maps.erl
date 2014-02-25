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


pmap_timeout(F, L, MaxTime, Max) ->
	S = self(),
	Pids = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- lists:sublist(L, Max)],
	replies_timeout(Pids, MaxTime).


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
	

pmap_any_tagged_max_time(F, L, MaxTime) ->
	S = self(),
	Pids = [spawn(fun() -> S ! {self(), {I, catch F(I)}} end) || I <- L],
	replies(Pids, MaxTime).


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
	replies(Pids).


pmap_any(F, L) ->
	S = self(),
	Pids = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- L],
	replies(Pids).
		

pmap_max(F, L, Max) ->
	S = self(),
	Pids = [spawn(fun() -> S ! {self(), catch F(I)} end) || I <- lists:sublist(L, Max)],
	replies(Pids).


replies([_|Pids]) ->
	replies(Pids) ++ receive
		{_, Value} -> 
			[Value]
	end;
replies([]) ->
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





fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

-module(final).
-compile(export_all).

other() ->
	{T, _} = timer:tc(?MODULE,pmap_any_tagged_max_time,[fun fib/1,[35,2,456,20],2000]),
	T/1000000.

test() ->
	% Worker = [32,16,8,4,2,1],
	Worker = lists:seq(2,10),
	io:format("Workers: ~p ~n",[Worker]),
	List = [ random:uniform(40) || _ <- lists:seq(1,200) ],
	io:format(".. "),
	{T, _} = timer:tc(?MODULE,smap,[fun fib/1,List]),
	io:format("~p ~p ~p ~p ~p ~p ~n",[1, T, T, T, T/T, T/T]),
	test(Worker,List, T),
	ok.
	
test([],_,_) ->
	ok;
test([H|Worker],List,Ref) ->
	sleep(1),
	io:format("."),
	{T1, _} = timer:tc(?MODULE,pmap_max,[fun fib/1,List,H]),
	io:format(". "),
	{T2, _} = timer:tc(mapc,pmap_max,[fun fib/1,List,H]),
	io:format("~p ~p ~p ~p ~p ~p ~n",[H, Ref, T1, T2, Ref/T1, Ref/T2]),
	test(Worker,List,Ref).

%
% SIMPLE MIDDLE MAN
%
simple_middle_man() ->
	register(input, spawn(?MODULE, input, [])),
	register(output, spawn(?MODULE, output, [])),
	register(middle, spawn_link(?MODULE, middle, [whereis(input),whereis(output)])),
	ok.
	
input() ->
	Middle = whereis(middle),
	receive
		{km, Value} ->
			% io:format("Port (input): send {~p, km, ~p} ~n", [self(),Value]),
			Middle ! {self(), km, Value},
			ok;
		{_, _} ->
			io:format("Port (input): invalid {km, <number>} expected. ~n"),
			error;
		{Middle, km, Value} ->
			io:format("Port (input): receive {km, ~p} ~n", [Value])
	end,
	input().

output() ->
	Middle = whereis(middle),
	receive
		{miles, Value} ->
			% io:format("Port (output): send {~p, miles, ~p} ~n", [self(),Value]),
			Middle ! {self(), miles, Value},
			ok;
		{_, _} ->
			io:format("Port (output): invalid {miles, <number>} expected. ~n"),
			error;
		{Middle, miles, Value} ->
			io:format("Port (output): receive {miles, ~p} ~n", [Value])
	end,
	output().

middle(Input, Output) ->
	receive
		{Input, km, Value} ->
			Output ! {self(), miles, Value / 1.60934};
		{Output, miles, Value} ->
			Input ! {self(), km, Value * 1.60934};
		_ ->
			error
	end,
	middle(Input, Output).

%
% PARALLEL ANY TAGGED MAX TIME
%
pmap_any_tagged_max_time(F, L, MaxTime) ->
	S = self(),
	Pids = [spawn(fun() -> S ! {self(), {I, F(I)}} end) || I <- L],
	% spawn(fun() -> receive after MaxTime -> S ! {stop}, killall(Pids), exit(S, kill) end end),
	collect_non_stable_max_time(Pids, MaxTime).

collect_non_stable_max_time(Pids, MaxTime) when MaxTime > 0 ->
	receive
		after
			MaxTime ->
				killall(Pids)
	end,
	collect_non_stable_max_time(Pids, 0);
collect_non_stable_max_time([_|Pids], 0) ->
	receive 
		{_, Value} ->
			[Value] ++ collect_non_stable_max_time(Pids, 0)
		after 
			0 ->
				[] ++ collect_non_stable_max_time(Pids, 0)
	end;
collect_non_stable_max_time([], 0) ->
	[].
	
killall([Pid|Pids]) ->
	exit(Pid,kill),
	killall(Pids);
killall([]) ->
	ok.

%
% PARALLEL ANY TAGGED
%
pmap_any_tagged(F, L) ->
 	S = self(),
	Pids = [spawn(fun() -> S ! {self(), {I, F(I)}} end) || I <- L],
	collect_non_stable(Pids).

%
% PARALLEL ANY
%
pmap_any(F, L) ->
 	S = self(),
	Pids = [spawn(fun() -> S ! {self(), F(I)} end) || I <- L],
	collect_non_stable(Pids).

collect_non_stable([_|Pids]) ->
	receive 
		{_, Value} ->
			[Value] ++ collect_non_stable(Pids)
	end;
collect_non_stable([]) ->
	[].

%
% PARALLEL WITH MAX WORKERS
%
pmap_max(F, L, MaxWorkers) when length(L) < MaxWorkers ->
	pmap_max(F, L, length(L));
pmap_max(F, L, MaxWorkers) when MaxWorkers > 0 ->
	S = self(),
	Workers = lists:map(fun(I) ->
		spawn(fun() -> 
			worker(S, F, I) 
		end) 
	end, lists:seq(1, MaxWorkers)),
	spawn(fun() -> scheduler(Workers, L, MaxWorkers, 0) end),
	collect_max(MaxWorkers, 0).

collect_max(0, _) ->
	[];
collect_max(MaxWorkers, ID) ->
	receive
		{ID, {_, Value}} ->
			[Value|collect_max(MaxWorkers, ID + 1)];
		{stop} ->
			collect_max(MaxWorkers-1, ID)
	end.

scheduler([Worker|Workers], [H|L], MaxWorkers, ID) when MaxWorkers > 0 ->
	Worker ! {run, self(), ID, H},
	scheduler(Workers ++ [Worker],L, MaxWorkers - 1, ID + 1);
scheduler(Workers,[H|L], 0, ID) ->
	receive 
		{next, Worker} ->
			Worker ! {run, self(), ID, H},
			scheduler(Workers, L, 0, ID + 1)
	end;
scheduler([_|Workers],[], 0, ID) ->
	receive 
		{next, Worker} ->
			Worker ! {stop},
			scheduler(Workers, [], 0, ID)
	end;
scheduler([],[], 0, _) ->
	ok.

worker(Parent, F, I) ->
	receive
		{run, Scheduler, ID, Value} ->
			Result = F(Value),
			Scheduler ! {next, self()},
			Parent ! {ID, {Value, Result}},
			worker(Parent, F, I);
		{stop} ->
			Parent ! {stop},
			ok
	end.









sleep(T) ->
	receive
		after
			T*1000 ->
				ok
end.

%
% SEQUENTIAL
%
smap(_, []) -> 
	[];
smap(F, [H|T]) -> 
	[F(H) | smap(F, T)].


fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).


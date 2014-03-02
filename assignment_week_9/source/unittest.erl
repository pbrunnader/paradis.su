% 
% This is the "week9 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(unittest).
-compile(export_all).

test_all() ->
	ok = test_2_1(),
	ok = test_2_2(),
	ok = test_2_3(),
	ok = test_2_4(),
	ok = test_3_1(),
	ok.
		

test_2_1() ->
	T = maps,
	io:format("pmap_max(F,L,Max)~n"),
	L = [1,2,3,4,5,6,7,8,9,10,15,25,35],
	Result = T:pmap_max(fun fib/1, L, 1),
	Result = T:pmap_max(fun fib/1, L, 3),
	Result = T:pmap_max(fun fib/1, L, 5),
	Result = T:pmap_max(fun fib/1, L, 7),
	Result = T:pmap_max(fun fib/1, L, 9),
	Result = T:pmap_max(fun fib/1, L, 11),
	Result = T:pmap_max(fun fib/1, L, 13),
	Result = T:pmap_max(fun fib/1, L, 15),
	ok.

test_2_2() ->
	T = maps,
	io:format("pmap_any(F,L)~n"),
	[1,6765,9227465] = T:pmap_any(fun fib/1, [35,2,20]),
	ok.

test_2_3() ->
	T = maps,
	io:format("pmap_any_tagged(F,L)~n"),
	[{2,1},{20,6765},{35,9227465}] = T:pmap_any_tagged(fun fib/1, [35,2,20]),
	ok.

test_2_4() ->
	T = maps,
	io:format("pmap_any_tagged_max_time(F,L,MaxTime)~n"),
	[{2,1},{20,6765},{35,9227465}] = T:pmap_any_tagged_max_time(fun fib/1, [35,2,456,20],2000),
	ok.

test_3_1() ->
	T = maps,
	io:format("Simple Middle Man~n"),
	T:simple_middle_man(),
	whereis(input) ! {km, 3},
	whereis(input) ! {miles, 3},
	whereis(output) ! {km, 3},
	whereis(output) ! {miles, 3},
	T:stop(),
	ok.


fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

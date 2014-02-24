% 
% This is the "week8 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(unittest).
-export([test_all/0,test_country/0,test_ets_dets/0,test_mnesia/0,test_tracker/0,benchmark/0]).

test_all() ->
	ok = test_mnesia(),
	ok = test_country(),
	ok = test_ets_dets(),
	ok = test_tracker(),
	success.


test_country() ->
	M = country_codes,
		io:format("normal: ETS~n"),
	I = M:start(),
		io:format("start() = ~p~n",[I]),
		io:format("loopup(\"SE\") = {ok, \"Sweden\"}~n"),
	{ok, "Sweden"} = M:lookup(I, "SE"),
		io:format("loopup(\"AT\") = {ok, \"Austria\"}~n"),
	{ok, "Austria"} = M:lookup(I, "AT"),
		io:format("loopup(\"JA\") = error~n"),
	error = M:lookup(I, "JA"),
		io:format("loopup(\"XY\") = error~n"),
	error = M:lookup(I, "XY"),
		io:format("stop() = ok~n"),
	ok = M:stop(I),
	ok.

test_ets_dets() ->
	M = ets_dets,
		io:format("advanced: ETS and DETS~n"),
		io:format("# Records Time (ets) ~n"),
		io:format("time(ets, 100) = ok~n"),
	ok = M:time(ets, 100),
		io:format("time(ets, 1000) = ok~n"),
	ok = M:time(ets, 1000),
		io:format("time(ets, 10000) = ok~n"),
	ok = M:time(ets, 10000),
		io:format("# Records Time (dets) ~n"),
		io:format("time(dets, 100) = ok~n"),
	ok = M:time(dets, 100),
		io:format("time(dets, 1000) = ok~n"),
	ok = M:time(dets, 1000),
		io:format("time(dets, 10000) = ok~n"),
	ok = M:time(dets, 10000),
	ok.

test_mnesia() ->
		io:format("normal: Mnesia~n"),
	M = country_codes_db,
	
	% executed once, for unit test purpose 
	% deleted and created new
		io:format("do_this_once()~n"),
	M:do_this_once(),
	
		io:format("start() = ok~n"),
	ok = M:start(),
		io:format("select(\"SE\") = {ok, \"Sweden\"}~n"),
	{ok, "Sweden"} = M:select("SE"),
		io:format("select(\"AT\") = {ok, \"Austria\"}~n"),
	{ok, "Austria"} = M:select("AT"),
		io:format("update(\"SE\",\"SwEdEn\") = ok~n"),
	ok = country_codes_db:update("SE","SwEdEn"),
		io:format("update(\"AT\",\"AUSTRIA\") = ok~n"),
	ok = country_codes_db:update("AT","AUSTRIA"),
		io:format("select(\"SE\") = {ok, \"SwEdEn\"}~n"),
	{ok, "SwEdEn"} = M:select("SE"),
		io:format("select(\"AT\") = {ok, \"AUSTRIA\"}~n"),
	{ok, "AUSTRIA"} = M:select("AT"),
		io:format("stop()~n"),
	M:stop(),
	ok.

test_tracker() ->
		io:format("normal:A simple file tracker~n"),
	M = tracker,
		io:format("start() = {ok, _}~n"),
	{ok, _} = M:start(),
		io:format("i_want(\"secret.txt\",\"168.192.0.10\") = [\"168.192.0.10\"]~n"),
	["168.192.0.10"] = M:i_want("secret.txt","168.192.0.10"),
		io:format("i_want(\"secret.txt\",\"168.192.0.18\") = [\"168.192.0.10\",\"168.192.0.18\"]~n"),
	["168.192.0.10","168.192.0.18"] = M:i_want("secret.txt","168.192.0.18"),
		io:format("i_want(\"secret.txt\",\"168.192.0.88\") = [\"168.192.0.10\",\"168.192.0.18\",\"168.192.0.88\"]~n"),
	["168.192.0.10","168.192.0.18","168.192.0.88"] = M:i_want("secret.txt","168.192.0.88"),
		io:format("i_want(\"file.txt\",\"168.192.0.18\") = [\"168.192.0.18\"]~n"),
	["168.192.0.18"] = M:i_want("file.txt","168.192.0.18"),
		io:format("who_wants(\"secret.txt\") = [\"168.192.0.10\",\"168.192.0.18\",\"168.192.0.88\"]~n"),
	["168.192.0.10","168.192.0.18","168.192.0.88"] = M:who_wants("secret.txt"),
		io:format("who_wants(\"file.txt\") = [\"168.192.0.18\"]~n"),
	["168.192.0.18"] = M:who_wants("file.txt"),

		io:format("i_am_leaving(\"168.192.0.18\") = ok~n"),
	ok = M:i_am_leaving("168.192.0.18"),
		io:format("who_wants(\"secret.txt\") = [\"168.192.0.10\",\"168.192.0.88\"]~n"),
	["168.192.0.10","168.192.0.88"] = M:who_wants("secret.txt"),
		io:format("who_wants(\"file.txt\") = []~n"),
	[] = M:who_wants("file.txt"),
		io:format("ping(\"168.192.0.10\") = ok~n"),
	ok = M:ping("168.192.0.10"),
	sleep(6),
		io:format("who_wants(\"secret.txt\") = [\"168.192.0.10\",\"168.192.0.88\"]~n"),
	["168.192.0.10","168.192.0.88"] = M:who_wants("secret.txt"),
		io:format("ping(\"168.192.0.10\") = ok~n"),
	ok = M:ping("168.192.0.10"),
	sleep(6),
		io:format("who_wants(\"secret.txt\") = [\"168.192.0.10\"]~n"),
	["168.192.0.10"] = M:who_wants("secret.txt"),
		io:format("stop()~n"),
	M:stop(),
	ok.
	
benchmark() ->
	io:format("Benchmarks form 10 to 1000000 for ets and dets~n"),
	ets_dets:benchmark(ets),
	ets_dets:benchmark(dets),
	ok.
	
sleep(T) ->
	io:format("sleep(~p)~n",[T]),
	receive
		after T*1000 ->
			true
	end.
	
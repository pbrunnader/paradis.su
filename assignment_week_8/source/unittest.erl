% 
% This is the "week8 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(unittest).
-export([test_all/0,test_country/0,test_ets_dets/0,test_mnesia/0,test_tracker/0]).

%
% !!! THIS HAS TO BE EXECUTED ONCE !!!
%
% > country_codes_db:do_this_once().
%
% !!! THIS HAS TO BE EXECUTED ONCE !!!
%


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
	{ok, "Sweden"} = M:lookup(I, "SE"),
	{ok, "Austria"} = M:lookup(I, "AT"),
	error = M:lookup(I, "JA"),
	error = M:lookup(I, "XY"),
	ok = M:stop(I),
	ok.

test_ets_dets() ->
	M = ets_dets,
	io:format("advanced: ETS and DETS~n"),
	io:format("# Records Time (ets) ~n"),
	ok = M:time(ets, 1000),
	ok = M:time(ets, 10000),
	ok = M:time(ets, 100000),
	io:format("# Records Time (dets) ~n"),
	ok = M:time(dets, 1000),
	ok = M:time(dets, 10000),
	ok = M:time(dets, 100000),
	ok.

test_mnesia() ->
	io:format("normal: Mnesia~n"),
	M = country_codes_db,
	
	% executed once
	% M:do_this_once(),
	
	ok = M:start(),
	{ok, "Sweden"} = M:select("SE"),
	{ok, "Austria"} = M:select("AT"),
	ok = country_codes_db:update("SE","SwEdEn"),
	ok = country_codes_db:update("AT","AUSTRIA"),
	{ok, "SwEdEn"} = M:select("SE"),
	{ok, "AUSTRIA"} = M:select("AT"),
	ok.

test_tracker() ->
	io:format("normal:A simple file tracker~n"),
	M = tracker,
	{ok, _} = M:start(),
	["168.192.0.10"] = M:i_want("secret.txt","168.192.0.10"),
	["168.192.0.10","168.192.0.18"] = M:i_want("secret.txt","168.192.0.18"),
	["168.192.0.10","168.192.0.18","168.192.0.88"] = M:i_want("secret.txt","168.192.0.88"),
	["168.192.0.18"] = M:i_want("file.txt","168.192.0.18"),
	["168.192.0.10","168.192.0.18","168.192.0.88"] = M:who_wants("secret.txt"),
	["168.192.0.18"] = M:who_wants("file.txt"),
	ok = M:i_am_leaving("168.192.0.18"),
	["168.192.0.10","168.192.0.88"] = M:who_wants("secret.txt"),
	[] = M:who_wants("file.txt"),
	ok.
	
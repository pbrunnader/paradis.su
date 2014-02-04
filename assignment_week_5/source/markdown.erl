% 
% This is the "week5 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(markdown).
-export([parse_binary/1,parse_to_html/1,expand_file/1]).

-spec parse_binary(_) -> [{'h1' | 'h2' | 'par' | bitstring(),bitstring()}].
parse_binary(B) ->
	parse_binary(B,[]).

-spec parse_binary(_,[{'h1' | 'h2' | 'par' | bitstring(),bitstring()}]) -> [{'h1' | 'h2' | 'par' | bitstring(),bitstring()}].
parse_binary(B,T) when B == <<>> ->
	T; 
parse_binary(<< "##", B/binary >>,T) -> 
	L = [{h2,<<>>}] ++ T, 
	parse_char(B,L);
parse_binary(<< "#", B/binary >>,T) -> 
	L = [{h1,<<>>}] ++ T, 
	parse_char(B,L);
parse_binary(<< X:8, B/binary >>,T) -> 
	[H|S] = lists:reverse(T),
	[Y|_] = tuple_to_list(H),
	if
		Y == par ->
			L = [H] ++ lists:reverse(S);
		true ->
			L = [{par,<<>>}] ++ T
	end,
	parse_char(<<X,B/binary>>,L).

-spec parse_char(bitstring(),[{'h1' | 'h2' | 'par' | bitstring(),bitstring()},...]) -> [{'h1' | 'h2' | 'par' | bitstring(),bitstring()}].
parse_char(B,[H|T]) when B == <<>> ->
	T ++ [H];
parse_char(<< Char:8, B/binary >>,[H|T]) when Char == $\n ->
	[X|[Y|_]] = tuple_to_list(H),
	parse_binary(B,T ++ [{ X, << Y/binary, Char >> }]);
parse_char(<< Char:8, B/binary >>,[H|T]) ->
	[X|[Y|_]] = tuple_to_list(H),
	parse_char(B,[{ X, << Y/binary, Char >> }] ++ T).
	

-spec parse_to_html(_) -> binary().
parse_to_html(T) when T == {}; T == [] ->
	<<>>;
parse_to_html({h1,<<B/binary>>}) ->
	<< "<h1>", B/binary, "</h1>" >>;
parse_to_html({h2,<<B/binary>>}) ->
	<< "<h2>", B/binary, "</h2>" >>;
parse_to_html({par,<<B/binary>>}) ->
	<< "<p>", B/binary, "</p>" >>;
parse_to_html([H|T]) ->
	A = parse_to_html(H),
	B = parse_to_html(T),
	<< A/binary, B/binary >>.

-spec expand_file(atom() | binary() | [atom() | [any()] | char()]) -> 'ok' | {'error',atom()}.
expand_file(F) ->
	{Status, Binary} = file:read_file(F),
	if
		Status == ok ->
			HTML = markdown:parse_to_html( markdown:parse_binary( Binary ) ),
			file:write_file("File.html", HTML);
		true ->
			throw("Could not read file: does not exist!")
	end.

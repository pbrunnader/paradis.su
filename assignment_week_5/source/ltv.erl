% 
% This is the "week5 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(ltv).
-export([encode_seq/1,decode_seq/1]).

encode_seq([H|T]) when erlang:length(T) == 0 -> 
	encode(H);
encode_seq([H|T]) -> 
	B1 = encode(H),
	B2 = encode_seq(T),
	<<B1/binary, B2/binary>>.

encode(V) when is_list(V) ->
	Binary = term_to_binary(V),
	BinarySize = bit_size(Binary),
	<<1:1/big-signed-integer-unit:8, BinarySize:4/big-signed-integer-unit:8, Binary/binary >>;
encode(V) when is_integer(V) ->
	Binary = term_to_binary(V),
	BinarySize = bit_size(Binary),
	<<2:1/big-signed-integer-unit:8, BinarySize:4/big-signed-integer-unit:8, Binary/binary >>;
encode(V) when is_float(V) ->
	Binary = term_to_binary(V),
	BinarySize = bit_size(Binary),
	<<3:1/big-signed-integer-unit:8, BinarySize:4/big-signed-integer-unit:8, Binary/binary >>;
encode(_) ->
	throw("Invalid parameter given.").


decode_seq(B) when <<>> == B -> 
	[];
decode_seq(<<Type:1/big-signed-integer-unit:8, Size:4/big-signed-integer-unit:8, Binary/binary>>) when Type == 1; Type == 2; Type == 3 -> 
	<<BinaryValue:Size/binary-unit:1, RestBinary/binary>> = Binary,
	[binary_to_term(BinaryValue)] ++ decode_seq(RestBinary);
decode_seq(<<_:1/big-signed-integer-unit:8, _:4/big-signed-integer-unit:8, _/binary>>) -> 
	throw("Invalid value-type transmitted.").

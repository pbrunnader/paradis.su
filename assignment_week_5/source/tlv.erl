% 
% This is the "week5 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(tlv).
-export([encode_seq/1,decode_seq/1]).


-spec encode_seq(list()) -> binary().
encode_seq([H|T]) when erlang:length(T) == 0 -> 
	encode(H);
encode_seq([H|T]) -> 
	B1 = encode(H),
	B2 = encode_seq(T),
	<<B1/binary, B2/binary>>.

-type datatype() :: list() | integer() | float().
-spec encode(datatype()) -> binary().
encode(V) when is_list(V), length(V) > 0 ->
	BinarySize = length(V),
	Binary = list_to_binary(V),
	<<1:1/big-signed-integer-unit:8, BinarySize:4/big-signed-integer-unit:8, Binary/binary >>;
encode(V) when is_integer(V), V =< 2147483647, V >= -2147483648 ->
	<<2:1/big-signed-integer-unit:8, 4:4/big-signed-integer-unit:8, V:4/big-signed-integer-unit:8 >>;
encode(V) when is_float(V) ->
	% The accuracy of float numbers can not be garanteed - natural behaviour of single precision - used double precision for better accuracy !!!
	<<3:1/big-signed-integer-unit:8, 4:4/big-signed-integer-unit:8, V:64/float >>;
encode(V) when is_integer(V) ->
	throw("Invalid Integer value! The accepted range is from 2147483647 to -2147483648.");
encode(V) when is_integer(V) ->
	throw("Invalid data-type given.").
	

-spec decode_seq(binary()) -> list().
decode_seq(B) when <<>> == B -> 
	[];
decode_seq(<<1:1/big-signed-integer-unit:8, BinarySize:4/big-signed-integer-unit:8, Binary/binary >>) ->
	<<BinaryValue:BinarySize/binary-unit:8, RestBinary/binary>> = Binary,
	[binary_to_list(BinaryValue)] ++ decode_seq(RestBinary);
decode_seq(<<2:1/big-signed-integer-unit:8, 4:4/big-signed-integer-unit:8, V:4/big-signed-integer-unit:8, RestBinary/binary>>) -> 
	[V] ++ decode_seq(RestBinary);
decode_seq(<<3:1/big-signed-integer-unit:8, 4:4/big-signed-integer-unit:8, V:64/float, RestBinary/binary>>) -> 
	% The accuracy of float numbers can not be garanteed - natural behaviour of single precision - used double precision for better accuracy !!!
	[V] ++ decode_seq(RestBinary);
decode_seq(<<_:1/big-signed-integer-unit:8, _:4/big-signed-integer-unit:8, _/binary>>) -> 
	throw("Invalid data-type transmitted or length of data.").

% 
% This is the "week5 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(tlv).
-export([encode_seq/1,decode_seq/1,safe_encode_seq/1,safe_decode_seq/1]).


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


-spec safe_encode_seq(list()) -> binary().
safe_encode_seq([H|T]) when erlang:length(T) == 0 -> 
	safe_encode(H);
safe_encode_seq([H|T]) -> 
	B1 = safe_encode(H),
	B2 = safe_encode_seq(T),
	<<B1/binary, B2/binary>>.


-spec safe_encode(integer()) -> binary().
% signed 32-bits
safe_encode(V) when is_integer(V), V >= -2147483648, V =< 2147483647 -> 
	<<1:1/big-signed-integer-unit:8, 4:4/big-signed-integer-unit:8, V:4/big-signed-integer-unit:8 >>;
% unsigned 32-bits
safe_encode(V) when is_integer(V), V >= 0, V =< 4294967295 -> 
	<<2:1/big-signed-integer-unit:8, 4:4/big-signed-integer-unit:8, V:4/big-unsigned-integer-unit:8 >>;
% signed 64-bits
safe_encode(V) when is_integer(V), V >= -9223372036854775808, V =< 9223372036854775807 -> 
	<<3:1/big-signed-integer-unit:8, 8:4/big-signed-integer-unit:8, V:8/big-signed-integer-unit:8 >>;
% unsigned 64-bits
safe_encode(V) when is_integer(V), V >= 0, V =< 18446744073709551615 -> 
	<<4:1/big-signed-integer-unit:8, 8:4/big-signed-integer-unit:8, V:8/big-unsigned-integer-unit:8 >>;
safe_encode(V) when is_integer(V), V > 0 ->
	throw("Invalid data: value is to big!");
safe_encode(V) when is_integer(V), V < 0 ->
	throw("Invalid data: value is to small!");
safe_encode(_) ->
	throw("Invalid data: unknown data format given!").


-spec safe_decode_seq(binary()) -> list().
safe_decode_seq(B) when <<>> == B -> 
	[];
safe_decode_seq(<<1:1/big-signed-integer-unit:8, 4:4/big-signed-integer-unit:8, V:4/big-signed-integer-unit:8, RestBinary/binary>>) -> 
	[V] ++ safe_decode_seq(RestBinary);
safe_decode_seq(<<2:1/big-signed-integer-unit:8, 4:4/big-signed-integer-unit:8, V:4/big-unsigned-integer-unit:8, RestBinary/binary>>) -> 
	[V] ++ safe_decode_seq(RestBinary);
safe_decode_seq(<<3:1/big-signed-integer-unit:8, 8:4/big-signed-integer-unit:8, V:8/big-signed-integer-unit:8, RestBinary/binary>>) -> 
	[V] ++ safe_decode_seq(RestBinary);
safe_decode_seq(<<4:1/big-signed-integer-unit:8, 8:4/big-signed-integer-unit:8, V:8/big-unsigned-integer-unit:8, RestBinary/binary>>) -> 
	[V] ++ safe_decode_seq(RestBinary).
	

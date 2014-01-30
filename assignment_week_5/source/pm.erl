% 
% This is the "week5 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(pm).
-export([binary_to_packet/1,packet_to_binary/1,term_to_packet/1,packet_to_term/1]).


-type packet() :: binary().
-spec binary_to_packet(list()) -> packet().
binary_to_packet(B) when is_binary(B) -> 
	BinarySize = byte_size(B),
	<<BinarySize:4/big-unsigned-integer-unit:8, B/binary>>.


-spec packet_to_binary(packet()) -> binary().
packet_to_binary(<<BinarySize:4/big-unsigned-integer-unit:8, Binary/binary>>) when BinarySize == byte_size(Binary) -> 
	Binary;
packet_to_binary(<<_:4/big-unsigned-integer-unit:8, _/binary>>) ->
	throw("Real binary size does not match with expected one.").


-spec term_to_packet(term()) -> packet().
term_to_packet(T) when not is_binary(T) -> 
	Binary = term_to_binary(T),
	binary_to_packet(Binary).

	
-spec packet_to_term(packet()) -> term().
packet_to_term(P) when is_binary(P) -> 
	Binary = packet_to_binary(P),
	binary_to_term(Binary).


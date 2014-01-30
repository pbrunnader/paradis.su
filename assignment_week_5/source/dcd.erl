% 
% This is the "week5 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(dcd).
-export([term_to_packet_with_checksum/1,packet_to_term_with_checksum/1]).


-type packet() :: binary().
-spec binary_to_packet(binary()) -> packet().
binary_to_packet(B) when is_binary(B) -> 
	BinarySize = byte_size(B),
	Checksum = erlang:md5(B),
	<<BinarySize:4/big-unsigned-integer-unit:8, Checksum/binary, B/binary>>.


-spec packet_to_binary(packet()) -> binary().
packet_to_binary(<<BinarySize:4/big-unsigned-integer-unit:8, Checksum:16/binary-unit:8, Binary/binary>>) when BinarySize == byte_size(Binary) -> 
	Chk = erlang:md5(Binary),
	if
		Checksum == Chk -> 
			Binary;
		true -> 
			throw("Packet was altered during transmission.")
	end;
packet_to_binary(<<_:4/big-unsigned-integer-unit:8, _:16/binary-unit:8, _/binary>>) ->
	throw("Real binary size does not match with expected one.").


-spec term_to_packet_with_checksum(term()) -> packet().
term_to_packet_with_checksum(T) when not is_binary(T) -> 
	Binary = term_to_binary(T),
	binary_to_packet(Binary).

	
-spec packet_to_term_with_checksum(packet()) -> term().
packet_to_term_with_checksum(P) when is_binary(P) -> 
	Binary = packet_to_binary(P),
	binary_to_term(Binary).

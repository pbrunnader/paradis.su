-module(unittest).
-export([test_tlv/0, test_safe_tlv/0, test_pm/0, test_dcd/0, test_all/0, test_markdown/0]).

test_all() ->
	test_tlv(),
	test_safe_tlv(),
	test_pm(),
	test_dcd(),
	test_markdown(),
	all.

test_safe_tlv() ->
	M = tlv,
	
	% test of signed 32 bit integer
	I1 = [-2147483648,-10,0,10,1234567890,2147483647],
	T1 = M:safe_encode_seq(I1),
	I1 = M:safe_decode_seq(T1),

	% test of unsigned 32 bit integer
	I2 = [2147483648,4294967295],
	T2 = M:safe_encode_seq(I2),
	I2 = M:safe_decode_seq(T2),

	% test of signed 64 bit integer
	I3 = [-9223372036854775808,9223372036854775807],
	T3 = M:safe_encode_seq(I3),
	I3 = M:safe_decode_seq(T3),

	% test of unsigned 64 bit integer
	I4 = [9223372036854775808,18446744073709551615],
	T4 = M:safe_encode_seq(I4),
	I4 = M:safe_decode_seq(T4),
	
	try
		I5 = [18446744073709551616],
		T5 = M:safe_encode_seq(I5)
	catch
		throw:Term5 -> Term5,
		"Invalid data: value is to big!" = Term5
	end,

	try
		I6 = [-9223372036854775809],
		T6 = M:safe_encode_seq(I6)
	catch
		throw:Term6 -> Term6,
		"Invalid data: value is to small!" = Term6
	end,

	try
		I7 = ["abc"],
		T7 = M:safe_encode_seq(I7)
	catch
		throw:Term7 -> Term7,
		"Invalid data: unknown data format given!" = Term7
	end,
	
	yeah.

test_tlv() ->
    M = tlv,

	I1 = [9],
	T1 = M:encode_seq(I1),
	I1 = M:decode_seq(T1),

	I2 = [1,2,3],
	T2 = M:encode_seq(I2),
	I2 = M:decode_seq(T2),

	% I3 = [1.23,2.34,3.45],
	% T3 = M:encode_seq(I3),
	% I3 = M:decode_seq(T3),

	I4 = ["a","b","c"],
	T4 = M:encode_seq(I4),
	I4 = M:decode_seq(T4),

	I5 = [1983,1.234,"abced"],
	T5 = M:encode_seq(I5),
	I5 = M:decode_seq(T5),

	I6 = [0.3333333],
	T6 = M:encode_seq(I6),
	I6 = M:decode_seq(T6),

	I7 = [2147483648],
	try
		T7 = M:encode_seq(I7),
		I7 = M:decode_seq(T7)
	catch
		throw:Term7 -> Term7,
		"Invalid Integer value! The accepted range is from 2147483647 to -2147483648." = Term7
	end,

	T8 = <<0,0,0,0,24,131,97,123,2,0,0,0,48,131,98,0,0,1,200>>,
	try
		M:decode_seq(T8)
	catch
		throw:Term8 -> Term8,
		"Invalid data-type transmitted or length of data." = Term8
	end,
	
    juhu.


test_pm() ->
	M = pm,
	
	B1 = <<123>>,
	P1 = M:binary_to_packet(B1),
	B1 = M:packet_to_binary(P1),

	B2 = atom_to_binary(abcdef,utf8),
	P2 = M:binary_to_packet(B2),
	B2 = M:packet_to_binary(P2),

	B3 = <<"This is a sample text">>,
	P3 = M:binary_to_packet(B3),
	B3 = M:packet_to_binary(P3),

	B4 = "abc",
	P4 = M:term_to_packet(B4),
	B4 = M:packet_to_term(P4),

	B5 = 9876543210,
	P5 = M:term_to_packet(B5),
	B5 = M:packet_to_term(P5),

	B6 = 123456789,
	P6 = M:term_to_packet(B6),
	B6 = M:packet_to_term(P6),
	try
		B6 = M:packet_to_term(<<0,0,0,6,131,98,7,91,205>>)
	catch
		throw:Term6 -> Term6,
		"Real binary size does not match with expected one." = Term6
	end,

	yes.
	
test_dcd() ->
	M = dcd,

	B1 = "abc",
	P1 = M:term_to_packet_with_checksum(B1),
	B1 = M:packet_to_term_with_checksum(P1),

	B2 = 9876543210,
	P2 = M:term_to_packet_with_checksum(B2),
	B2 = M:packet_to_term_with_checksum(P2),

	B3 = 123456789,
	P3 = M:term_to_packet_with_checksum(B3),
	B3 = M:packet_to_term_with_checksum(P3),
	try
		B3 = M:packet_to_term_with_checksum(<<0,0,0,6,50,99,161,23,11,249,6,97,133,136,218,184,242,36,65,234,131,1,2,91,205,21>>)
	catch
		throw:Term3 -> Term3,
		"Packet was altered during transmission." = Term3
	end,
	
	try
		M:packet_to_term_with_checksum(<<0,0,0,6,50,99,161,23,11,249,6,97,133,136,218,184,242,36,65,234,131,98,7>>)
	catch
		throw:Term4 -> Term4,
		"Real binary size does not match with expected one." = Term4
	end,
	
	nice.

test_markdown() ->
	M = markdown,
	
	try
		M:expand_file("NotExistingFile.txt")
	catch
		throw:Term -> Term,
		"Could not read file: does not exist!" = Term
	end,
	
	M:expand_file("File.txt"),
	file_created.
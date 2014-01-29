-module(unittest).
-export([test_ltv/0, test_pm/0, test_all/0]).

test_all() ->
	test_ltv(),
	test_pm(),
	all.

test_ltv() ->
    M = ltv,

	I1 = [9],
	T1 = M:encode_seq(I1),
	I1 = M:decode_seq(T1),

	I2 = [1,2,3],
	T2 = M:encode_seq(I2),
	I2 = M:decode_seq(T2),

	I3 = [1.23,2.34,3.45],
	T3 = M:encode_seq(I3),
	I3 = M:decode_seq(T3),

	I4 = ["a","b","c"],
	T4 = M:encode_seq(I4),
	I4 = M:decode_seq(T4),

	I5 = [1983,0.12345,"abced"],
	T5 = M:encode_seq(I5),
	I5 = M:decode_seq(T5),

	I6 = [1/3,1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000],
	T6 = M:encode_seq(I6),
	I6 = M:decode_seq(T6),

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

	jaha.
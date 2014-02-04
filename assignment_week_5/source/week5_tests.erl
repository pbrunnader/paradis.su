-module(week5_tests).
-export([test_all/0]).


test_all() ->
    T = week5_solutions,
    test_simple_TLV(T),
    test_bin_packet(T),
    test_term_packet(T),
    io:fwrite("All tests ok\n").

test_simple_TLV(T) ->
    Bin = <<2, 0, 0, 0, 1, "1">>,
    Bin = T:encode_seq([1]),
    [1] = T:decode_seq(Bin),
    L = ["abc123", 17, 3.14],
    L = T:decode_seq(T:encode_seq(L)),
    io:fwrite("LTV simple test ok\n").

test_bin_packet(T) ->
    Bin = <<1:32/big, "1">>,
    Packet = {1, <<"1">>},
    Packet = T:binary_to_packet(Bin),
    Bin = T:packet_to_binary(Packet),
    Packet = T:binary_to_packet(T:packet_to_binary(Packet)),
    io:fwrite("Packet bin test ok\n").

test_term_packet(T) ->
    Term = {"123", abc},
    Term = T:packet_to_term(T:term_to_packet(Term)),
    io:fwrite("Packet term test ok\n").
% 
% This is the "week7 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(udp_test).
-export([start_server/0, client/3]).

start_server() ->
    spawn(fun() -> server(2000) end).

%% The server 		  
server(Port) ->
    {ok, Socket} = gen_udp:open(Port, [binary]),
    io:format("server opened socket:~p~n",[Socket]),
    loop(Socket).

loop(Socket) ->
    receive
		{udp, Socket, _, _, Binary} = Msg -> 
			io:format("server received: ~p~n",[Msg]),
			io:format("decrypt message: ~p~n",["SecretPassword"]),
			{email, From, Subject, Content} = binary_to_term(elib2_aes:decrypt("SecretPassword",Binary)),
			%% {ok, [[Path]]} = init:get_argument(home),
			
			Root = "./inbox",
			{ok, List} = file:list_dir(Root),
			Num = integer_to_list(erlang:length(List)),
			Path = Root ++ "/email-" ++ Num ++ ".txt",
			
			ok = file:write_file(lists:flatten(Path), term_to_binary({email, From, Subject, Content})),
			io:format("server saved message in ~p~n",[Path]),
			loop(Socket)
	end.



%% The client
client(From, Subject, Content) ->
    client("localhost", 2000, From, Subject, Content).

client(Host, Port, From, Subject, Content) ->
    {ok, Socket} = gen_udp:open(0, [binary]),
    io:format("client opened socket=~p~n",[Socket]),
	io:format("encrypt message: ~p~n",["SecretPassword"]),
    ok = gen_udp:send(Socket, Host, Port, elib2_aes:encrypt("SecretPassword",term_to_binary({email, From, Subject, Content}))),
    gen_udp:close(Socket).


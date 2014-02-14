% 
% This is the "week7 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(filesystem).
-export([list_dir/1, reverse_file/1, read_and_number_lines/1, get_config/2]).

list_dir(Dir) ->
	true = filelib:is_dir(Dir),
	{ok, List} = file:list_dir(Dir),
	read_item(List).
	
read_item(List) when List == [] ->
	[];
read_item([Item|Tail]) ->
	case filelib:is_dir(Item) of
		true -> 
			[{dir,Item}] ++ read_item(Tail);
		false -> 
			case filelib:is_file(Item) of
				true ->
					Size = filelib:file_size(Item),
					[{file,Item,Size}] ++ read_item(Tail);
				false ->
					error("not a file and not a directory")
			end
	end.

	

reverse_file(File) -> 
	{ok, S} = file:open(File, [read,write,raw,binary]),
	{ok, {file_info,Size,_,_,_,_,_,_,_,_,_,_,_,_}} = file:read_file_info(File),
	swap_character(S, 0, Size-1).

swap_character(File, Left, Right) when Left < Right, Left >= 0 ->
	{ok, L} = file:pread(File, Left, 1),
	{ok, R} = file:pread(File, Right, 1),
	
	ok = file:pwrite(File, Right, L),
	ok = file:pwrite(File, Left, R),
	swap_character(File, Left+1, Right-1);
swap_character(File, _, _) ->
	file:close(File).


read_and_number_lines(File) when is_list(File) ->
	{ok, S} = file:open(File, [read,raw,binary]),
	List = read_and_number_lines(S,1),
	file:close(S),
	List.

read_and_number_lines(File,Line) when is_integer(Line), Line > 0 ->
	case file:read_line(File) of 
		{ok, Data} ->
			[{Line, Data}] ++ read_and_number_lines(File,Line + 1);
		eof ->
			[]	
	end.	


get_config(_,[]) ->
	[];
get_config(File,Default) when is_list(Default) ->
	List = file_config(File),
	case List of
		[] ->
			Default;
		_ ->
			update_config(dict:from_list(List),Default)
	end.
	
update_config(List,[{Key,Default}]) -> 
	case dict:find(Key, List) of
		{ok, Value} ->
			[{Key, Value}];
		error ->
			[{Key, Default}]
	end;
update_config(List,[{Key,Default}|Tail]) -> 
	case dict:find(Key, List) of
		{ok, Value} ->
			[{Key, Value}] ++ update_config(List,Tail);
		error ->
			[{Key, Default}] ++ update_config(List,Tail)
	end.

file_config(File) ->
	{ok, Data} = file:consult(File), 
	Data.
	
	
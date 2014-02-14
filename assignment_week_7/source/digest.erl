% 
% This is the "week7 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(digest).
-export([compute_digest/2,check_digest/1]).

compute_digest(File, Blocksize) ->
	Digest = compute(File, Blocksize),
	file:write_file(File ++ ".digest", term_to_binary(Digest)),
	digest_computed.

	
compute(File, Blocksize) ->
	Size = filelib:file_size(File),
	{ok, S} = file:open(File, [read,raw,binary]),
	Chunks = compute_checksum(S, Size, Blocksize, 0),
	{size, Size, blocksize, Blocksize, checksums, Chunks}.

compute_checksum(File, Size, Blocksize, Position) when Size > Position  ->
	{ok, Chunk} = file:pread(File, Position, Blocksize),
	[erlang:md5(Chunk)] ++ compute_checksum(File, Size, Blocksize, Position + Blocksize);
compute_checksum(_, _, _, _) ->
	[].


check_digest(File) ->
	{ok, Binary} = file:read_file(File ++ ".digest"),
	{size, Size, blocksize, Blocksize, checksums, Chunks} = binary_to_term(Binary),
	{size, Size, blocksize, Blocksize, checksums, Chunks} = compute(File, Blocksize),
	digest_match.
% 
% This is the "week4 assignment" for the course "Parallel and distributed programming" 
% at the Stockholm University 
% 
% @author Peter Brunnader 
% @version 1.0
% 

-module(week4_solutions).
-export([factorial/1, rotate/2, expand_markup/1]).

% factorial implementation
factorial(0) -> 1;
factorial(N) -> N * factorial(N-1).

% rotate implementation
rotate(0,L) -> L;
rotate(N,L) -> 
  P = N rem count(L),
  if
    P>0 -> [H|T] = L, rotate(P-1,T ++ [H]);
    P<0 -> rotate(count(L)+P,L);
    true -> L
  end.

% count elements in list for rotate
count([]) -> 0;
count(L) -> [_|T] = L, 1 + count(T).




% expand markup
expand_markup(S) -> markup(S,1,[],[],[]).

markup(String,Begin,Result,Stack1,Stack2) ->
  End = string:len(String) + 1,
  Tag = string:substr(String, Begin, 2),
  Sym = string:substr(String, Begin, 1),
  Check = isOnStack(Tag,Stack1), 
  
  if 
    Check -> 
      [Head|Tail] = Stack1, 
      CC = isOnStack(Tag,Tail),
      % Num = erlang:length(Stack2),
      if
        CC -> markup(String, Begin, Result ++ "</" ++ Head ++ ">", Tail, Stack2 ++ [Head]); 
        Begin < End -> markup(String, Begin + 2, Result ++ "</" ++ Head ++ ">" ++ reOpen(Stack2), Tail ++ Stack2, []);
        true -> Result
      end;
    true ->
      if
        Tag == "**" -> markup(String, Begin + 2, Result ++ "<b>", ["b"] ++ Stack1, Stack2);
        Tag == "__" -> markup(String, Begin + 2, Result ++ "<i>", ["i"] ++ Stack1, Stack2);
        Begin < End -> markup(String, Begin + 1, Result ++ Sym, Stack1, Stack2);
        true -> Result
      end
  end.

reOpen([]) -> "";
reOpen(Stack) -> [Head|Tail] = Stack, "<" ++ Head ++ ">" ++ reOpen(Tail).

isOnStack(Tag,Stack) -> 
  if
    Tag == "**" -> lists:member("b", Stack);
    Tag == "__" -> lists:member("i", Stack); 
    true -> false
  end.

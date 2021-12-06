-module(day3).

%% API exports
-export([main/1]).

%%====================================================================
%% API functions
%%====================================================================

%% escript Entry point
main(_) ->
    Input = get_input(),
    part1(Input),
    part2(Input),
    erlang:halt(0).

%%====================================================================
%% Internal functions
%%====================================================================

get_input() ->
    case io:get_line("") of
        eof -> [];
        Line ->
            [string:trim(Line, trailing, "\n")] ++ get_input()
    end.

part1(Input) ->
    Compute = lists:foldl(fun (Line, Compute) ->
                                  add_to_compute(Line, Compute)
                          end,
                          [],
                          Input),
    {Gg, Espilon} = lists:foldl(fun (Res, {G, E}) ->
                                        What = case Res > length(Input) / 2 of
                                                   true -> {G ++ "1", E ++ "0"};
                                                   false -> {G ++ "0", E ++ "1"}
                                               end,
                                        What
                                end,
                                {"", ""},
                                Compute),
    Gamma = list_to_integer(Gg, 2),
    Epsilon = list_to_integer(Espilon, 2),
    io:fwrite("Part 1: ~.B~n", [Gamma * Epsilon]).

part2(Input) ->
    Oxygen = list_to_integer(compute_part2(Input,
                                           1,
                                           $1,
                                           $0),
                             2),
    Co2 = list_to_integer(compute_part2(Input, 1, $0, $1),
                          2),
    io:fwrite("Part 2: ~.B~n", [Oxygen * Co2]).

compute_part2([Input], _, _, _) -> Input;
compute_part2(Input, Index, Main, Second) ->
    Sum = lists:foldl(fun (X, Sum) ->
                              {N, _} =
                                  string:to_integer(string:chars(lists:nth(Index,
                                                                           X),
                                                                 1)),
                              Sum + N
                      end,
                      0,
                      Input),
    NewInput = lists:filter(fun (El) ->
                                    case Sum < length(Input) / 2 of
                                        true -> lists:nth(Index, El) == Main;
                                        false -> lists:nth(Index, El) == Second
                                    end
                            end,
                            Input),
    compute_part2(NewInput, Index + 1, Main, Second).

add_to_compute(Line, []) ->
    lists:map(fun (X) ->
                      {N, _} = string:to_integer(string:chars(X, 1)),
                      N
              end,
              Line);
add_to_compute(Line, Compute) ->
    lists:zipwith(fun (L, R) ->
                          {N, _} = string:to_integer(string:chars(L, 1)),
                          N + R
                  end,
                  Line,
                  Compute).

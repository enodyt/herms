%%%-------------------------------------------------------------------
%%% @author <matthias@doloops.net>
%%% @copyright (C) 2017, <matthias@doloops.net>
%%% @doc
%%%
%%% @end
%%% Created : 2017-12-31 13:19:36.638829
%%%-------------------------------------------------------------------
-module(hs_utils).

-export([ allowed_fields/1
        , changeset/2
        , token/0, token/1
        ]).

-define(DEFAULT_TOKEN_LENGTH, 64).

-include("hs_store.hrl").

-spec allowed_fields(sumo:sumo_schema()) -> [atom()].
allowed_fields(S) ->
  #{ fields := Fields } = sumo_internal:get_schema(S),
  lists:map(fun (#{ name := Name }) -> Name end, Fields).

-spec changeset(
  Mod::atom()
, sumo_changeset:params()
) -> sumo_changeset:changeset().
changeset(Mod, #{ id := Id }=Params) when is_binary(Id) ->
  case apply(Mod, read, [Id]) of
    {ok, Doc} ->
      Now = calendar:universal_time(),
      P2 = maps:put(updated, Now, Params),
      apply(Mod, changeset, [Doc, P2]);
    _ ->
      N = apply(Mod, new, [#{}]),
      apply(Mod, changeset, [N, Params])
  end;
changeset(Mod, Params) ->
  N = apply(Mod, new, [#{}]),
  apply(Mod, changeset, [N, Params]).

-spec token() -> hs_token().
token() ->
  token(?DEFAULT_TOKEN_LENGTH).
-spec token(integer()) -> hs_token().
token(L) ->
  Initial = rand:uniform(62) - 1,
  token(<<Initial>>, L).
-spec token(binary(), integer()) -> hs_token().
token(Bin, 1) ->
  Chars = <<"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890">>,
  << <<(binary_part(Chars, B, 1))/binary>> || <<B>> <= Bin >>;
token(Bin, Rem) ->
  Next = rand:uniform(62) - 1,
  token(<<Bin/binary, Next>>, Rem - 1).

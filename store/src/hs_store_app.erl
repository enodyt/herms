%%%-------------------------------------------------------------------
%% @doc hs_store public API
%% @end
%%%-------------------------------------------------------------------

-module(hs_store_app).

-behaviour(application).

%% Application callbacks
-export([ start/0, start/2
        , stop/0, stop/1
        , start_phase/3]).

%%====================================================================
%% API
%%====================================================================

-spec start() -> {ok, [atom()]}.
start() ->
  hs_store_sup:start_link().

-spec start(application:start_type(), any()) -> {ok, pid()}.
start(_StartType, _StartArgs) ->
  hs_store_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
  ok.

-spec stop() -> ok.
stop() ->
  application:stop(hs_store).

-spec start_phase(
  atom(), 
  StartType::applicication:start_type(), []
) -> ok | {error, _}.
start_phase(create_schema, _StartType, []) ->
  _ = application:stop(mnesia),
  Node = node(),
  io:format("~n~p:~p(~p) Node ~p~n", 
            [?MODULE, ?LINE, self(), Node]),
  case mnesia:create_schema([Node]) of
    ok -> ok;
    {error, {Node, {already_exists, Node}}} -> ok
  end,
  {ok, _} = application:ensure_all_started(mnesia),
  sumo:create_schema().

%%====================================================================
%% Internal functions
%%====================================================================

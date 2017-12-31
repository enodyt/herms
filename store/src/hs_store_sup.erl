%%%-------------------------------------------------------------------
%% @doc hs_store top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(hs_store_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
  RestartStrategy = one_for_one,
  MaxRestarts = 5,
  MaxTime = 3600,

  SupFlags = {RestartStrategy, MaxRestarts, MaxTime},

  Restart = permanent,
  Shutdown = 2000,
  Type = worker,

  AChild = {{local, 'hs_readings_worker'}, {hs_readings_worker, start_link, []},
            Restart, Shutdown, Type, [hs_readings_worker]},

  {ok, {SupFlags, [AChild]}}.

%%====================================================================
%% Internal functions
%%====================================================================

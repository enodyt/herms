%%%-------------------------------------------------------------------
%%% @author <matthias@doloops.net>
%%% @copyright (C) 2017, <matthias@doloops.net>
%%% @doc
%%%
%%% @end
%%% Created : 2017-12-31 11:37:41.414203
%%%-------------------------------------------------------------------
-module(hs_readings).

-behaviour(sumo_doc).

-include("include/hs_store.hrl").

-export([sumo_schema/0, sumo_sleep/1, sumo_wakeup/1]).

-export([ create/1
        , changeset/1, changeset/2
        , new/1
        ]).

%% -------------------------------------------------------------------
%% sumo_db behavior 
%% -------------------------------------------------------------------

%% @doc Part of the sumo_doc behavior.
-spec sumo_schema() -> sumo:schema().
sumo_schema() ->
  sumo:new_schema(?MODULE, [
    sumo:new_field(id,           binary,   [id, unique]),
    sumo:new_field(sensor,       custom,   [not_null, {type, term}]),
    sumo:new_field(value,        custom,   [not_null, {type, term}]),
    sumo:new_field(created,      datetime, [not_null])
  ]).

%% @doc Part of the sumo_doc behavior.
-spec sumo_sleep(hs_reading()) -> sumo:model().
sumo_sleep(Entity) -> Entity.

%% @doc Part of the sumo_doc behavior.
-spec sumo_wakeup(sumo:model()) -> hs_reading().
sumo_wakeup(Entity) -> Entity.

-spec new(map()) -> hs_reading().
new(Params) ->
  ID = hs_utils:token(),
  Created = calendar:universal_time(),
  maps:merge(Params, #{created => Created, id => ID}).

-spec create(sumo_changeset:params() | sumo_changeset:changeset()) -> 
  {'ok', hs_reading()} | {'error', sumo_changeset:changeset()}.
create(#{changes:=_, types:=_}=Changeset) ->
  case sumo_changeset:is_valid(Changeset) of
    true ->
      sumo:persist(Changeset);
    false ->
      {error, Changeset}
  end;
create(Params) ->
  create(changeset(Params)).

-spec changeset(sumo_changeset:params()) -> sumo_changeset:changeset().
changeset(Params) -> hs_utils:changeset(?MODULE, Params).
-spec changeset(
  map()
, sumo_changeset:params()
) -> sumo_changeset:changeset().
changeset(Init, Params) ->
  sumo_changeset:cast(?MODULE, 
                      Init, 
                      Params,
                      hs_utils:allowed_fields(?MODULE)).

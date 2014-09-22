-module(simple_auth_riak_server).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
    terminate/2, code_change/3, validate/2
  ]).

start_link() ->
  gen_server:start_link({ local, ?MODULE }, ?MODULE, [], []).

init(_Args) ->
  { ok, Pid} = riakc_pb_socket:start_link(localhost, 8087),

  { ok, Pid }.

validate(Username, Password) ->
  gen_server:call(?MODULE, { validate, Username, Password }).

handle_call({ validate, Username, Password }, _From, RiakPid) ->
  Pass = case get_user(RiakPid, Username) of
    { ok, Obj } -> Obj;
    { error, notfound } -> notfound
  end,
  Res = case Pass of
    Password -> authorized;
    notfound -> { error, notfound };
    _        -> { error, unauthorized }
  end,

  { reply, Res, RiakPid };

handle_call(_Msg, _From, RiakPid) ->
  { reply, ok, RiakPid }.

handle_cast(_Msg, RiakPid) ->
  { noreply, RiakPid }.

handle_info(_Info, RiakPid) ->
    {noreply, RiakPid}.

terminate(_Reason, _RiakPid) ->
    ok.

code_change(_OldVsn, RiakPid, _Extra) ->
    {ok, RiakPid}.

get_user(RiakPid, Username) ->
  case riakc_pb_socket:get(RiakPid, <<"users">>, Username) of
    { ok, Obj } ->
      { ok, riakc_obj:get_value(Obj) };
    {error, notfound} ->
      { error, notfound }
  end.

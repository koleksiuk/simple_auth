-module(simple_auth_server).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
    terminate/2, code_change/3, validate/1
  ]).

start_link() ->
  gen_server:start_link({ local, ?MODULE }, ?MODULE, [], []).

init(_Args) ->
  { ok, [] }.

validate(Params) ->
  #{"username" := Username , "password" := Password} = Params,
  gen_server:call(?MODULE, { validate, Username, Password}).

handle_call({ validate, Username, Password}, _From, State) ->
  case simple_auth_riak_server:validate(Username, Password) of
    authorized -> io:format("User ~s validated!~n", [Username]);
    { error, Err } -> io:format("User ~s ~s!~n", [Username, Err])
  end,

  { reply, ok, State };

handle_call(_Msg, _From, State) ->
  { reply, ok, State }.

handle_cast(_Msg, State) ->
  { noreply, State }.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

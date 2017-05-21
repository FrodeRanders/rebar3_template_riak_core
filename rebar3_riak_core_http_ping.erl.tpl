-module({{ name }}_http_ping).

-export([init/2, terminate/3]).

-ignore_xref([init/2, terminate/3]).

-export([rest_init/2,
         rest_terminate/2,
         allowed_methods/2,
         content_types_provided/2,
         to_json/2]).

-ignore_xref([rest_init/2,
         rest_terminate/2,
         allowed_methods/2,
         content_types_provided/2,
         to_json/2]).

-record(state, {}).

% A simple handler
%init(Req0, State) ->
%    Req = cowboy_req:reply(200,
%       #{<<"content-type">> => <<"application/json">>},
%       <<"PONG">>,
%       Req0),
%    {ok, Req, State}.

init(Req, State) ->
   {cowboy_rest, Req, State}.
   
rest_init(Req, _Opts) -> {ok, Req, #state{}}.

allowed_methods(Req, State) -> {[<<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    {[{ {<<"application">>, <<"json">>, '*'}, to_json}], Req, State}.

to_json(Req, State) ->
    {pong, Partition} = {{ name }}:ping(),
    Response = {{ name }}_json:encode([{pong, integer_to_binary(Partition)}]),
    {Response, Req, State}.

rest_terminate(_Req, _State) -> ok.
terminate(_Reason, _Req, _State) -> ok.

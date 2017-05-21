-module({{name}}_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    init_http(),
    case {{name}}_sup:start_link() of
        {ok, Pid} ->
            ok = riak_core:register([{vnode_module, {{name}}_vnode}]),
            ok = riak_core_node_watcher:service_up({{name}}, self()),

            {ok, Pid};
        {error, Reason} ->
            {error, Reason}
    end.

stop(_State) ->
    ok.

%% ===================================================================
%% Web frontend support
%% ===================================================================
routes() ->
    [
       {"/ping", {{ name }}_http_ping, []}
    ].

init_http() ->
    DispatchRoutes = routes(),
    
    %% {HostMatch, list({PathMatch, Handler, InitialState})}
    Dispatch = cowboy_router:compile([
        {'_', DispatchRoutes}
    ]),

    % [{env, [{dispatch, Dispatch}]}],
    CowboyOpts = #{env => #{dispatch => Dispatch} }, 
    ApiAcceptors = envd(http_acceptors, 100),
    ApiPort = envd(http_port, 8080),

    {ok, _} = cowboy:start_clear(http, ApiAcceptors, [{port, ApiPort}], CowboyOpts).

env(App, Par, Def) -> application:get_env(App, Par, Def).

envd(Par, Def) -> env({{ name }}, Par, Def).

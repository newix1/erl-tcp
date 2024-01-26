-module(dialer).
-export([start_server/0, start_server/1, acceptor/1, handle/1]).

%% You can start server on any port. To do it use dialer:start_server(Port) 
%% or dialer:start_server w/o any arguments to start server on default port 8091
start_server() ->
    start_server(8091).

start_server(Port) ->
    Pid = spawn_link(fun() ->
        {ok, Listen} = gen_tcp:listen(Port, [binary, {active, false}, {packet, 2}]),
        spawn(fun() -> acceptor(Listen) end),
        timer:sleep(infinity)
    end),
    {ok, Pid}.

acceptor(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    spawn(fun() -> acceptor(ListenSocket) end),
    handle(Socket).

%% Displaying in shell and echoing back whatever was obtained
handle(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Msg} -> io:format("Socket got message: ~p~n", [Msg]),
                     gen_tcp:send(Socket, Msg),
                     handle(Socket);
        {error, closed} ->
            io:format("Socket session closed ~n"),
            acceptor(Socket)
    end.    
